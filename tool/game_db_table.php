<?php
// =========== ======================================== ====================
// @todo   游戏数据库表
function game_db_table () {
    global $tables_info, $tables_fields_info, $table_name_len_max, $game_db_table, $game_db_table_file;

    $tables     = $tables_info['TABLES'];

    $file       = fopen($game_db_table_file, 'w');

    fwrite($file, "-module ({$game_db_table}).");
    write_attributes($file);
    // 写入系统属性
    fwrite($file, "
-export ([
    ets_tab/1,          ets_tab/2,

    get_all_table/0,
    get_all_player_table/0,
    get_all_template_table/0
]).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================");



    // 写入 ets_tab/1 函数
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $frag_field     = $fields_info['FRAG_FIELD'];
        if ($frag_field) {
            continue;
        }
        $dots   = generate_char($table_name_len_max, strlen($table_name), ' ');
        fwrite($file, "
ets_tab ({$table_name}){$dots} -> t_{$table_name};");
    }

    // 写入 ets_tab/1  通配分支函数
    $dots = generate_char($table_name_len_max, strlen("Table"), ' ');
    fwrite($file, "
ets_tab (Table){$dots} -> exit({?MODULE, ets_tab, {unkown_table, Table}}).

");


    // 写入 ets_tab/2 函数
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $frag_field     = $fields_info['FRAG_FIELD'];
        if ($frag_field) {
            $dots   = generate_char($table_name_len_max, strlen($table_name), ' ');
            for ($i =  0; $i <  10; $i++) { 
            fwrite($file, "
ets_tab ({$table_name}, 0{$i}){$dots}     -> t_{$table_name}_0{$i};");
            }
            for ($i = 10; $i < 100; $i++) { 
            fwrite($file, "
ets_tab ({$table_name}, {$i}){$dots}     -> t_{$table_name}_{$i};");
            }
            fwrite($file, "
ets_tab ({$table_name}, FragId){$dots} -> ets_tab({$table_name}, FragId rem 100);
");
        }
    }

    // 写入 ets_tab/2  通配分支函数
    $dots = generate_char($table_name_len_max, strlen("Table"), ' ');
    fwrite($file, "
ets_tab (Table, _FragId){$dots}-> exit({?MODULE, ets_tab, {unkown_table, Table}}).


%%% ========== ======================================== ====================");



    // 写入 get_all_table/0 函数
    // 写入 get_all_player_table/0 函数
    // 写入 get_all_template_table/0 函数
    $player_tables      = array();
    $template_tables    = array();
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $is_temp_table  = $fields_info['IS_TEMP_TABLE'];
        if ($is_temp_table) {
            $template_tables[]  = $table_name;
        }
        else {
            $player_tables[]    = $table_name;
        }
    }
    $tables_arr         = implode(",
        ", $tables);
    $player_tables_arr  = implode(",
        ", $player_tables);
    $template_tables_arr= implode(",
        ", $template_tables);
    fwrite($file, "
get_all_table () ->
    [
        {$tables_arr}
    ].

get_all_player_table () ->
    [
        {$player_tables_arr}
    ].

get_all_template_table () ->
    [
        {$template_tables_arr}
    ].

");
}
?>