<?php
// =========== ======================================== ====================
// @todo   游戏数据库表
function game_db_sync () {
    global $tables_info, $tables_fields_info, $table_name_len_max;

    show_schedule(PF_DB_WRITE, PF_DB_WRITE_SCH, count(PF_DB_WRITE_SCH), true);
    $tables     = $tables_info['TABLES'];

    $file       = fopen(GAME_DB_SYNC_FILE, 'w');

    fwrite($file, '-module ('.GAME_DB_SYNC.').');
    write_attributes($file);
    // 写入系统属性
    fwrite($file, "
-export ([
    tran_action_to_sql/1
]).

-include (\"define.hrl\").
-include (\"gen/game_db.hrl\").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================");



    // 写入 tran_action_to_sql/1 函数
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $fields         = $fields_info['FIELDS'];
        $is_log_table   = $fields_info['IS_LOG_TABLE'];
        $name_len_max   = $fields_info['NAME_LEN_MAX'];
        $primary        = $fields_info['PRIMARY'];
        // $is_temp_table  = $fields_info['IS_TEMP_TABLE'];
        // if ($is_temp_table) {
        //     continue;
        // }

        // 写入 insert 分支
        fwrite($file, "
tran_action_to_sql ({{$table_name}, insert, Record}) ->");

        foreach ($fields as $field) {
            write_type_to_bin($file, $table_name, $field, $name_len_max);
        }

        fwrite($file, "
    <<
        \"INSERT IGNORE INTO `{$table_name}` SET \"");

        $insert_arr = array();
        foreach ($fields as $field) {
            $field_name     = $field['COLUMN_NAME'];
            $field_name_up  = ucfirst($field_name);
            $dots = generate_char($name_len_max, strlen($field_name), ' ');
            $insert_arr[]   = "
            {$dots}\"`{$field_name}` = \", {$dots}{$field_name_up}/binary, ";
        }

        $insert_arr = implode("\", \"", $insert_arr);
        fwrite($file, "{$insert_arr}\";\\n\"
    >>;");

        // 玩家日志表只有insert new
        if ($is_log_table) {
            continue;
        }

        // 写入 delete 分支
        fwrite($file, "
tran_action_to_sql ({{$table_name}, delete, Record}) ->");

        foreach ($fields as $field) {
            $field_key      = $field['COLUMN_KEY'];
            if ($field_key == "") {
                continue;
            }
            write_type_to_bin($file, $table_name, $field, $name_len_max);
        }

        fwrite($file, "
    <<
        \"DELETE FROM `{$table_name}` WHERE \"");

        $insert_arr = array();
        foreach ($primary as $field_name) {
            $field_name_up  = ucfirst($field_name);
            $dots = generate_char($name_len_max, strlen($field_name), ' ');
            $insert_arr[]   = "
            {$dots}\"`{$field_name}` = \", {$dots}{$field_name_up}/binary, ";
            $comma  = ", ";
        }

        $insert_arr = implode("\" AND \"", $insert_arr);
        fwrite($file, "{$insert_arr}\";\\n\"
    >>;
tran_action_to_sql ({{$table_name}, update, _Record, []})      -> none;
tran_action_to_sql ({{$table_name}, update,  Record, Changes}) ->
    Sql     = generate_update_sql({$table_name}, Record, <<\" \">>, Changes, []),
    BinSql  = list_to_binary(lists:reverse(Sql)),
    <<\"UPDATE `{$table_name}` SET\", BinSql/binary>>;
");
    }

    // 写入 tran_action_to_sql/1 通配分支函数
    fwrite($file, "
tran_action_to_sql ({_Table, bin_sql, BinSql}) ->
    BinSql.

");



    // 写入内部函数
    fwrite($file, "
%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    generate_update_sql");

    // 写入 generate_update_sql/5 函数
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $is_log_table   = $fields_info['IS_LOG_TABLE'];
        // $is_temp_table  = $fields_info['IS_TEMP_TABLE'];
        // if ($is_log_table || $is_temp_table) {
        if ($is_log_table) {
            continue;
        }
        $fields         = $fields_info['FIELDS'];
        $name_len_max   = $fields_info['NAME_LEN_MAX'];

        $index  = 3;
        foreach ($fields as $field) {
            $field_key      = $field['COLUMN_KEY'];
            if ($field_key == "PRI") {
                $index ++;
                continue;
            }
            $field_name     = $field['COLUMN_NAME'];
            $field_name_up  = ucfirst($field_name);
            fwrite($file, "
generate_update_sql ({$table_name}, Record,  Comma, [$index | Changes], Sql) ->");
            write_type_to_bin($file, $table_name, $field, $name_len_max);
            $dots  = generate_char($name_len_max, strlen("NewSql"), ' ');
            $dots2 = generate_char($name_len_max, strlen($field_name), ' ');
            fwrite($file, "
    NewSql{$dots} = [<<Comma/binary, {$dots2}\"`{$field_name}` = \", {$dots2}{$field_name_up}/binary>> | Sql],
    generate_update_sql({$table_name}, Record, <<\", \">>, Changes, NewSql);");
            $index ++;
        }

        fwrite($file, "
generate_update_sql ({$table_name}, Record, _Comma, [], Sql) ->");
        foreach ($fields as $field) {
            $field_key      = $field['COLUMN_KEY'];
            if ($field_key == "") {
                continue;
            }
            write_type_to_bin($file, $table_name, $field, $name_len_max);
        }
        $primary_key    = array();
        foreach ($fields as $field) {
            $field_key      = $field['COLUMN_KEY'];
            if ($field_key == "") {
                continue;
            }
            $field_name     = $field['COLUMN_NAME'];
            $field_name_up  = ucfirst($field_name);
            $primary_key[]  = "`{$field_name}` = \", {$field_name_up}/binary, ";
        }
        $primary_key_arr    = implode("\" AND ", $primary_key);
        fwrite($file, "
    [<<\" WHERE {$primary_key_arr}\";\\n\">> | Sql];
");
    }

    // 写入 generate_update_sql/4 通配分支函数
    fwrite($file, "
generate_update_sql (_Table, _Record, _Comma, _Changes, _Sql) ->
    <<>>.
");

    fclose($file);
}
?>