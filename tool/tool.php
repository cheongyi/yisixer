<?php
    // 设定用于所有日期时间函数的默认时区
    date_default_timezone_set("Asia/Shanghai");

    // 加载配置文件
    require_once 'conf.php';
    require_once 'lib_misc.php';
    require_once 'game_db_hrl.php';
    require_once 'game_db_init.php';

    // 数据库配置
    $db_sign = 'localhost';
    if ($argc > 0) {
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
    $game_db_init       = "game_db_init";
    $game_db_init_file  = "{$src_gen_dir}{$game_db_init}.erl";

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
    $tables         = get_tables();
    $tables_fields  = get_all_table_fields($table_name);
    $table_name_len = 0;
    foreach ($tables as $table_name) {
        $table_name_len = max($table_name_len, strlen($table_name));
    }
        print_r($tables);
        print_r($tables_fields);

    db_enum();
    db_record();
    game_db_init();

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
function get_tables () {
    global $schema, $db_name;
    
    $sql    = "SELECT `TABLE_NAME` FROM `TABLES` WHERE `TABLE_SCHEMA` = '{$db_name}';";
    $result = $schema->query($sql);
    $tables = array();
    $name_len   = 0;
    
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $tables[]   = $row['TABLE_NAME'];
        $name_len   = max($name_len, strlen($row['COLUMN_NAME']));
    }
    
    $result->close();
    
    return $tables;
}

// @todo   获取所有表字段信息
function get_all_table_fields () {
    global $tables;
    $tables_fields  = array();
    foreach ($tables as $table_name) {
        $fields = get_table_fields($table_name);
        $tables_fields[$table_name] = $fields;
    }
    return $tables_fields;
}

// @todo   获取表字段信息
function get_table_fields ($table_name) {
    global $schema, $db_name;
    
    $sql    = "SELECT 
            `COLUMN_NAME`, `COLUMN_KEY`, `DATA_TYPE`, `EXTRA`, `COLUMN_DEFAULT`, `IS_NULLABLE`, `COLUMN_COMMENT`
        FROM  `COLUMNS`
        WHERE `TABLE_SCHEMA` = '$db_name' AND `TABLE_NAME` = '$table_name'";
    $result     = $schema->query($sql);
    $fields     = array();
    $name_len   = 0;
    
    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $fields[]   = $row;
        $name_len   = max($name_len, strlen($row['COLUMN_NAME']));
    }
    $fieldsLen      = array();
    foreach ($fields as $field) {
        $field['FIELD_NAME_LEN'] = $name_len;
        $fieldsLen[]             = $field;
    }
    
    $result->close();
    return $fieldsLen;
}
?>