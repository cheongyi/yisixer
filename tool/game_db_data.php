<?php
// =========== ======================================== ====================
// @todo   游戏数据库数据操作
function game_db_data () {
    global $tables_info, $tables_fields_info, $game_db_data, $game_db_data_file;

    $file       = fopen($game_db_data_file, 'w');

    fwrite($file, "-module ({$game_db_data}).");
    write_attributes($file);
    // 写入系统属性
    fwrite($file, "
-export ([
    do/1,
    fetch/1,

    dirty_read/1, 
    dirty_select/2,     dirty_select/3, 

    read/1, 
    select/2,           select/3, 
    write/1, 
    delete/1, 
    delete_select/2,    delete_select/3, 
    delete_all/1,

    table/1,            table/2,
    ets/1,              ets/2,
    count/1,
    memory/0,           memory/1,
    get_all_template_table/0
]).

-include (\"gen/game_db.hrl\").

-define (ENSURE_TRAN, ensure_tran()).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
do (Tran) ->
    case get(tran_action_list) of
        undefined ->
            do_tran_put(),

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

do_tran_put () ->
    put(tran_log, []),
    put(tran_action_list, []),
    put(tran_action_list2, []).

do_tran_erase () ->
    erase(tran_log),
    erase(tran_action_list),
    erase(tran_action_list2).

fetch (Sql) ->
    {data, ResultId} = game_mysql:fetch(gamedb, Sql),
    lib_mysql:get_rows(ResultId).


dirty_read (Key) ->
    read(Key).

dirty_select (Table, MatchSpec) ->
    select(Table, MatchSpec).

dirty_select (Table, PlayerId, MatchSpec) ->
    select(Table, PlayerId, MatchSpec).


%%% ========== ======================================== ====================
%%% ========== ======================================== ====================");

    // 写入 read   函数
    $tables = $tables_info['TABLES'];
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $primary        = $fields_info['PRIMARY'];
        $is_frag        = $fields_info['IS_FRAG'];
        $primary_key    = array();
        $row_key_up     = array();
        foreach ($primary as $field_name) {
            $field_name_up  = ucfirst($field_name);
            $primary_key[]  = "{$field_name} = {$field_name_up}";
            $row_key_up[]   = $field_name_up;
        }
        $primary_key_arr    = implode(", ", $primary_key);
        $row_key_up_arr     = implode(", ", $row_key_up);
        if ($is_frag) {
            $ets_table  = "list_to_atom(\"t_{$table_name}_\" ++ integer_to_list(Record #{$table_name}.player_id rem 100))";
        }
        else {
            $ets_table  = "t_{$table_name}";
        }
        fwrite($file, "
read (#pk_{$table_name}{{$primary_key_arr}}) ->
    TimeTuple   = game_perf:statistics_start(),
    Return      = ets:lookup({$ets_table}, {{$row_key_up_arr}}),
    game_perf:statistics_end({{$game_db_data}, 'read.{$table_name}', 1}, TimeTuple),
    Return;
");
    }

    // 写入 read   通配分支函数
    // 写入 select 函数
    fwrite($file, "
read (_Record) ->
    ok.


%%% ========== ======================================== ====================
select (Table, MatchSpec) ->
    select(Table, signle, MatchSpec).
");
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $is_frag        = $fields_info['IS_FRAG'];
        if ($is_frag) {
            $record_select  = "Return      = case _ModeOrFragId of
        slow    -> 
            fetch_select(\"t_{$table_name}_\", MatchSpec);
        _FragId ->
            ets:select(list_to_atom(\"t_{$table_name}_\" ++ integer_to_list(_FragId rem 100)), MatchSpec)
    end,";
        }
        else {
            $record_select  = "Return      = ets:select(t_{$table_name}, MatchSpec),";
        }
        fwrite($file, "
select ({$table_name}, _ModeOrFragId, MatchSpec) ->
    TimeTuple   = game_perf:statistics_start(),
    {$record_select}
    game_perf:statistics_end({{$game_db_data}, 'select.{$table_name}', 3}, TimeTuple),
    Return;
");
    }

    // 写入 select 通配分支函数
    // 写入 write  函数
    fwrite($file, "
select (_Table, _ModeOrFragId, _MatchSpec) ->
    ok.


%%% ========== ======================================== ====================");
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $fields         = $fields_info['FIELDS'];
        $primary        = $fields_info['PRIMARY'];
        $is_frag        = $fields_info['IS_FRAG'];
        $auto_increment = $fields_info['AUTO_INCREMENT'];
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
        if ($is_frag) {
            $ets_table  = "list_to_atom(\"t_{$table_name}_\" ++ integer_to_list(Record #{$table_name}.player_id rem 100))";
        }
        else {
            $ets_table  = "t_{$table_name}";
        }
        if ($auto_increment == "") {
            $insert_record  = "NewRecord = Record #peach_fail_tips{
                row_key = {{$row_key_up_arr}}
            },";
        }
        else {
            $insert_record  = "NewId        = case Record #{$table_name}.{$auto_increment} of
               null -> ets:update_counter(auto_increment, {{$table_name}, id}, 1);
               Id   -> Id
            end,
            NewRecord = Record #peach_fail_tips{
                {$auto_increment}      = NewId,
                row_key = {{$row_key_up_arr}}
            },";
        }
        fwrite($file, "
write (Record = #{$table_name}{row_key = RowKey, {$primary_key_arr}, row_ver = RowVer}) -> ?ENSURE_TRAN,
    TimeTuple   = game_perf:statistics_start(),
    EtsTable    = {$ets_table},
    Return      = case RowKey of
        undefined ->
            validate_for_insert(Record),
            {$insert_record}
            true = ets:insert_new(EtsTable, InsertRecord),
            add_tran_log({insert, EtsTable, InsertRecord #{$table_name}.row_key}),
            add_tran_action({{$table_name}, insert, InsertRecord}),
            {ok, InsertRecord};
        _ ->
            validate_for_update(Record),
            [OldRecord]  = ets:lookup(EtsTable, RowKey),
            if OldRecord #{$table_name}.row_ver =:= RowVer -> ok end,
            Changes      = get_changes({$fields_num}, Record, OldRecord),
            UpdateRecord = Record #{$table_name}{row_ver = RowVer + 1},
            ets:insert(EtsTable, UpdateRecord),
            add_tran_log({update, EtsTable, OldRecord}),
            add_tran_action({{$table_name}, update, Record, Changes}),
            {ok, UpdateRecord}
    end,
    game_perf:statistics_end({{$game_db_data}, 'write.{$table_name}', 1}, TimeTuple),
    Return;
");
    }

    // 写入 write  通配分支函数
    // 写入 delete 函数
    fwrite($file, "
write (_Record) ->
    ok.


%%% ========== ======================================== ====================");
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $is_frag        = $fields_info['IS_FRAG'];
        if ($is_frag) {
            $ets_table  = "list_to_atom(\"t_{$table_name}_\" ++ integer_to_list(_FragId rem 100))";
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
    game_perf:statistics_end({{$game_db_data}, 'delete.{$table_name}', 1}, TimeTuple),
    ok;
");
    }

    // 写入 delete 通配分支函数
    // 写入 delete_select 函数
    fwrite($file, "
delete (_Record) ->
    ok.


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
    foreach ($tables as $table_name) {
        fwrite($file, "
delete_select ({$table_name}, _ModeOrFragId, MatchSpec) -> ?ENSURE_TRAN,
    TimeTuple   = game_perf:statistics_start(),
    RecordList  = select({$table_name}, _ModeOrFragId, MatchSpec),
    Count       = do_delete_select(RecordList,  0),
    game_perf:statistics_end({{$game_db_data}, 'delete_select.{$table_name}', 3}, TimeTuple),
    {ok, Count};
");
    }

    // 写入 delete_select  通配分支函数
    // 写入 do_delete_select 函数
    // 写入 delete_all 函数
    fwrite($file, "
delete_select (_Table, _ModeOrFragId, _MatchSpec) ->
    ok.

do_delete_select ([Record | List], Count) ->
    delete(Record),
    do_delete_select(List, Count + 1);
do_delete_select ([], Count) ->
    Count.


%%% ========== ======================================== ====================");
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $is_frag        = $fields_info['IS_FRAG'];
        if ($is_frag) {
            $delete_all_objects  = "[
        ets:delete_all_objects(list_to_atom(\"t_player_abnormal_\" ++ integer_to_list(Id))) 
        || 
        Id <- ?FRAG_ID_LIST
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
        Size > 10000 -> add_tran_action({{$table_name}, sql, \"TRUNCATE `{$table_name}`;\"});
        true         -> add_tran_action({{$table_name}, sql, \"DELETE FROM `{$table_name}`;\"})
    end,
    game_perf:statistics_end({{$game_db_data}, 'delete_all.{$table_name}', 1}, TimeTuple),
    Return;
");
    }

    // 写入 delete_all  通配分支函数
    // 写入 get_all_template_table 函数
    $template_tables     = array();
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $is_temp_table  = $fields_info['IS_TEMP_TABLE'];
        if ($is_temp_table) {
            $template_tables[]  = $table_name;
        }
    }
    $template_tables_arr = implode(",
        ", $template_tables);
    fwrite($file, "
delete_all (_Table) ->
    ok.


%%% ========== ======================================== ====================
get_all_template_table () ->
    [
        {$template_tables_arr}
    ].
");

    // 写入 delete_all  通配分支函数
    // 写入 delete 函数
    fwrite($file, "
%%% ========== ======================================== ====================
");
    foreach ($tables as $table_name) {
    }

    // 写入 delete_all  通配分支函数
    // 写入 delete 函数
    fwrite($file, "
%%% ========== ======================================== ====================
");
    foreach ($tables as $table_name) {
    }

    // 写入 delete_all  通配分支函数
    // 写入 delete 函数
        fwrite($file, "
%%% ========== ======================================== ====================
");
    foreach ($tables as $table_name) {
    }




    fwrite($file, "
%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
ensure_tran () -> 
    case get(tran_action_list) of 
        undefined -> exit(need_gamedb_tran); 
        _         -> ok 
    end.
    
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

get_changes (N, NewRecord, OldRecord) ->
    get_changes(N, NewRecord, OldRecord, []).
    
get_changes (2, _, _, Changes) -> 
    Changes;
get_changes (N, NewRecord, OldRecord, Changes) ->
    case element(N, NewRecord) =:= element(N, OldRecord) of
        true  -> get_changes(N - 1, NewRecord, OldRecord, Changes);
        false -> get_changes(N - 1, NewRecord, OldRecord, [N | Changes])
    end.

fetch_lookup(TablePrefix, Key) ->
    fetch_lookup(TablePrefix, Key, 0).

fetch_lookup(_, _, 100) ->
    [];
fetch_lookup(TablePrefix, Key, N) ->
    case ets:lookup(list_to_atom(TablePrefix ++ integer_to_list(N)), Key) of
        [] -> fetch_lookup(TablePrefix, Key, N + 1);
        R  -> R
    end.

fetch_select(TablePrefix, MatchSpec) ->
    fetch_select(TablePrefix, MatchSpec, 0, []).

fetch_select(_, _, 100, Result) ->
    lists:concat(Result);
fetch_select(TablePrefix, MatchSpec, N, Result) ->
    fetch_select(
        TablePrefix, 
        MatchSpec, 
        N + 1, 
        [ets:select(list_to_atom(TablePrefix ++ integer_to_list(N)), MatchSpec) | Result]
    ).
");
}
?>