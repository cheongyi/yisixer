<?php
    // 设定用于所有日期时间函数的默认时区
    date_default_timezone_set("Asia/Shanghai");

    // 加载配置文件
    require_once 'conf.php';
    require_once 'lib_misc.php';
    require_once 'game_db_hrl.php';
    require_once 'game_db_data.php';
    require_once 'game_db_dump.php';
    require_once 'game_db_init.php';
    require_once 'game_db_sync.php';
    require_once 'game_db_table.php';

    // 数据库配置
    $db_sign = 'localhost';
    if ($argc > 1) {
        $db_sign = $argv[1];
    }
    $db_host = $db_argv[$db_sign]['host'];
    $db_user = $db_argv[$db_sign]['user'];
    $db_pass = $db_argv[$db_sign]['pass'];
    $db_name = $db_argv[$db_sign]['name'];
    $db_port = $db_argv[$db_sign]['port'];

    // 目录路径
    $server_dir         = "../server/";
    $include_gen_dir    = "{$server_dir}include/gen/";
    $src_gen_dir        = "{$server_dir}src/gen/";

    // 文件名称
    $game_db_hrl_file   = "{$include_gen_dir}game_db.hrl";
    $game_db_data       = "game_db_data";
    $game_db_data_file  = "{$src_gen_dir}{$game_db_data}.erl";
    $game_db_init       = "game_db_init";
    $game_db_init_file  = "{$src_gen_dir}{$game_db_init}.erl";
    $game_db_sync       = "game_db_sync";
    $game_db_sync_file  = "{$src_gen_dir}{$game_db_sync}.erl";
    $game_db_table      = "game_db_table";
    $game_db_table_file = "{$src_gen_dir}{$game_db_table}.erl";
    $game_db_dump       = "game_db_dump";
    $game_db_dump_file  = "{$src_gen_dir}{$game_db_dump}.erl";

    // 生成新的数据库连接对象
    $mysqli = new mysqli($db_host, $db_user, $db_pass, $db_name, $db_port);
    if ($mysqli->connect_error) {
        die("Open '$db_name' failed (".$mysqli->connect_errno.".) ".$mysqli->connect_error.".\n");
    }
    $mysqli->query("SET NAMES utf8;");

    $schema = new mysqli($db_host, $db_user, $db_pass, 'information_schema', $db_port);
    if ($schema->connect_error) {
        die("Open 'information_schema' failed (".$schema->connect_errno.".) ".$schema->connect_error.".\n");
    }
    $schema->query("SET NAMES utf8;");
    $tables_info        = get_tables_info();
    $tables_fields_info = get_tables_fields_info();
    $table_name_len_max = $tables_info['NAME_LEN_MAX'];

        print_r($tables_info);
        print_r($tables_fields_info);

    db_enum();
    db_record();
    game_db_data();
    game_db_dump();
    game_db_init();
    game_db_sync();
    game_db_table();

    // 关闭数据库连接
    $mysqli->close();
    $schema->close();



// =========== ======================================== ====================
// @todo   获取表数据
function get_table_data ($mysqli, $table_name, $fields) {
    $fields_arr = implode("`, `", $fields);
    $select_sql = "SELECT `{$fields_arr}` FROM `{$table_name}`;";
    // echo $select_sql;
    $result     = $mysqli->query($select_sql, MYSQLI_USE_RESULT);
    
    $table_data = array();
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $values = array();
    
        foreach ($fields as $field) {
            $values[$field] = $mysqli->real_escape_string($row[$field]);
        }
        
        $table_data[] = $values;
    }

    $result->close();
    return $table_data;
}


// @todo   获取对应数据库的所有表
function get_tables_info () {
    global $schema, $db_name;
    
    $sql            = "SELECT `TABLE_NAME` FROM `TABLES` WHERE `TABLE_SCHEMA` = '{$db_name}';";
    $result         = $schema->query($sql);
    $tables_info    = array();
    $name_len       = 0;
    
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $table_name              = $row['TABLE_NAME'];
        // 过滤掉不需要的表
        if ($table_name == "db_version") {
            // continue;
        }
        $tables_info['TABLES'][] = $table_name;
        $name_len                = max($name_len, strlen($table_name));
    }
    $tables_info['NAME_LEN_MAX'] = $name_len;
    
    $result->close();
    
    return $tables_info;
}

// @todo   获取所有表字段信息
function get_tables_fields_info () {
    global $tables_info;
    $tables_fields_info = array();
    foreach ($tables_info['TABLES'] as $table_name) {
        $fields = get_table_fields_info($table_name);
        $tables_fields_info[$table_name] = $fields;
    }
    return $tables_fields_info;
}

// @todo   获取表字段信息
function get_table_fields_info ($table_name) {
    global $schema, $db_name;
    
    $sql        = "SELECT 
            `COLUMN_NAME`, `COLUMN_KEY`, `DATA_TYPE`, `EXTRA`, `COLUMN_DEFAULT`, `IS_NULLABLE`, `COLUMN_COMMENT`
        FROM  `COLUMNS`
        WHERE `TABLE_SCHEMA` = '$db_name' AND `TABLE_NAME` = '$table_name'";
    $result     = $schema->query($sql);
    $fields_info= array();
    $name_len   = 0;
    $primary    = array();
    $auto_increment     = "";
    $frag_field    = "";
    
    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $field_name             = $row['COLUMN_NAME'];
        $field_key              = $row['COLUMN_KEY'];
        $field_extra            = $row['EXTRA'];
        $name_len               = max($name_len, strlen($field_name));
        if ($field_key == "PRI") {
            $primary[]  = $field_name;
        }
        if ($field_extra == "auto_increment") {
            $auto_increment     = $field_name;
        }
        if ($field_name == "player_id") {
            $frag_field = $field_name;
        }
        $fields_info['FIELDS'][$field_name] = $row;
    }
    $player_start   = "player";
    if (substr_compare($table_name, $player_start, 0, strlen($player_start)) === 0) {
        $is_temp_table  = false;
        $log_end        = "_log";
        if (substr_compare($table_name, $log_end, -strlen($log_end)) === 0) {
            $is_log_table   = true;
        } 
        else {
            $is_log_table   = false;
        }
    }
    else {
        $is_temp_table  = true;
        $is_log_table   = false;
    }
    $fields_info['NAME_LEN_MAX']    = $name_len;
    $fields_info['PRIMARY']         = $primary;
    $fields_info['AUTO_INCREMENT']  = $auto_increment;
    $fields_info['FRAG_FIELD']      = $frag_field;
    $fields_info['IS_TEMP_TABLE']   = $is_temp_table;
    $fields_info['IS_LOG_TABLE']    = $is_log_table;
    
    $result->close();
    return $fields_info;
}
?>