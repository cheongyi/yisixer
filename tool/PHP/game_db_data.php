<?php
// =========== ======================================== ====================
// @todo   游戏数据库数据操作
function game_db_data () {
    global $tables_info, $tables_fields_info, $table_name_len_max, $game_db_data, $game_db_data_file;

    $file       = fopen($game_db_data_file, 'w');

    fwrite($file, "-module ({$game_db_data}).");
    write_attributes($file);
    // 写入系统属性
    fwrite($file, "
-export ([
    do/1,
    fetch/1,

    read/1, 
    select/2,           select/3, 
    write/1, 
    delete/1, 
    delete_select/2,    delete_select/3, 
    delete_all/1,

    count/1,
    memory/0,           memory/1
]).

-include (\"gen/game_db.hrl\").

-define (ENSURE_TRAN, ensure_tran()).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
do (Tran) ->
    case get(tran_action_list) of
        undefined ->
            do_tran_put_init(),

            case catch Tran() of
                {'EXIT', {aborted, Reason}} -> 
                    rollback(get(tran_log)),
                    do_tran_erase(),
                    exit(Reason);

                {'EXIT', Reason} -> 
                    rollback(get(tran_log)),
                    do_tran_erase(),
                    exit(Reason);
                    
                Result ->
                    erase(tran_log),
                    TranActionList = erase(tran_action_list),
                    case TranActionList of
                        [] -> ok;
                        _  -> game_db_sync_srv ! {sync, TranActionList}
                    end,
                    {atomic, Result}
            end;
        _ -> 
            {atomic, Tran()}
    end.


fetch (Sql) ->
    {data, ResultId} = game_mysql:fetch(gamedb, Sql),
    lib_mysql:get_rows(ResultId).


%%% ========== ======================================== ====================
%%% read
%%% ========== ======================================== ====================");



    // 写入 read/1 函数
    $tables = $tables_info['TABLES'];
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        // 日志表不读
        $is_log_table   = $fields_info['IS_LOG_TABLE'];
        if ($is_log_table) {
            continue;
        }
        $primary        = $fields_info['PRIMARY'];
        $frag_field     = $fields_info['FRAG_FIELD'];
        $primary_key    = array();
        $row_key_up     = array();
        foreach ($primary as $field_name) {
            $field_name_up  = ucfirst($field_name);
            $primary_key[]  = "{$field_name} = {$field_name_up}";
            $row_key_up[]   = $field_name_up;
        }
        $primary_key_arr    = implode(", ", $primary_key);
        $row_key_up_arr     = implode(", ", $row_key_up);
        if ($frag_field) {
            if (in_array($frag_field, $primary)) {
                $ets_lookup  = "ets:lookup(
        game_db_table:ets_tab({$table_name}, {$field_name_up} rem 100), 
        {{$row_key_up_arr}}
    )";
            }
            else {
                $ets_lookup  = "fetch_lookup({$table_name}, {{$row_key_up_arr}})";
            }
        }
        else {
            $ets_lookup  = "ets:lookup(t_{$table_name}, {{$row_key_up_arr}})";
        }
        fwrite($file, "
read (#pk_{$table_name}{{$primary_key_arr}}) ->
    TimeTuple   = game_perf:statistics_start(),
    Return      = {$ets_lookup},
    game_perf:statistics_end({?MODULE, 'read.{$table_name}', 1}, TimeTuple),
    Return;
");
    }



    // 写入 read/1 通配分支函数
    // 写入 select/2 函数
    fwrite($file, "
read (Record) ->
    exit({?MODULE, read, {unkown_record, Record}}).


%%% ========== ======================================== ====================
%%% select
%%% ========== ======================================== ====================
select (Table, MatchSpec) ->
    select(Table, signle, MatchSpec).
");
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        // 日志表不读
        $is_log_table   = $fields_info['IS_LOG_TABLE'];
        if ($is_log_table) {
            continue;
        }
        $frag_field     = $fields_info['FRAG_FIELD'];
        if ($frag_field) {
            $record_select  = "Return      = case _ModeOrFragId of
        slow    -> 
            fetch_select({$table_name}, MatchSpec);
        _FragId ->
            ets:select(game_db_table:ets_tab({$table_name}, _FragId rem 100), MatchSpec)
    end,";
        }
        else {
            $record_select  = "Return      = ets:select(t_{$table_name}, MatchSpec),";
        }
        fwrite($file, "
select ({$table_name}, _ModeOrFragId, MatchSpec) ->
    TimeTuple   = game_perf:statistics_start(),
    {$record_select}
    game_perf:statistics_end({?MODULE, 'select.{$table_name}', 3}, TimeTuple),
    Return;
");
    }

    // 写入 select/3 通配分支函数
    fwrite($file, "
select (Table, ModeOrFragId, MatchSpec) ->
    exit({?MODULE, select, {unkown_info, Table, ModeOrFragId, MatchSpec}}).


%%% ========== ======================================== ====================
%%% write
%%% ========== ======================================== ====================");



    // 写入 write/1  函数
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $fields         = $fields_info['FIELDS'];
        $primary        = $fields_info['PRIMARY'];
        $frag_field     = $fields_info['FRAG_FIELD'];
        $auto_increment = $fields_info['AUTO_INCREMENT'];
        $is_log_table   = $fields_info['IS_LOG_TABLE'];
        // 判断是否日志表
        if ($is_log_table) {
            fwrite($file, "
write (Record = #{$table_name}{}) -> ?ENSURE_TRAN,
    TimeTuple   = game_perf:statistics_start(),
    validate_for_write(Record, insert),
    NewId        = ets:update_counter(auto_increment, {{$table_name}, id}, 1),
    InsertRecord = Record #{$table_name}{
        {$auto_increment}      = NewId,
        row_key = {NewId}
    },
    add_tran_action({{$table_name}, insert, InsertRecord}),
    game_perf:statistics_end({?MODULE, 'write.{$table_name}', 1}, TimeTuple),
    {ok, InsertRecord};
");
            continue;
        }
        $fields_num     = count($fields);
        $primary_key    = array();
        $row_key_up     = array();
        foreach ($primary as $field_name) {
            $field_name_up  = ucfirst($field_name);
            $primary_key[]  = "{$field_name} = {$field_name_up}";
            $row_key_up[]   = $field_name_up;
        }
        $primary_key_arr    = implode(", ", $primary_key);
        $row_key_up_arr     = implode(", ", $row_key_up);
        // 判断是否分表
        if ($frag_field) {
            $ets_table  = "game_db_table:ets_tab({$table_name}, Record #{$table_name}.{$frag_field} rem 100)";
        }
        else {
            $ets_table  = "t_{$table_name}";
        }
        // 判断是否自增长
        if ($auto_increment == "") {
            $insert_record  = "InsertRecord = Record #{$table_name}{
                row_key = {{$row_key_up_arr}}
            },";
        }
        else {
            $insert_record  = "NewId        = case Record #{$table_name}.{$auto_increment} of
               null -> ets:update_counter(auto_increment, {{$table_name}, id}, 1);
               Id   -> Id
            end,
            InsertRecord = Record #{$table_name}{
                {$auto_increment}      = NewId,
                row_key = {NewId}
            },";
        }
        fwrite($file, "
write (Record = #{$table_name}{row_key = RowKey, {$primary_key_arr}, row_ver = RowVer}) -> ?ENSURE_TRAN,
    TimeTuple   = game_perf:statistics_start(),
    EtsTable    = {$ets_table},
    Return      = case RowKey of
        undefined ->
            validate_for_write(Record, insert),
            {$insert_record}
            true = ets:insert_new(EtsTable, InsertRecord),
            add_tran_log({insert, EtsTable, InsertRecord #{$table_name}.row_key}),
            add_tran_action({{$table_name}, insert, InsertRecord}),
            {ok, InsertRecord};
        _ ->
            validate_for_write(Record, update),
            [OldRecord]  = ets:lookup(EtsTable, RowKey),
            if OldRecord #{$table_name}.row_ver =:= RowVer -> ok end,
            Changes      = get_changes({$fields_num}, Record, OldRecord),
            UpdateRecord = Record #{$table_name}{row_ver = RowVer + 1},
            ets:insert(EtsTable, UpdateRecord),
            add_tran_log({update, EtsTable, OldRecord}),
            add_tran_action({{$table_name}, update, Record, Changes}),
            {ok, UpdateRecord}
    end,
    game_perf:statistics_end({?MODULE, 'write.{$table_name}', 1}, TimeTuple),
    Return;
");
    }

    // 写入 write/1  通配分支函数
    fwrite($file, "
write (Record) ->
    exit({?MODULE, write, {unkown_record, Record}}).


%%% ========== ======================================== ====================
%%% delete
%%% ========== ======================================== ====================");



    // 写入 delete/1 函数
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        // 日志表不读
        $is_log_table   = $fields_info['IS_LOG_TABLE'];
        if ($is_log_table) {
            continue;
        }
        $frag_field     = $fields_info['FRAG_FIELD'];
        if ($frag_field) {
            $ets_table  = "game_db_table:ets_tab({$table_name}, Record #{$table_name}.{$frag_field} rem 100)";
        }
        else {
            $ets_table  = "t_{$table_name}";
        }
        fwrite($file, "
delete (Record = #{$table_name}{row_key = RowKey}) -> ?ENSURE_TRAN,
    TimeTuple   = game_perf:statistics_start(),
    EtsTable    = {$ets_table},
    ets:delete(EtsTable, RowKey),
    add_tran_log({delete, EtsTable, Record}),
    add_tran_action({{$table_name}, delete, Record}),
    game_perf:statistics_end({?MODULE, 'delete.{$table_name}', 1}, TimeTuple),
    ok;
");
    }


    // 写入 delete/1 通配分支函数
    // 写入 delete_select/2 函数
    fwrite($file, "
delete (Record) ->
    exit({?MODULE, delete, {unkown_record, Record}}).


%%% ========== ======================================== ====================
%%% delete_select
%%% ========== ======================================== ====================
delete_select (Table, MatchSpec) ->
    delete_select(Table, signle, MatchSpec).

% delete_select (Table, _ModeOrFragId, MatchSpec) -> ?ENSURE_TRAN,
%     TimeTuple   = game_perf:statistics_start(),
%     RecordList  = select(Table, _ModeOrFragId, MatchSpec),
%     Count       = do_delete_select(RecordList,  0),
%     Action      = list_to_atom(\"delete_select.\" ++ atom_to_list(Table)),
%     game_perf:statistics_end({game_db_data, Action, 3}, TimeTuple),
%     {ok, Count}.
");


    // 写入 delete_select/3 函数
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        // 日志表不读
        $is_log_table   = $fields_info['IS_LOG_TABLE'];
        if ($is_log_table) {
            continue;
        }
        fwrite($file, "
delete_select ({$table_name}, _ModeOrFragId, MatchSpec) -> ?ENSURE_TRAN,
    TimeTuple   = game_perf:statistics_start(),
    RecordList  = select({$table_name}, _ModeOrFragId, MatchSpec),
    Count       = do_delete_select(RecordList,  0),
    game_perf:statistics_end({?MODULE, 'delete_select.{$table_name}', 3}, TimeTuple),
    {ok, Count};
");
    }

    // 写入 delete_select/3  通配分支函数
    // 写入 do_delete_select/2 函数
    fwrite($file, "
delete_select (Table, ModeOrFragId, MatchSpec) ->
    exit({?MODULE, delete_select, {unkown_info, Table, ModeOrFragId, MatchSpec}}).

do_delete_select ([Record | List], Count) ->
    delete(Record),
    do_delete_select(List, Count + 1);
do_delete_select ([], Count) ->
    Count.


%%% ========== ======================================== ====================
%%% delete_all
%%% ========== ======================================== ====================");



    // 写入 delete_all/1 函数
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        // 日志表不读
        $is_log_table   = $fields_info['IS_LOG_TABLE'];
        if ($is_log_table) {
            continue;
        }
        $frag_field     = $fields_info['FRAG_FIELD'];
        if ($frag_field) {
            $delete_all_objects  = "[
        ets:delete_all_objects(game_db_table:ets_tab({$table_name}, FragId)) 
        || 
        FragId <- ?FRAG_ID_LIST
    ]";
        }
        else {
            $delete_all_objects  = "ets:delete_all_objects(t_{$table_name})";
        }
        fwrite($file, "
delete_all ({$table_name}) -> ?ENSURE_TRAN,
    TimeTuple   = game_perf:statistics_start(),
    Size        = count({$table_name}),
    Return      = {$delete_all_objects},
    if 
        Size > 10000 -> add_tran_action({{$table_name}, bin_sql, <<   \"TRUNCATE `{$table_name}`;\">>});
        true         -> add_tran_action({{$table_name}, bin_sql, <<\"DELETE FROM `{$table_name}`;\">>})
    end,
    game_perf:statistics_end({?MODULE, 'delete_all.{$table_name}', 1}, TimeTuple),
    Return;
");
    }

    // 写入 delete_all/1 通配分支函数
    fwrite($file, "
delete_all (Table) ->
    exit({?MODULE, delete_all, {unkown_table, Table}}).


%%% ========== ======================================== ====================
%%% count
%%% ========== ======================================== ====================");


    // 写入 count/1 函数
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $frag_field     = $fields_info['FRAG_FIELD'];
        if ($frag_field) {
            $dots   = generate_char($table_name_len_max, strlen($table_name), ' ');
            fwrite($file, "
count ({$table_name}){$dots} -> count_frag({$table_name});");
        }
    }

    // 写入 count/1  通配分支函数
    // 写入 memory/0 函数
    // 写入 memory/2 函数
    $dots = generate_char($table_name_len_max, strlen("Table"), ' ');
    fwrite($file, "
count (Table){$dots} -> ets:info(game_db_table:ets_tab(Table), size).

count_frag (Table) ->
    lists:sum([ets:info(game_db_table:ets_tab(Table, FragId), size) || FragId <- ?FRAG_ID_LIST]).


%%% ========== ======================================== ====================
%%% memory
%%% ========== ======================================== ====================
memory () ->
    memory(game_db_table:get_all_table(), 0).

memory ([Table | List], TotalMemory) ->
    Memory  = memory(Table),
    memory(List, TotalMemory + Memory);
memory ([], TotalMemory) ->
    TotalMemory.
");


    // 写入 memory/1 函数
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $frag_field     = $fields_info['FRAG_FIELD'];
        if ($frag_field) {
            $dots   = generate_char($table_name_len_max, strlen($table_name), ' ');
            fwrite($file, "
memory ({$table_name}){$dots} -> memory_frag({$table_name});");
        }
    }

    // 写入 memory/1  通配分支函数
    $dots = generate_char($table_name_len_max, strlen("Table"), ' ');
    fwrite($file, "
memory (Table){$dots} -> ets:info(game_db_table:ets_tab(Table), memory).

memory_frag (Table) ->
    lists:sum([ets:info(game_db_table:ets_tab(Table, FragId), memory) || FragId <- ?FRAG_ID_LIST]).


%%% ========== ======================================== ====================");



    // 写入内部函数
    fwrite($file, "
%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================");

    // 写入 validate_for_write 函数
    foreach ($tables as $table_name) {
        fwrite($file, "
validate_for_write (Record, Type) when is_record(Record, {$table_name}) ->");
        $fields_info        = $tables_fields_info[$table_name];
        $fields             = $fields_info['FIELDS'];
        $field_name_len_max = $fields_info['NAME_LEN_MAX'];
        foreach ($fields as $field) {
            $field_extra    = $field['EXTRA'];
            $is_nullable    = $field['IS_NULLABLE'];
            $field_name     = $field['COLUMN_NAME'];
            $dots   = generate_char($field_name_len_max, strlen($field_name), ' ');
            if ($field_extra == "auto_increment" && $is_nullable == "NO") {
                fwrite($file, "
    if  Type == update andalso 
        Record #{$table_name}.{$field_name}{$dots} == null -> exit({null_column, Type, {$table_name}, {$field_name}});{$dots} true -> ok end,");
                continue;
            }
            if ($is_nullable == "NO") {
                fwrite($file, "
    if  Record #{$table_name}.{$field_name}{$dots} == null -> exit({null_column, Type, {$table_name}, {$field_name}});{$dots} true -> ok end,");
            }
        }
        fwrite($file, "
    ok;
");
    }

    // 写入 validate_for_write  通配分支函数
        fwrite($file, "
validate_for_write (Record, Type) ->
    exit({validate_for_write, Type, Record}).


%%% ========== ======================================== ====================");
    foreach ($tables as $table_name) {
    }

    // 写入我也不知道怎么注释了
    fwrite($file, "
ensure_tran () -> 
    case get(tran_action_list) of 
        undefined -> exit(need_gamedb_tran); 
        _         -> ok 
    end.

do_tran_put_init () ->
    put(tran_log, []),
    put(tran_action_list, []),
    put(tran_action_list2, []).

do_tran_erase () ->
    erase(tran_log),
    erase(tran_action_list),
    erase(tran_action_list2).
    
add_tran_log (TranLog) ->
    TranLogList = get(tran_log),
    put(tran_log, [TranLog | TranLogList]).

add_tran_action (TranAction) ->
    TranActionList = get(tran_action_list),
    put(tran_action_list, [TranAction | TranActionList]).

rollback ([TranLog | List]) ->
    case TranLog of
        {insert, Table, RowKey} ->
            ets:delete(Table, RowKey);
        {update, Table, Row} ->
            ets:insert(Table, Row);
        {delete, Table, Row} ->
            ets:insert(Table, Row)
    end,
    rollback(List);
rollback ([]) ->
    ok.


%%% ========== ======================================== ====================
%%% @doc    Index:: need add record_name and row_key
get_changes (Index, NewRecord, OldRecord) ->
    get_changes(Index + 2, NewRecord, OldRecord, []).
    
get_changes (2, _, _, Changes) -> 
    Changes;
get_changes (Index, NewRecord, OldRecord, Changes) ->
    case element(Index, NewRecord) =:= element(Index, OldRecord) of
        true  -> get_changes(Index - 1, NewRecord, OldRecord, Changes);
        false -> get_changes(Index - 1, NewRecord, OldRecord, [Index | Changes])
    end.


%%% ========== ======================================== ====================
fetch_lookup(Table, Key) ->
    fetch_lookup(Table, Key, 0).

fetch_lookup(_, _, 100) ->
    [];
fetch_lookup(Table, Key, FragId) ->
    case ets:lookup(game_db_table:ets_tab(Table, FragId), Key) of
        [] -> fetch_lookup(Table, Key, FragId + 1);
        R  -> R
    end.


fetch_select(Table, MatchSpec) ->
    fetch_select(Table, MatchSpec, 0, []).

fetch_select(_, _, 100, Return) ->
    lists:concat(Return);
fetch_select(Table, MatchSpec, FragId, Return) ->
    NewReturn   = case ets:select(game_db_table:ets_tab(Table, FragId), MatchSpec) of
        []      -> Return;
        Result  -> Result ++ Return
    end,
    fetch_select(
        Table, 
        MatchSpec, 
        FragId + 1, 
        NewReturn
    ).
");

    fclose($file);
}
?>