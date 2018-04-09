<?php
    // 加载配置文件
    require_once 'conf.php';

    // 设定用于所有日期时间函数的默认时区
    date_default_timezone_set("Asia/Shanghai");

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
// 数据库枚举
function db_enum() {
    global $mysqli, $enum_table, $game_db_hrl_file;

    $main_stime = microtime(true);

    $file       = fopen($game_db_hrl_file, 'w');

// -date       ({".date("Y, m, d")."}).
// -copyright  (\"Copyright © ".date("Y")." YiSiXEr\").
// -copyright  (\"Copyright © 2018 YiSiXEr\").
// -date       ({2018, 04, 08}).
    $year   = date("Y");
    $ymd    = date("Y, m, d");
    fwrite($file, "
-copyright  (\"Copyright © 2017-$year YiSiXEr\").
-author     (\"CHEONGYI\").
-date       ({{$ymd}}).

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
        fwrite($file, "%%% $table_name\n");
        $table_data = get_table_data($mysqli, $table_name, $fields);
        foreach ($table_data as $row) {
            $dots = generate_char(50, strlen($row[$table['sign']].$row[$table['id']]), ' ');
            fwrite($file, "-define("
                .$table['prefix'].strtoupper($row[$table['sign']])
                .",$dots"
                .$row[$table['id']]
                .").    %% $table_note - ".$row[$table['cname']]
                ."\n");
        }
        fwrite($file, "\n");
    }

    fclose($file);
}


// 数据库记录
function db_record () {
    global $mysqli, $tables, $tables_fields, $game_db_hrl_file;

    $file       = fopen($game_db_hrl_file, 'a');

    fwrite($file, "
%%% ========== ======================================== ====================
%%% database table create to record
%%% ========== ======================================== ====================
");

    foreach ($tables as $table_name) {
        $fields = $tables_fields[$table_name];
        fwrite($file, "-record($table_name, {
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
                fwrite($file, "= $field_default");
            }
            elseif ($field_type == "float") {
                fwrite($file, "= $field_default");
            }
            else {
                fwrite($file, "= \"$field_default\"");
            }
            $dots = generate_char(10, $field_default_len, ' ');
            fwrite($file, ",$dots%% $field_comment");
        }
        fwrite($file, "
    row_ver             = 0
}).\n\n");
    }

    fclose($file);
}


// @todo   游戏数据库初始化
function game_db_init () {
    global $mysqli, $tables, $game_db_init, $game_db_init_file, $tables_fields;

    $file       = fopen($game_db_init_file, 'w');

    fwrite($file, "-module ($game_db_init).");
    write_attributes($file);
    // ets:new(t_$table_name, [public, set, named_table, {keypos, 2}, compressed]),
    fwrite($file, "
-export ([init/0, init/1, load/1]).

-include (\"define.hrl\").
-include (\"record.hrl\").
-include (\"gen/game_db.hrl\").

-define (CUT_LINE, 
    \"-------------+---------------------------------------------------+----------~n\"
).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
");

    // 写入init/0函数
    fwrite($file, "init () ->
    [
        begin
            cut_line(),
            init(TableName)
        end
        ||
        TableName <- [
            ");
    fwrite($file, implode(",
            ", $tables));
    fwrite($file, "
        ]
    ],
    cut_line().
");

    // 写入init/1函数
    foreach ($tables as $table_name) {
        $dots = generate_char(50, strlen($table_name), ' ');
        fwrite($file, "
init ($table_name) ->
    ?FORMAT(\"game_db init : $table_name{$dots}|");
        if ($table_name == "db_version") {
        fwrite($file, " ignore~n\", []),
    ok;
");
            continue;
        }

        // 写入init开头
        fwrite($file, " start~n\", []),
");

        // 判断是否自增长
        $fields = $tables_fields[$table_name];
        foreach ($fields as $field) {
            $field_extra      = $field['EXTRA'];
            if ($field_extra == "auto_increment") {
                $field_name   = $field['COLUMN_NAME'];
                fwrite($file, "
    {data, AutoIncResultId} = game_mysql:fetch(
        gamedb, 
        [<<\"SELECT IFNULL(MAX(`$field_name`), 0) AS `max_id` FROM `$table_name`;\">>]
    ),
    [AutoIncResult] = lib_mysql:get_rows(AutoIncResultId),
    {max_id, AutoIncStart} = lists:keyfind(max_id, 1, AutoIncResult),
    true = ets:insert_new(auto_increment, {{{$table_name}, id}, AutoIncStart}),
");
            }
        }

        // 写入init结尾
        $log_end    = "_log";
        if (substr_compare($table_name, $log_end, -strlen($log_end)) === 0) {
            $init_end = "ok;";
        } 
        else {
            // 判断是否建立ets分表
            $player_start    = "player_";
            echo $table_name.substr_compare($table_name, $player_start, 0, strlen($player_start))."\n";
            if (substr_compare($table_name, $player_start, 0, strlen($player_start)) === 0) {
        fwrite($file, "
    [
        ets:new(
            list_to_atom(\"$table_name\" ++ integer_to_list(I)), 
            [public, set, named_table, {keypos, 2}]
        ) 
        || 
        I <- lists:seq(0, 99)
    ],");
            } 
            else {
                fwrite($file, "
    ets:new(t_$table_name, [public, set, named_table, {keypos, 2}]),");
            }

            $init_end = "load($table_name);";
        }
        fwrite($file, "
    $init_end
");
    }

    // 写入init通配分支函数
    fwrite($file, "
init (_) ->
    ok.

");

    // 写入load/0函数
    foreach ($tables as $table_name) {
        if ($table_name == "db_version") {
            continue;
        }

        // 写入load开头
        fwrite($file, "
load ($table_name) ->
    {data, NumResultId} = game_mysql:fetch(
        gamedb, 
        [<<\"SELECT count(1) AS num FROM `$table_name`\">>]
    ),
    {num, RecordNumber} = lists:keyfind(num, 1, hd(lib_mysql:get_rows(NumResultId))),

    lists:foreach(
        fun(Page) ->
            Sql  = \"SELECT * FROM `$table_name` LIMIT \" 
                ++  integer_to_list((Page - 1) * 500000) ++ \", 500000\",
            {data, ResultId} = game_mysql:fetch(gamedb, [list_to_binary(Sql)]),
            Rows = lib_mysql:get_rows(ResultId),
            
            lists:foreach(
                fun(Row) ->");
        $fields     = $tables_fields[$table_name];
        $keyfind    = "";
        $record     = "";
        $is_rem_tab = false;
        $primary    = array();
        foreach ($fields as $field) {
            $field_name     = $field['COLUMN_NAME'];
            $field_key      = $field['COLUMN_KEY'];
            $field_nameF    = ucfirst($field_name);
            if ($field_key == "PRI") {
                $primary[] = $field_nameF;
            }
            if ($field_name == "player_id") {
                $is_rem_tab = true;
            }
            $dots = generate_char($field['FIELD_NAME_LEN'], strlen($field_name), ' ');
            $keyfind    = $keyfind."
                    {{$field_name}, {$dots}{$field_nameF}}{$dots} = lists:keyfind({$field_name},{$dots}1, Row),";
            $record     = $record."
                        {$field_name}{$dots} = {$field_nameF},";
        }
        $primary_arr = implode(", ", $primary);
        fwrite($file, "{$keyfind}

                    Record = #$table_name {
                        row_key = {{$primary_arr}},{$record}
                        row_ver = 0
                    },");
        if ($is_rem_tab) {
            fwrite($file, "
                    TabId  = integer_to_list((Record #$table_name.player_id) rem 100),
                    EtsTab = list_to_atom(\"t_{$table_name}_\" ++ TabId),");
        }
        else {
            fwrite($file, "
                    EtsTab = t_$table_name,");
        }
        $dots = generate_char(50, strlen($table_name), ' ');
        fwrite($file, "
                    ets:insert(EtsTab, Record)
                end,
                Rows
            )
        end,
        lists:seq(1, ceil(RecordNumber / 500000))
    ),
    ?FORMAT(\"game_db init : $table_name{$dots}| finished~n\", []);
");
    }

    // 写入load通配分支函数
    fwrite($file, "
load (_) ->
    ok.

cut_line () ->
    ?FORMAT(?CUT_LINE, []).

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
    $name_len   = 0;
    
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $tables[]   = $row['TABLE_NAME'];
        $name_len   = max($name_len, strlen($row['COLUMN_NAME']));
    }
    
    $result->close();
    
    return $tables;
}

// @todo   获取制定数据库的表字段
function get_db_table_fields ($db, $table_name, $sql) {
    
    return $fieldsLen;
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
    $year   = date("Y");
    $ymd    = date("Y, m, d");
    fwrite($file, "

%%% @doc    

-copyright  (\"Copyright © 2017-$year YiSiXEr\").
-author     (\"CHEONGYI\").
-date       ({{$ymd}}).
-vsn        (\"1.0.0\").
");
}
?>