<?php
    // 判断命令行参数
    if ($argc < 3) {
        echo "Argument error!\n";
        echo "Usage:   php main.php [change|renew|export|backup|clone|cloneback|clean] localhost\n";
        echo "Usage:   php main.php [restore|repair] localhost filename[.php]\n";
        exit;
    }

    // 加载配置文件
    require_once 'conf.php';

    // 设定用于所有日期时间函数的默认时区
    date_default_timezone_set("Asia/Shanghai");

    // 目录路径
    $change_log_dir = "change_log/";
    $change_dir     = "change/";
    $repair_dir     = "repair/";
    $backup_dir     = "backup/";

    // 文件名称
    $temp_cron_file = "template_data.clone.php";

    // 参数声明赋值
    $mode    = $argv[1];
    $db_sign = $argv[2];

    // 数据库配置
    $db_host = $db_argv[$db_sign]['host'];
    $db_user = $db_argv[$db_sign]['user'];
    $db_pass = $db_argv[$db_sign]['pass'];
    $db_name = $db_argv[$db_sign]['name'];
    $db_port = $db_argv[$db_sign]['port'];

    // 数据库准备
    $db_version = prepare_db();

    // 生成新的数据库连接对象
    $mysqli = new mysqli($db_host, $db_user, $db_pass, $db_name, $db_port);
    $mysqli->query("SET NAMES utf8;");

    if ($mode == "change" || $mode == "renew") {
        // 变更数据结构|重新开始
        @unlink($temp_cron_file);
        change_db();
    } else if ($mode == "export") {
        // 导出数据库模版
        change_db();
        export_db(false);
    } else if ($mode == "backup") {
        // 备份所有数据
        change_db();
        export_db(true);
    } else if ($mode == "restore") {
        // 恢复备份数据
        $backup_file = str_replace(".php", "", $argv[3]);
        require_once($backup_dir.$backup_file.".php");
    } else if ($mode == "repair") {
        // 执行修复脚本
        $main_stime   = microtime(true);
        $repair_file = str_replace(".php", "", $argv[3]);
        require_once($repair_dir.$repair_file.".php");
        $main_etime = microtime(true);
        $dots = generate_char(20, strlen($db_name), '.');
        echo "\nRepair db:{$db_name} {$dots} complete in ".round($main_etime - $main_stime, 2)."s\n";
    } else if ($mode == "clone") {
        // 克隆数据库
        export_db(false);
    } else if ($mode == "cloneback") {
        // 恢复克隆的数据库
        $main_stime   = microtime(true);
        require_once($temp_cron_file);
        $main_etime = microtime(true);
        $dots = generate_char(20, strlen($db_name), '.');
        echo "\nCloneB db:{$db_name} {$dots} complete in ".round($main_etime - $main_stime, 2)."s\n";
    } else if ($mode == "clean") {
        // 清空数据
        $main_stime   = microtime(true);
        $query_player = query_array("SELECT 1 FROM `player`;");
        if (count($query_player) >= 20) {
            echo "Too many player ".count($query_player)."! Cannt clean!\n";
            exit();
        }
        
        execute("SET FOREIGN_KEY_CHECKS=0;");
        $tables     = get_tables();
        $max_length = get_max_length($tables);
        foreach ($tables as $table_name) {
            if ($table_name == 'db_version')
                continue;

            $dots = generate_char($max_length, strlen($table_name), '.');
            echo "delete {$table_name} {$dots}......... ";
            execute("DELETE FROM `{$table_name}`;");
            echo "[done]\n";

    
        }
        $main_etime = microtime(true);
        $dots = generate_char(20, strlen($db_name), '.');
        echo "\nClean  db:{$db_name} {$dots} complete in ".round($main_etime - $main_stime, 2)."s\n";
    } else {
        echo "Unknown mode {$mode}!\n";
    }

    // 关闭数据库连接
    $mysqli->close();



// ==========================================================================================
// ============================== 查询数据库函数 ==============================
// @todo   查询数据库|有返回字段
function query ($sql) {
    global $mysqli;
    
    $result = $mysqli->query($sql, MYSQLI_USE_RESULT);
    if (!$result)
        die("Query Error (" . $mysqli->errno . ") " . $mysqli->error."\n");
    
    $rows = array();
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $rows[] = $row;
    }

    $result->close();
    
    return $rows;
}


// @todo   批量查询数据库|没返回字段
function query_array ($sql) {
    global $mysqli;

    $result = $mysqli->query($sql, MYSQLI_USE_RESULT);
    if (!$result)
        die("Query Array Error (" . $mysqli->errno . ") " . $mysqli->error."\n");

    $rows = array();
    while ($row = $result->fetch_array(MYSQLI_NUM)) {
        $rows[] = $row;
    }

    $result->close();

    return $rows;
}


// @todo   执行数据库语句
function execute ($sql) {
    global $mysqli;

    if(!$mysqli->multi_query($sql)){
        echo "\nSQL execute failure\n-----------------\n{$sql}\n-----------------\n";
        die("Execute Error (" . $mysqli->errno . ") " . $mysqli->error."\n");
    }

    free_result();
}

function free_result() {
    global $mysqli;

    do {
        if ($result = $mysqli->store_result()) {
            $result->free();
        }

        if (! $mysqli->more_results()) {
            break;
        }
    } while ($mysqli->next_result());
}



// ==============================  ==============================
// @todo   获取变更脚本
function get_changes () {
    global $change_dir, $change_log_dir;
    $changes = array();

    get_files_from_dir($change_dir, $changes);
    get_files_from_dir($change_log_dir, $changes);
    asort($changes);
    
    return $changes;
}


// @todo   获取某个路径下的文件
function get_files_from_dir ($dir, &$changes) {
    if ($handle = opendir($dir)) {
        while (FALSE !== ($file = readdir($handle))) {
            if ($file == "." || $file == ".." || is_dir($file)) {
                continue;
            } else if (strrpos($file, ".php") == 13) {
                if (strlen($file) == 17) {
                    $name    = substr($file, 0, -4);
                    $id      = (int)str_replace("-", "", $name);
                    $is_dump = false;
                } else {
                    continue;
                }
            } else if (strrpos($file, ".dump.php") == 13) {
                if (strlen($file) == 22) {
                    $name    = substr($file, 0, -9);
                    $id      = (int)str_replace("-", "", $name);
                    $is_dump = true;
                } else {
                    continue;
                }
            } else {
                continue;
            }
        
            $changes[$id] = array('file' => $file, 'dir' => $dir, 'is_dump' => $is_dump);
        }
    }
}

// @todo   获取最大版本
function get_max_version ($changes) {
    $max_version = 0;
    
    foreach (array_keys($changes) as $version) {
        if ($version > $max_version)
            $max_version = $version;
    }

    return $max_version;
}


// @todo   获取最大长度
function get_max_length ($tables) {
    $max_length = 0;
    
    foreach ($tables as $table) {
        $len = strlen($table);
        
        if ($len > $max_length)
            $max_length = $len;
    }
    
    return $max_length;
}


// @todo   生成填补字符
function generate_char ($max_length, $length, $char) {
    $space      = "";
    $fill_len   = $max_length - $length;
    for ($i = 0; $i < $fill_len; $i ++) {
        $space .= $char;
    }
     
    return $space;
}


// @todo   获取对应数据库的所有表
function get_tables () {
    global $db_host, $db_user, $db_pass, $db_name, $db_port;
    $mysqli = new mysqli($db_host, $db_user, $db_pass, 'information_schema', $db_port);
    if ($mysqli->connect_error) {
        die("Open 'information_schema' failed (" . $mysqli->connect_errno . ") " . $mysqli->connect_error."\n");
    }
    
    $sql    = "SELECT `TABLE_NAME` FROM `TABLES` WHERE `TABLE_SCHEMA` = '{$db_name}';";
    $result = $mysqli->query($sql);
    $tables = array();
    
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $tables[] = $row['TABLE_NAME'];
    }
    
    $result->close();
    $mysqli->close();
    
    return $tables;
}


// @todo   获取表字段
function get_table_fields ($mysqli, $table_name) {
    $sql    = "SHOW FIELDS FROM `{$table_name}`;";
    $result = $mysqli->query($sql);
    $fields = array();
    
    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $fields[] = $row['Field'];
    }
    
    $result->close();
    
    return $fields;
}


// @todo   获取表的创建语句
function get_create_table_sql ($mysqli, $table_name) {
    $sql    = "SHOW CREATE TABLE `{$table_name}`;";
    $result = $mysqli->query($sql);
    $row    = $result->fetch_array(MYSQLI_ASSOC);
    // 剔除掉语句中的自增长字段值
    $create_table_sql = preg_replace("/AUTO_INCREMENT=\d{1,}/", "", $row['Create Table']);
    $create_table_sql = preg_replace("/\\n  /", "\n            ", $create_table_sql);
    $create_table_sql = preg_replace("/\\n\)/", "\n        )", $create_table_sql);
    
    $result->close();
    
    return "        ".$create_table_sql.";";
}


// @todo   获取表的数据插入语句
function get_insert_into_sql ($mysqli, $table_name, $fields) {
    $fields_arr = implode("`, `", $fields);
    $insert_sql = "    INSERT INTO `{$table_name}` (`{$fields_arr}`) VALUES";
    $insert_arr = array();
        
    $select_sql = "SELECT `{$fields_arr}` FROM `{$table_name}`;";
    $result     = $mysqli->query($select_sql, MYSQLI_USE_RESULT);
    
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $values = array();
    
        foreach ($fields as $field) {
            //$values[] = str_replace(array('"', '\'', '\\n'), array('\"', '\\\'', '\\\\n'), $row[$field]);
            $values[] = $mysqli->real_escape_string($row[$field]);
        }
        
        $insert_arr[] = "\n        ('".implode("', '", $values)."')";
    }

    if (count($insert_arr) == 0){
        $result->close();
        return "";
    }
    
    $insert_sql .= implode(", ", $insert_arr).";\n";
    
    $result->close();
    
    return $insert_sql;
}



// ============================== 操作数据库函数 ==============================
// @todo   准备数据库
// @return version
function prepare_db () {
    global $db_host, $db_user, $db_pass, $db_name, $db_port;
    
    // 连接数据库
    $mysqli = @new mysqli($db_host, $db_user, $db_pass, 'information_schema', $db_port);
    if ($mysqli->connect_error) {
        die("Open 'information_schema' failed (".$mysqli->connect_errno.") ".$mysqli->connect_error."\n");
    }
    
    
    // 判断是否需要初始创建数据库
    $sql          = "SELECT `SCHEMA_NAME` 
        FROM `SCHEMATA` 
        WHERE `SCHEMA_NAME` = '{$db_name}';";
    $result       = $mysqli->query($sql);
    $need_init_db = $result->fetch_array(MYSQLI_ASSOC) == false;
    $result->close();

    if ($need_init_db) {
        $sql = "CREATE DATABASE `{$db_name}` 
            CHARACTER SET 'utf8' 
            COLLATE 'utf8_general_ci';";
        
        if ($mysqli->query($sql) === FALSE)
            die("Prepare database:{$db_name} fialed (" . $mysqli->errno . ") " . $mysqli->error."\n");
    }
    
    
    // 判断是否需要初始创建表`db_version`
    $sql             = "SELECT `TABLE_NAME` 
        FROM `TABLES` 
        WHERE `TABLE_NAME` = 'db_version' 
        AND `TABLE_SCHEMA` = '{$db_name}';";
    $result          = $mysqli->query($sql);
    $need_init_table = $result->fetch_array(MYSQLI_ASSOC) == false;
    $result->close();

    $sql = "USE `{$db_name}`;";
    $mysqli->query($sql);
    
    if ($need_init_table) {
        $version = (int)date('Ymd'.'01');
        $sql = "CREATE TABLE `db_version` 
            (
                `version`   INTEGER     NOT NULL DEFAULT 0      COMMENT '版本号:{$version}',
                `release`   VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '发布号:R001',
                CONSTRAINT `pk_db_version` PRIMARY KEY (`version`)
            )
            COMMENT       = '数据库版本'
            ENGINE        = 'InnoDB'
            CHARACTER SET = 'utf8'
            COLLATE       = 'utf8_general_ci';
            INSERT INTO `db_version` (`version`) VALUES (0);";
        if ($mysqli->multi_query($sql) === FALSE)
            die("Prepare `db_version` fialed (" . $mysqli->errno . ') ' . $mysqli->error."\n");
            
        $mysqli->close();
        $mysqli  = new mysqli($db_host, $db_user, $db_pass, $db_name, $db_port);
    }
    
    $sql    = "SELECT `version` FROM `db_version`;";
    $result = $mysqli->query($sql);
    $row    = $result->fetch_array(MYSQLI_ASSOC);
    $result->close();
    
    if ($row == false) { 
        $mysqli->query("INSERT INTO `db_version` (`version`) VALUES (0);");
        $version = 0;
    } else {
        $version = $row['version'];
    }

    $mysqli->close();
    
    return $version;
}


// @todo   变更数据结构,将 $mode 所配置的数据库更新到 $change_dir 目录中的最新版本
function change_db () {
    global $mysqli, $db_version, $mode;
    
    $changes             = get_changes();
    $last_export_version = 0;
    $change_num          = 0;
    $main_stime          = microtime(true);
    
    foreach (array_keys($changes) as $version) {
        if ($changes[$version]['is_dump'] && $last_export_version <= $version)
            $last_export_version = $version;
    }

    foreach (array_keys($changes) as $version) {
        if ($db_version == 0) {
            // 初始化则从最新的模版开始
            if ($version < $last_export_version)
                continue;
        } else if ($mode == "renew") {
            // renew 是想引用最新模版数据和数据结构
            if ($version < $last_export_version || $version <= $db_version && $changes[$version]['is_dump'] == false)
                continue;
        } else if ($version <= $db_version || ($changes[$version]['is_dump'] && $version < $last_export_version)) {
            continue;
        }
        
        echo "\napply  change: ".$changes[$version]['file'];
        require_once($changes[$version]['dir'].$changes[$version]['file']);
        $change_num += 1;
        
        $sql = "UPDATE `db_version` SET `version` = {$version};";
        if ($mysqli->query($sql) === FALSE)
            die("Can not query:'UPDATE `db_version` SET `version` = {$version}'\n");
        
        if ($changes[$version]['is_dump'])
            echo "apply  change: ".$changes[$version]['file']." ................... [done]";
        else
            echo " ........................ [done]";
    }
    
    $main_etime = microtime(true);
    echo "\n\nApply  change:".sprintf("%03d", $change_num)." ............. complete in ".round($main_etime - $main_stime, 2)."s\n";
}


// @todo   导出数据库
function export_db ($is_backup = false) {
    global $mode, $mysqli, $db_host, $db_name, $backup_dir, $change_dir, $temp_cron_file;
    
    $main_stime = microtime(true);
        
    if ($mode == "clone") {
        $output_file = str_replace("\\", "/", getcwd())."/".$temp_cron_file;
    } else if ($is_backup) {
        $output_file = str_replace("\\", "/", getcwd())."/".$backup_dir.date("Y-m-d_H-i-s").".php";
    } else {
        $changes     = get_changes();
        $max_version = get_max_version($changes);

        $i           = 0;
        while (true) {
            $i += 1;
            
            $file_name  = date("Y-m-d") . "-" . sprintf("%02d", $i);
            $version    = (int)str_replace("-", "", $file_name);
            
            if ($version > $max_version) {
                break;
            }
        }

        $output_file = str_replace("\\", "/", getcwd())."/".$change_dir.$file_name.".dump.php";
    }
    
    $file       = fopen($output_file, 'c');
    $tables     = get_tables();
    $max_length = get_max_length($tables);
    $mysql_vsn  = $mysqli->get_server_info();
    
    // fwrite($file, "<?php\n\n");
    // fwrite($file, "echo \"\\n\\n\";\n");
    fwrite($file, "<?php

// MySQL dump 10.13  Distrib {$mysql_vsn}, for osx10.13 (x86_64)

// Host: {$db_host}    Database: {$db_name}
// ------------------------------------------------------
// Server version   {$mysql_vsn}


echo \"\\n\\n\";\n
execute(\"
    /*!40101 SET NAMES utf8 */;

    /*!40101 SET SQL_MODE=''*/;

    /*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
    /*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
    /*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
    /*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
\");


");

    if ($mode == "clone") 
        $echo_mode = "clone  ";
    else if ($mode == "backup")
        $echo_mode = "backup ";
    else if ($mode == "export")
        $echo_mode = "dump   ";

    foreach ($tables as $table_name) {
        $dots = generate_char($max_length, strlen($table_name), '.');
        if ($table_name == "db_version") {
            fwrite($file, 'if ($db_version == 0) {'."\n");
            fwrite($file, "    echo \"    {$table_name} {$dots}......... [ignore]\\n\";\n\n");
            fwrite($file, "}\n\n");
            echo $echo_mode.$table_name." {$dots}......... [ignore]\n";
            continue;
        }
        echo $echo_mode.$table_name." {$dots}......... ";
        
        $sql  = get_create_table_sql($mysqli, $table_name);

        fwrite($file, 'if ($db_version == 0) {'."\n");
        fwrite($file, "    echo \"    {$table_name} {$dots}......... \";\n\n");
        
        fwrite($file, "    execute(\"\n");
        fwrite($file, $sql);
        fwrite($file, "\n    \");\n\n");
        
        fwrite($file, "    echo \"[created]\\n\"; \n"); 
        fwrite($file, "}\n\n");
        
        if ($is_backup == false && (strpos($table_name, "player") === 0 
            || $table_name == "server_state" 
            || $table_name == "world_boss_state" 
            || $table_name == "level_up_record" 
            || $table_name == 'max_online' 
            || $table_name == 'friend_chat_times')) {
            echo "[ignore]\n";
            continue;
        }
            
        $fields = get_table_fields($mysqli, $table_name);
        $sql    = get_insert_into_sql($mysqli, $table_name, $fields);
        
        fwrite($file, "echo \"    {$table_name} {$dots}......... \";\n\n");
        fwrite($file, "execute(\"DELETE FROM `{$table_name}`;\");\n\n");
        if ($sql != "") {
            fwrite($file, "execute(\"\n");
            fwrite($file, $sql);
            fwrite($file, "\");\n\n");
        }
        fwrite($file, "echo \"[loaded]\\n\"; \n"); 
        fwrite($file, "\n");
        
        echo "[done]\n";
    }

    fwrite($file, "
execute(\"
    /*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
    /*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
    /*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
    /*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
\");

");

    fwrite($file, "echo \"\\n\";\n");
    fwrite($file, "?>\n");
    
    fclose($file);
    
    if ($mode == "export") {
        $sql = "UPDATE `db_version` SET `version` = {$version};";

        if ($mysqli->query($sql) === FALSE)
            die("Can not query:'UPDATE `db_version` SET `version` = {$version}'\n");
    }
    
    $main_etime = microtime(true);
    
    $dots = generate_char(20, strlen($db_name), '.');
    if ($mode == "clone") 
        echo "\n\nClone  db:{$db_name} {$dots} complete in ".round($main_etime - $main_stime, 2)."s\n";
    else if ($mode == "backup")
        echo "\n\nBackup db:{$db_name} {$dots} complete in ".round($main_etime - $main_stime, 2)."s\n";
    else if ($mode == "export")
        echo "\n\nExport db:{$db_name} {$dots} complete in ".round($main_etime - $main_stime, 2)."s\n";
}

?>