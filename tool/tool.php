<?php
    // 加载配置文件
    require_once 'conf.php';

    // 设定用于所有日期时间函数的默认时区
    date_default_timezone_set("Asia/Shanghai");

    // 数据库配置
    $db_sign = 'localhost';
    $db_host = '127.0.0.1';
    $db_user = 'root';
    $db_pass = 'wlwlwl';
    $db_name = 'yisixer';
    $db_port = 3306;
    // $db_host = $db_argv[$db_sign]['host'];
    // $db_user = $db_argv[$db_sign]['user'];
    // $db_pass = $db_argv[$db_sign]['pass'];
    // $db_name = $db_argv[$db_sign]['name'];
    // $db_port = $db_argv[$db_sign]['port'];

    // 目录路径
    $server_dir         = "server/";
    $include_gen_dir    = $server_dir."include/gen/";

    // 文件名称
    $game_db_file       = $include_gen_dir."game_db.hrl";

    // 生成新的数据库连接对象
    $mysqli = new mysqli($db_host, $db_user, $db_pass, $db_name, $db_port);
    $mysqli->query("SET NAMES utf8;");

    db_enum();

    // 关闭数据库连接
    $mysqli->close();

// 数据库枚举
function db_enum() {
    global $mysqli, $enum_table, $game_db_file;

    $main_stime = microtime(true);

    $file       = fopen($game_db_file, 'c');

    foreach ($enum_table as $table) {
        print_r($table);
    }
    fclose($file);

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
?>