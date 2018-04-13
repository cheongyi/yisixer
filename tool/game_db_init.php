<?php
// =========== ======================================== ====================
// @todo   游戏数据库初始化
function game_db_init () {
    global $tables_info, $game_db_init, $game_db_init_file, $tables_fields_info;

    $file       = fopen($game_db_init_file, 'w');

    fwrite($file, "-module ($game_db_init).");
    write_attributes($file);
    // ets:new(t_$table_name, [public, set, named_table, {keypos, 2}, compressed]),
    fwrite($file, "
-export ([init/0, init/1, load/1]).

-include (\"define.hrl\").
-include (\"gen/game_db.hrl\").

-define (CUT_LINE, 
    \"-------------+---------------------------------------------------+----------~n\"
).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
");

    // 写入init/0函数
    $tables = $tables_info['TABLES'];
    fwrite($file, "init () ->
    cut_line(),
    [
        begin
            cut_line(),
            init(TableName)
        end
        ||
        TableName <- case ?GET_ENV_ATOM(build_code_db, false) of
            true  -> game_db_table:get_all_table();
            false -> game_db_table:get_all_player_table()
        end
    ],
    cut_line(),
    cut_line().
");

    // 写入init/1函数
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $fields         = $fields_info['FIELDS'];
        $frag_field     = $fields_info['FRAG_FIELD'];
        $is_log_table   = $fields_info['IS_LOG_TABLE'];
        if ($is_log_table) {
        }

        $dots = generate_char(50, strlen($table_name), ' ');
        fwrite($file, "
init ($table_name) ->
    ?FORMAT(\"game_db init : $table_name{$dots}| start~n\"),
");

        // 判断是否自增长
        foreach ($fields as $field) {
            $field_extra    = $field['EXTRA'];
            if ($field_extra == "auto_increment") {
                $field_name = $field['COLUMN_NAME'];
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
        if ($is_log_table) {
            $init_end = "ok;";
        } 
        else {
            // 判断是否建立ets分表
            if ($frag_field) {
        fwrite($file, "
    [
        ets:new(
            game_db_table:ets_tab({$table_name}, FragId), 
            [public, set, named_table, {keypos, 2}]
        ) 
        || 
        FragId <- ?FRAG_ID_LIST
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
        $fields_info    = $tables_fields_info[$table_name];
        $fields         = $fields_info['FIELDS'];
        $is_log_table   = $fields_info['IS_LOG_TABLE'];
        $frag_field     = $fields_info['FRAG_FIELD'];
        $name_len_max   = $fields_info['NAME_LEN_MAX'];
        $keyfind        = "";
        $record         = "";
        $primary        = array();
        if ($is_log_table) {
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

    RowsBin = integer_to_binary(?SELECT_LIMIT_ROWS),
    lists:foreach(
        fun(Page) ->
            RowsStartBin     = integer_to_binary((Page - 1) * ?SELECT_LIMIT_ROWS),
            {data, ResultId} = game_mysql:fetch(
                gamedb, 
                [<<\"SELECT * FROM `$table_name` LIMIT \", RowsStartBin/binary, \", \", RowsBin/binary>>]
            ),
            Rows = lib_mysql:get_rows(ResultId),
            
            lists:foreach(
                fun(Row) ->");
        foreach ($fields as $field) {
            $field_name     = $field['COLUMN_NAME'];
            $field_key      = $field['COLUMN_KEY'];
            $field_name_up  = ucfirst($field_name);
            if ($field_key == "PRI") {
                $primary[] = $field_name_up;
            }
            $dots = generate_char($name_len_max, strlen($field_name), ' ');
            $keyfind    = $keyfind."
                    {{$field_name}, {$dots}{$field_name_up}}{$dots} = lists:keyfind({$field_name},{$dots}1, Row),";
            $record     = $record."
                        {$field_name}{$dots} = {$field_name_up},";
        }
        $primary_arr = implode(", ", $primary);
        fwrite($file, "{$keyfind}

                    Record = #$table_name {
                        row_key = {{$primary_arr}},{$record}
                        row_ver = 0
                    },");
        if ($frag_field) {
            fwrite($file, "
                    EtsTab = game_db_table:ets_tab({$table_name}, Record #{$table_name}.{$frag_field} rem 100),");
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
        lists:seq(1, ceil(RecordNumber / ?SELECT_LIMIT_ROWS))
    ),
    ?FORMAT(\"game_db init : $table_name{$dots}| finished~n\");
");
    }

    // 写入load通配分支函数
    fwrite($file, "
load (_) ->
    ok.

cut_line () ->
    ?FORMAT(?CUT_LINE).

");

    fclose($file);
}
?>