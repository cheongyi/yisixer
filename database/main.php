<?php
    // 判断命令行参数
    if ($argc < 3) {
        echo 'argument error.\n';
        echo 'example: php main.php [update|backup|restore|dump|cron] localhost';
        exit;
    }

    // 加载配置文件
    require_once 'conf.php';

    date_default_timezone_set('Asia/Shanghai');

    // 参数声明赋值
    $mode    = $argv[1];
    $db_sign = $argv[2];

    $db_host = $db_argv[$db_sign]['host'];
    $db_user = $db_argv[$db_sign]['user'];
    $db_pass = $db_argv[$db_sign]['pass'];
    $db_name = $db_argv[$db_sign]['name'];
    $db_port = $db_argv[$db_sign]['port'];

    $db_version = prepare_db();

    $db = new mysqli($db_host, $db_user, $db_pass, $db_name, $db_port);
    $db->query('SET NAMES utf8;');

    if ($mode == "update" || $mode == "renew") {
        @unlink('changes/template_data.cron.php');
        update_db();
    } else if ($mode == "backup") {
        export_db(true);
    } else if ($mode == "restore") {
        $backup_file = $argv[3];
        require_once("./backup/".$backup_file.".php");
    } else if ($mode == "export") {
        update_db();
        export_db(false);
    } else if ($mode == "run") {
        require_once("update/".$argv[3].".php");
    } else if ($mode == "run_cron") {
        require_once("changes/template_data.cron.php");
    } else if ($mode == "cron") {
        cron_db();
    } else if ($mode == "clean") {
        if (count(query_array('SELECT 1 FROM `player`')) > 19) {
            echo "too_many_player";
            exit();
        }
        
        execute("SET FOREIGN_KEY_CHECKS=0;");
        $tables = query_array("SHOW TABLES;");
        foreach ($tables as $table) {
            if ($table[0] == 'db_version')
              continue;

            echo "$table[0]\n";
            execute("DELETE FROM ".$table[0]);
        }
    }

    $db->close();



// ==========================================================================================
// ============================== 查询数据库函数 ==============================
// @todo   查询数据库
function query ($sql) {
    global $db;
    
    $result = $db->query($sql, MYSQLI_USE_RESULT);
    if (!$result)
        die('Query Error (' . $db->errno . ') ' . $db->error);
    
    $rows = array();
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $rows[] = $row;
    }

    $result->close();
    
    return $rows;
}


// @todo   批量查询数据库
function query_array ($sql) {
    global $db;

    $result = $db->query($sql, MYSQLI_USE_RESULT);
    if (!$result)
        die('Query Array Error (' . $db->errno . ') ' . $db->error);

    $rows = array();
    while ($row = $result->fetch_array(MYSQLI_NUM)) {
        $rows[] = $row;
    }

    $result->close();

    return $rows;
}


// @todo   执行数据库语句
function execute ($sql) {
    global $db;

    if(!$db->multi_query($sql)){
        echo "\nsql execute failure\n-----------------\n$sql\n------------\n";
        printf("Error - SQLSTATE %d: %s.\n", $db->errno, $db->error);
        echo ("!!!!!!!!!!!!!!!!!!!\n");
        die('error occur, exited.');
    }

    free_result();
}

function free_result() {
    global $db;

    do {
        if ($result = $db->store_result()) {
            $result->free();
        }

        if (! $db->more_results()) {
            break;
        }
    } while ($db->next_result());
}



// ==============================  ==============================
// @todo   获取变更脚本
function get_changes () {
    $changes = array();
    
    get_files_from_dir('changes', $changes);
    get_files_from_dir('changes_log', $changes);
    asort($changes);
    
    return $changes;
}


// @todo   获取某个路径下的文件
function get_files_from_dir ($dir, &$changes) {
    if ($handle = opendir('./'.$dir)) {
        while (FALSE !== ($file = readdir($handle))) 
        {
            if ($file == "." || $file == ".." || is_dir($file))
                continue;
            
            if (strrpos($file, ".php") == 13) {
                if (strlen($file) != 17)
                    continue;
                else {
                    $name    = substr($file, 0, -4);
                    $id      = (int)str_replace('-', '', $name);
                    $is_dump = false;
                }
            } else if (strrpos($file, ".dump.php") == 13) {
                if (strlen($file) != 22)
                    continue;
                else {
                    $name    = substr($file, 0, -4);
                    $id      = (int)str_replace('.dump', '', str_replace('-', '', $name));
                    $is_dump = true;
                }
            } else {
                continue;
            }
        
            $changes[$id] = array('name' => $name, 'dir' => $dir, 'is_dump' => $is_dump);
        }
    }
}


// @todo   获取最大长度
function get_max_length ($str_array) {
    $max_length = 0;
    
    foreach ($str_array as $str) {
        $len = strlen($str);
        
        if ($len > $max_length)
            $max_length = $len;
    }
    
    return $max_length;
}


// @todo   生成填补字符
function generate_char ($max_length, $length, $char) {
    $space      = '';
    $fill_len   = $max_length - $length;
    for ($i = 0; $i < $fill_len; $i ++) {
        $space .= $char;
    }
     
    return $space;
}


// @todo   获取对应数据库的所有表
function get_tables ($db_host, $db_user, $db_pass, $db_name, $db_port) {
    $db = new mysqli($db_host, $db_user, $db_pass, 'information_schema', $db_port);
    if ($db->connect_error) {
        die('open information_schema failed (' . $db->connect_errno . ') ' . $db->connect_error);
    }
    
    $sql    = "SELECT `TABLE_NAME` FROM `TABLES` WHERE `TABLE_SCHEMA` = '$db_name'";
    $result = $db->query($sql);
    $tables = array();
    
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $tables[] = $row['TABLE_NAME'];
    }
    
    $result->close();
    $db->close();
    
    return $tables;
}


// @todo   获取表字段
function get_table_fields ($db, $table_name) {
    $sql    = "SHOW FIELDS FROM `".$table_name."`";
    $result = $db->query($sql);
    $fields = array();
    
    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $fields[] = $row['Field'];
    }
    
    $result->close();
    
    return $fields;
}


// @todo   获取表的创建语句
function get_create_table_sql ($db, $table_name) {
    $sql    = "SHOW CREATE TABLE `".$table_name."`";
    $result = $db->query($sql);
    $row    = $result->fetch_array(MYSQLI_ASSOC);
    // 剔除掉语句中的自增长字段值
    $create_table_sql = preg_replace('/AUTO_INCREMENT=\d{1,}/', "", $row['Create Table']) . ";";
    
    $result->close();
    
    return $create_table_sql;
}


// @todo   获取表的数据插入语句
function get_insert_into_sql ($db, $table_name, $fields, $is_backup) {
    $fields_arr = implode("`, `", $fields);
    $insert_sql = "    INSERT INTO `".$table_name."` (`".$fields_arr."`) VALUES";
    $insert_arr = array();
        
    $select_sql = "SELECT `".$fields_arr."` FROM `".$table_name."`";
    $result     = $db->query($select_sql, MYSQLI_USE_RESULT);
    
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $values = array();
    
        foreach ($fields as $field) {
            //$values[] = str_replace(array('"', '\'', '\\n'), array('\"', '\\\'', '\\\\n'), $row[$field]);
            $values[] = mysqli_real_escape_string($db, $row[$field]);
        }
        
        $insert_arr[] = "\n        ('".implode("','", $values)."')";
    }

    if (count($insert_arr) == 0){
        $result->close();
        return "";
    }
    
    $insert_into_sql .= implode(',', $insert_rows). ";\n";
    
    $result->close();
    
    return $insert_into_sql;
}



// ============================== 操作数据库函数 ==============================
// @todo   准备数据库
// @return version
function prepare_db () {
    global $db_host, $db_user, $db_pass, $db_name, $db_port;
    
    // 连接数据库
    $db = new mysqli($db_host, $db_user, $db_pass, 'information_schema', $db_port);
    if ($db->connect_error) {
        die('open information_schema failed (' . $db->connect_errno . ') ' . $db->connect_error);
    }
    
    
    // 判断是否需要初始创建数据库
    $sql          = "SELECT `SCHEMA_NAME` 
        FROM `SCHEMATA` 
        WHERE `SCHEMA_NAME` = '".$db_name."'";
    $result       = $db->query($sql);
    $need_init_db = $result->fetch_array(MYSQLI_ASSOC) == false;
    $result->close();

    if ($need_init_db) {
        $sql = "CREATE DATABASE `".$db_name."` 
            CHARACTER SET 'utf8' 
            COLLATE 'utf8_general_ci';\n";
        
        if ($db->query($sql) === FALSE)
            die("prepare database fialed (" . $db->errno . ') ' . $db->error);
    }
    
    
    // 判断是否需要初始创建表`db_version`
    $sql             = "SELECT `TABLE_NAME` 
        FROM `TABLES` 
        WHERE `TABLE_NAME` = 'db_version' 
        AND `TABLE_SCHEMA` = '".$db_name."'";
    $result          = $db->query($sql);
    $need_init_table = $result->fetch_array(MYSQLI_ASSOC) == false;
    $result->close();

    $sql = "USE `".$db_name."`";
    $db->query($sql);
    
    if ($need_init_table) {
        $sql = "CREATE TABLE `db_version` ( `version` INT );\n"
             . "INSERT INTO `db_version` VALUES (0);\n";
        if ($db->multi_query($sql) === FALSE)
            die("prepare database fialed (" . $db->errno . ') ' . $db->error);
            
        $db->close();
        $db  = new mysqli($db_host, $db_user, $db_pass, $db_name, $db_port);
    }
    
    $sql    = "SELECT `version` FROM `db_version`";
    $result = $db->query($sql);
    $row    = $result->fetch_array(MYSQLI_ASSOC);
    $result->close();
    
    if ($row == FALSE) { 
        $db->query("INSERT INTO `db_version` VALUES (0);");
        $version = 0;
    } else {
        $version = $row['version'];
    }

    $db->close();
    
    return $version;
}


// @todo   更新数据库,将 db_name 所引用的数据库更新到changes目录中可以找到的最新版本
function update_db () {
    global $db, $db_version, $mode;
    
    $changes             = get_changes();
    $main_stime          = microtime(true);
    $last_export_version = 0;
    
    foreach (array_keys($changes) as $version) {
        if ($changes[$version]['is_dump'] && $last_export_version <= $version)
            $last_export_version = $version;
    }

    foreach (array_keys($changes) as $version) {
        if ($db_version == 0 || $mode == 'renew') {
            if ($version < $last_export_version)
                continue;
        } else if ($version <= $db_version || ($changes[$version]['is_dump'] && $version < $last_export_version)) {
            continue;
        }
        
        echo "\napply change: ".$changes[$version]['name'].".php";
        require_once("./".$changes[$version]['dir']."/".$changes[$version]['name'].".php");
        
        $sql = "UPDATE `db_version` SET `version` = ".$version;
        if ($db->query($sql) === false)
            die("can not update db_version");
        
        echo " ........................ [done]";
    }
    
    $main_etime = microtime(true);
    echo "\n\napply changes complete in ".round($main_etime - $main_stime, 2)."s\n";
}


// @todo   导出数据库，true则生成.dump文件
function export_db ($is_backup = false) {
    global $db, $db_host, $db_user, $db_pass, $db_name, $db_port;
    
    $main_stime = microtime(true);
        
    if ($is_backup) {
        $output_file = str_replace('\\', '/', getcwd())."/backup/".date("Y-m-d_H-i-s").".php";
    } else {
        // $version = (int)(date("Ymd") . "01");
        $changes = get_changes();
        $i       = 0;

        while (true) {
            $i += 1;
            
            $file_name  = date("Y-m-d") . "-" . sprintf("%02d", $i);
            $version    = (int)str_replace('-', '', $file_name);
            
            if (array_key_exists($version, $changes) == false) {
                break;
            }
        }

        $output_file = str_replace('\\', '/', getcwd())."/changes/".$file_name.".dump.php";
    }
    

    $file       = fopen($output_file, 'c');
    $tables     = get_tables($db_host, $db_user, $db_pass, $db_name, $db_port);
    $max_length = get_max_length($tables);
    
    fwrite($file, "<?php\n\n");
    fwrite($file, "echo \"\\n\\n\";\n");
    fwrite($file, "
execute(\"
/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
\");
");

    foreach ($tables as $table_name) {
        if ($table_name == "db_version")
            continue;
            
        if ($is_backup)
            echo "backup ";
        else
            echo "dump ";
            
        echo $table_name." ";
        $dots = generate_char($max_length, strlen($table_name), '.');
        echo $dots;
        echo "......... ";
        
        $sql  = get_create_table_sql($db, $table_name);

        fwrite($file, 'if ($db_version == 0) {'."\n");
        fwrite($file, "    echo \"    " . $table_name . " " . $dots . "......... \";\n\n");
        
        fwrite($file, "    execute(\"\n");
        fwrite($file, $sql);
        fwrite($file, "\n\");\n\n");
        
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
            
        $fields = get_table_fields($db, $table_name);
        $sql    = get_insert_into_sql($db, $table_name, $fields, $is_backup);
        
        fwrite($file, "echo \"    " . $table_name . " " . $dots . "......... \";\n\n");
        fwrite($file, "execute(\"DELETE FROM `" . $table_name . "`\");\n\n");
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
    
    if ($is_backup == false)
    {
        $sql = "UPDATE `db_version` SET `version` = ".$version;
       
        if ($db->query($sql) === false)
            die("can not update db_version");
    }
    
    $main_etime = microtime(true);
    
    echo "\ndatabase ";

    if ($is_backup)
        echo "backup ";
    else
        echo "dump ";
        
    echo "complete in ".round($main_etime - $main_stime, 2)."s\n";
}

?>