<?php
// =========== ======================================== ====================
// @todo   游戏数据库表
function game_db_dump () {
    global $tables_info, $tables_fields_info, $table_name_len_max, $PF_DB_WRITE_SCH;

    show_schedule(PF_DB_WRITE, $PF_DB_WRITE_SCH, count($PF_DB_WRITE_SCH), true);
    $file       = fopen(GAME_DB_DUMP_FILE, 'w');
    $tables     = $tables_info['TABLES'];
    fwrite($file, '-module ('.GAME_DB_DUMP.').');
    write_attributes($file);
    // 写入系统属性
    fwrite($file, '
-export ([
    run/0,
    backup/0
]).

-include ("define.hrl").
-include ("gen/game_db.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
run () ->
    supervisor:terminate_child(game, socket_server_sup),
    mod_online:wait_all_online_player_exit(?KICKOUT_PLAYER_TIMEOUT),
    FileName    = "./game_db.sql",');

    // 写入 run/0 剩余
    write_dump_table_to_file($file, $tables, $tables_fields_info);



    // 写入 backup/0 开头
    fwrite($file, '


%%% ========== ======================================== ====================
backup () ->
    FileName    = "./game_db_backup.sql",');

    // 写入 backup/0 剩余
    write_dump_table_to_file($file, $tables, $tables_fields_info);



    // 写入内部函数
    fwrite($file, '



%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================');

    foreach ($tables as $table_name) {
        $fields_info        = $tables_fields_info[$table_name];
        $is_temp_table      = $fields_info['IS_TEMP_TABLE'];
        $is_log_table       = $fields_info['IS_LOG_TABLE'];
        $table_name_len_max = $tables_info['NAME_LEN_MAX'];
        if ($is_temp_table || $is_log_table) {
            continue;
        }

        $dots = generate_char($table_name_len_max, strlen($table_name), '.');
        fwrite($file, "
dump_{$table_name} (File) ->
    ?FORMAT(\"dump {$table_name} ...{$dots} \"),
    Size = game_db_data:count({$table_name}),
    if
        Size > ?DELETE_OR_TRUNCATE_ROWS -> file:write(File, <<   \"\\nTRUNCATE `{$table_name}`;\\n\\n\">>);
        true                            -> file:write(File, <<\"\\nDELETE FROM `{$table_name}`;\\n\\n\">>)
    end,");

        // 分表判断
        $frag_field     = $fields_info['FRAG_FIELD'];
        if ($frag_field) {
            fwrite($file, '
    lists:foldl(fun(FragId, {FragSum, FragNumber, FragL})->
        ets:foldl(fun(Record, {Sum, Number, L}) ->
');
        }
        else {
            fwrite($file, '
    ets:foldl(fun(Record, {Sum, Number, L}) ->
');
        }

        $fields         = $fields_info['FIELDS'];
        $name_len_max   = $fields_info['NAME_LEN_MAX'];
        foreach ($fields as $field) {
            write_type_to_bin($file, $table_name, $field, $name_len_max);
        }
        fwrite($file, "
    Value   = <<\"(\",");

        $insert_arr = array();
        $value_arr  = array();
        foreach ($fields as $field) {
            $field_name     = $field['COLUMN_NAME'];
            $field_name_up  = ucfirst($field_name);
            $dots = generate_char($name_len_max, strlen($field_name), ' ');
            $insert_arr[]   = $field_name;
            $value_arr[]    = $dots.$field_name_up.'/binary, ';
        }

        $insert_arr = implode('`, `', $insert_arr);
        $value_arr  = implode("\", \",
        ", $value_arr);
        fwrite($file, "
        {$value_arr}
    \")\">>,
    if 
        Number == ?INSERT_BATCH_ROWS orelse Sum == Size -> 
            ok = file:write(File, <<\"INSERT IGNORE INTO `{$table_name}` (`{$insert_arr}`) VALUES \\n\">>),
            ok = file:write(File, L),
            ok = file:write(File, <<Value/binary, \";\\n\">>),
            {Sum + 1, 1, []};
        true ->
            {Sum + 1, Number + 1, [<<Value/binary, \",\\n\">> | L]}
    end
");

        // 分表判断
        $frag_field     = $fields_info['FRAG_FIELD'];
        if ($frag_field) {
        fwrite($file, "
            end,    % ets:foldl
            {FragSum, FragNumber, FragL}, 
            ?ETS_TAB({$table_name}, FragId)
        )
        end,    % lists:foldl
        {1, 1, []}, 
        ?FRAG_ID_LIST
    ),
");
        }
        else {
        fwrite($file, "
        end,    % ets:foldl
        {1, 1, []}, 
        t_{$table_name}
    ),
");
        }

        fwrite($file, "
    ok = file:write(File, <<\"\\n\">>),
    ?FORMAT(\"done    size(~p)~n\", [Size]).

");
    }




    fwrite($file, "
%%% ========== ======================================== ====================
%%% @doc    获取日志文件
get_sql_file (FileName) ->
    case filelib:is_file(FileName) of
        true  -> ok;
        false -> ok = filelib:ensure_dir(FileName)
    end,
    {ok, File} = file:open(FileName, [write, raw]),
    ok = file:write(File, <<\"/*!40101 SET NAMES utf8 */;\\n\">>),
    ok = file:write(File, <<\"/*!40101 SET SQL_MODE=''*/;\\n\">>),
    ok = file:write(File, <<\"/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;\\n\">>),
    ok = file:write(File, <<\"/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;\\n\">>),
    ok = file:write(File, <<\"/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;\\n\">>),
    ok = file:write(File, <<\"/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;\\n\\n\">>),
    File.
    ");

    fclose($file);
}


// @todo   写入表到文件
function write_dump_table_to_file ($file, $tables, $tables_fields_info) {
    fwrite($file, '
    File        = get_sql_file(FileName),
');

    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $is_temp_table  = $fields_info['IS_TEMP_TABLE'];
        $is_log_table   = $fields_info['IS_LOG_TABLE'];
        if ($is_temp_table || $is_log_table) {
            continue;
        }
        fwrite($file, "
    dump_{$table_name}(File),");
    }

    fwrite($file, '

    ok = file:close(File).');
}

?>