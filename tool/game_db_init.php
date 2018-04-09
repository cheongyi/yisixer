<?php
// =========== ======================================== ====================
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
?>