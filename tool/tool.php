<?php
    // 加载配置文件
    require_once 'conf.php';

    // 设定用于所有日期时间函数的默认时区
    date_default_timezone_set("Asia/Shanghai");

    // 数据库配置
    $db_sign = 'localhost';
    $db_host = '127.0.0.1';
    $db_user = 'root';
    $db_pass = 'ybybyb';
    $db_name = 'yisixer';
    $db_port = 3306;
    // $db_host = $db_argv[$db_sign]['host'];
    // $db_user = $db_argv[$db_sign]['user'];
    // $db_pass = $db_argv[$db_sign]['pass'];
    // $db_name = $db_argv[$db_sign]['name'];
    // $db_port = $db_argv[$db_sign]['port'];

    // 目录路径
    $server_dir         = "../server/";
    $include_gen_dir    = $server_dir."include/gen/";
    $src_gen_dir        = $server_dir."src/gen/";

    // 文件名称
    $game_db_hrl_file   = $include_gen_dir."game_db.hrl";
    $game_db_init_fname = "game_db_init";
    $game_db_init_file  = $src_gen_dir.$game_db_init_fname.".erl";

    // 生成新的数据库连接对象
    $mysqli = new mysqli($db_host, $db_user, $db_pass, $db_name, $db_port);
    if ($mysqli->connect_error) {
        die("Open '".$db_name."' failed (" . $mysqli->connect_errno . ") " . $mysqli->connect_error."\n");
    }
    $mysqli->query("SET NAMES utf8;");

    $schema = new mysqli($db_host, $db_user, $db_pass, 'information_schema', $db_port);
    if ($schema->connect_error) {
        die("Open 'information_schema' failed (" . $schema->connect_errno . ") " . $schema->connect_error."\n");
    }
    $tables     = get_tables();
        print_r($tables);

    db_enum();
    db_record();
    game_db_init();

    // 关闭数据库连接
    $mysqli->close();
    $schema->close();

// =========== ======================================== ====================
// 数据库枚举
function db_enum() {
    global $mysqli, $enum_table, $game_db_hrl_file;

    $main_stime = microtime(true);

    $file       = fopen($game_db_hrl_file, 'w');

// -date       ({".date("Y, m, d")."}).
// -copyright  (\"Copyright © ".date("Y")." YiSiXEr\").
// -copyright  (\"Copyright © 2018 YiSiXEr\").
// -date       ({2018, 04, 08}).
    fwrite($file, "
-copyright  (\"Copyright © 2017-".date("Y")." YiSiXEr\").
-author     (\"CHEONGYI\").
-date       ({".date("Y, m, d")."}).

%%% ========== ======================================== ====================
%%% database table rows to define
%%% ========== ======================================== ====================
");
    foreach ($enum_table as $table) {
        $fields     = array();
        $fields[]   = $table['id'];
        $fields[]   = $table['sign'];
        $fields[]   = $table['cname'];
        $table_name = $table['tname'];
        $table_note = $table['note'];
        fwrite($file, "%%% ".$table_name."\n");
        $table_data = get_table_data($mysqli, $table_name, $fields);
        foreach ($table_data as $row) {
            $dots = generate_char(50, strlen($row[$table['sign']].$row[$table['id']]), ' ');
            fwrite($file, "-define("
                .$table['prefix'].strtoupper($row[$table['sign']])
                .",".$dots
                .$row[$table['id']]
                .").    %% ".$table_note." - ".$row[$table['cname']]
                ."\n");
        }
        fwrite($file, "\n");
    }

    fclose($file);
}


// 数据库记录
function db_record () {
    global $mysqli, $tables, $game_db_hrl_file;

    $file       = fopen($game_db_hrl_file, 'a');

    fwrite($file, "
%%% ========== ======================================== ====================
%%% database table create to record
%%% ========== ======================================== ====================
");

    foreach ($tables as $table_name) {
        $fields = get_table_fields_info($table_name);
        fwrite($file, "-record(".$table_name.", {
    row_key,");
        foreach ($fields as $field) {
            $field_name     = $field['COLUMN_NAME'];
            $field_type     = $field['DATA_TYPE'];
            $field_default  = $field['COLUMN_DEFAULT'];
            $field_comment  = $field['COLUMN_COMMENT'];
            $dots = generate_char(20, strlen($field_name), ' ');
            fwrite($file, "
    ".$field_name.$dots);
            $field_default_len = strlen($field_default);
            if ($field_default == "NULL" || $field_default == "") {
                $field_default_len = 4;
                fwrite($file, "= null");
            }
            elseif ($field_type == "tinyint" || $field_type == "int" || $field_type == "bigint" || $field_type == "float") {
                fwrite($file, "= ".$field_default);
            }
            elseif ($field_type == "float") {
                fwrite($file, "= ".$field_default);
            }
            else {
                fwrite($file, "= \"".$field_default."\"");
            }
            $dots = generate_char(10, $field_default_len, ' ');
            fwrite($file, ",".$dots."%% ".$field_comment);
        }
        fwrite($file, "
    row_ver             = 0
}).\n\n");
        print_r($fields);
    }

    fclose($file);
}


// @todo   游戏数据库初始化
function game_db_init () {
    global $mysqli, $tables, $game_db_init_fname, $game_db_init_file;
    
    $file       = fopen($game_db_init_file, 'w');
    
    fwrite($file, "-module (".$game_db_init_fname.").");
    write_attributes($file);
    fwrite($file, "
-export ([init/1,   load/1]).

-include (\"define.hrl\").
-include (\"record.hrl\").
-include (\"gen/game_db.hrl\").


%%% ========== ======================================== ====================
");
    
    fclose($file);
}



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
    
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $tables[] = $row['TABLE_NAME'];
    }
    
    $result->close();
    
    return $tables;
}

function get_table_fields_info ($table_name) {
    global $schema, $db_name;
    
    $sql    = "SELECT 
            `COLUMN_NAME`, `COLUMN_KEY`, `DATA_TYPE`, `EXTRA`, `COLUMN_DEFAULT`, `IS_NULLABLE`, `COLUMN_COMMENT`
        FROM  `COLUMNS`
        WHERE `TABLE_SCHEMA` = '".$db_name."' AND TABLE_NAME = '".$table_name."'";
    $result = $schema->query($sql);
    $fields = array();
    
    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $fields[]   = $row;
    }
    
    $result->close();
    
    return $fields;
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



// =========== ======================================== ====================
// @todo   生成填补字符
function generate_char ($max_length, $length, $char) {
    $space      = "";
    $fill_len   = $max_length - $length;
    for ($i = 0; $i < $fill_len; $i ++) {
        $space .= $char;
    }
     
    return $space;
}


// @todo    写入属性
function write_attributes($file) {
    fwrite($file, "

%%% @doc    

-copyright  (\"Copyright © 2017-".date("Y")." YiSiXEr\").
-author     (\"CHEONGYI\").
-date       ({".date("Y, m, d")."}).
-vsn        (\"1.0.0\").
");
}
?>