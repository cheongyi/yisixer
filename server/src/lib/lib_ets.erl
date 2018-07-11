-module(lib_ets).

%%% @doc    ets库函数

-author     ("CHEONGYI").
-date       ({2018, 03, 06}).
-vsn        ("1.0.0").

-export([
    create/1, create/2, create/3, create/4,     % 新建表
    insert/2, insert/3,
    get/2,  get/3,
    match/2, match/3,
    select/2,
    check_record/2,
    update/3,
    delete/2,
    delete_object/2,
    delete_all/1,
    drop/1,
    select_delete/2,
    tab2list/1,
    first/1,
    next/2,

    reload_template/1,      %% 重新加载模板表
    reload_all_template/0,  %% 重新加载所有模板表
    load_new/1,             %% 加载新表
    reload_player_table/2   %% 重新加载玩家表(外网禁用,参数为表名,是否有分表)
]).

-include("define.hrl").

-define (DEFAULT_KEYPOS, 1).                    % 默认键位置

%% -----------------------------------------------------------------------------
%% Function: create(TableName) -> TableName | error
%%              TableName: 表名[atom]
%% Descrip: 新建表
%%
%% -----------------------------------------------------------------------------
create (TableName) ->
    create(TableName, set, ?DEFAULT_KEYPOS, protected).

%% -----------------------------------------------------------------------------
%% Function: create(TableName, Type) -> TableName | error
%%              TableName: 表名[atom]
%%              Type: 表类型[set|ordered_set|bag|duplicate_bag]
%% Descrip: 新建表
%%
%% -----------------------------------------------------------------------------
create (TableName, Type) ->
    create(TableName, Type, ?DEFAULT_KEYPOS, protected).

%% -----------------------------------------------------------------------------
%% Function: create(TableName, Type, KeyPosition) -> TableName | error
%%              TableName: 表名[atom]
%%              Type: 表类型[set|ordered_set|bag|duplicate_bag]
%%              KeyPosition: key位置[int]
%% Descrip: 新建表
%%
%% -----------------------------------------------------------------------------
create (TableName, Type, KeyPosition) ->
    create(TableName, Type, KeyPosition, protected).

%% -----------------------------------------------------------------------------
%% Function: create(TableName, Type, KeyPosition, Access) -> TableName | error
%%              TableName: 表名[atom]
%%              Type: 表类型[set|ordered_set|bag|duplicate_bag]
%%              KeyPosition: key位置[int]
%% Descrip: 新建表
%%
%% -----------------------------------------------------------------------------
create (TableName, Type, KeyPosition, Access) ->
    case catch ets:new(TableName, [Type, named_table, Access, {keypos, KeyPosition}]) of
        {'EXIT', _Reason} ->
            error;
        Success ->
            Success
    end.


%% -----------------------------------------------------------------------------
%% Function: insert(TableName, Value) -> true | false | error
%%              TableName: 表名[atom]
%%              Value: 值[list]
%% Descrip: 插入数据(set类型表，如果新的记录key与旧的key重复，插入会失败)
%%
%% -----------------------------------------------------------------------------
insert (TableName, Value) ->
    insert(TableName, Value, null).

%% -----------------------------------------------------------------------------
%% Function: insert_data(TableName, Value, Type) -> true | false | error
%%              TableName: 表名[atom]
%%              Value: 值[list]
%%              Type: 插入类型[replace]
%% Descrip: 插入数据(set类型表，如果新的记录key与旧的key重复，旧值会被覆盖)
%%
%% -----------------------------------------------------------------------------
insert (TableName, Value, Type) ->
     case Type of
        null ->
            case catch ets:insert_new(TableName, Value) of
                {'EXIT', _Reason} ->
                    error;
                Success ->
                    Success
            end;
        _Other ->
            case catch ets:insert(TableName, Value) of
                {'EXIT', _Reason} ->
                    error;
                Success ->
                    Success
            end
    end.


%% -----------------------------------------------------------------------------
%% Function: get(TableName, Key) -> list
%%              TableName: 表名[atom]
%%              Key: key值[term]
%% Descrip: 根据Key值查询数据,返回整个记录
%%
%% -----------------------------------------------------------------------------
get (TableName, Key) ->
    get(TableName, Key, null).

%% -----------------------------------------------------------------------------
%% Function: get(TableName, Key, ColumnPosition) -> list
%%              TableName: 表名[atom]
%%              Key: key值[term]
%%              ColumnPosition: 要查询的列索引[int]
%% Descrip: 根据Key值查询数据,只返回单列数据
%%
%% -----------------------------------------------------------------------------
get (TableName, Key, ColumnPosition) ->
    case ColumnPosition of
        null ->
            case catch ets:lookup(TableName, Key) of
                {'EXIT', _Reason} ->
                    [];
                Data ->
                    Data
            end;
        Position ->
            case catch ets:lookup_element(TableName, Key, Position) of
                {'EXIT', _Reason} ->
                    [];
                Data ->
                    Data
            end
    end.

%% -----------------------------------------------------------------------------
%% Function: match(TableName, MatchExp) -> list
%%              TableName: 表名[atom]
%%              MatchExp: match匹配表达式
%% Descrip: match匹配查询数据,只返回单列数据
%%
%% -----------------------------------------------------------------------------
match (TableName, MatchExp) ->
    match(TableName, MatchExp, null).

%% -----------------------------------------------------------------------------
%% Function: match(TableName, MatchExp, Type) -> list
%%              TableName: 表名[atom]
%%              MatchExp: match匹配表达式
%%              Type: match查询类型[object]
%% Descrip: match匹配查询数据，返回整个记录
%%
%% -----------------------------------------------------------------------------
match (TableName, MatchExp, Type) ->
    case Type of
        null ->
            case catch ets:match(TableName, MatchExp) of
                {'EXIT', _Reason} ->
                    [];
                Data ->
                    Data
            end;
        _Other ->
            case catch ets:match_object(TableName, MatchExp) of
                {'EXIT', _Reason} ->
                    [];
                Data ->
                    Data
            end
    end.

%% -----------------------------------------------------------------------------
%% Function: select(TableName, MatchSpec) -> list
%%              TableName: 表名[atom]
%%              MatchSpec: match_spec()
%% Descrip: match匹配查询数据，返回整个记录
%%
%% -----------------------------------------------------------------------------
select (TableName, MatchSpec) ->
    case catch ets:select(TableName, MatchSpec) of
        {'EXIT', _Reason} ->
            [];
        Data ->
            Data
    end.

%% -----------------------------------------------------------------------------
%% Function: check_record(TableName, Key) -> true | flase | error
%%              TableName: 表名[atom]
%%              Key: key值
%% Descrip: 根据key值检查记录是否存在
%%
%% -----------------------------------------------------------------------------
check_record (TableName, Key) ->
    case catch ets:member(TableName, Key) of
        {'EXIT', _Reason} ->
            error;
        Success ->
            Success
    end.


%% -----------------------------------------------------------------------------
%% Function: update(TableName, Key, Value) -> true | flase | error
%%              TableName: 表名[atom]
%%              Key: key值
%%              Value: 要更新的值
%% Descrip: 根据Key值更新数据
%%
%% -----------------------------------------------------------------------------
update (TableName, Key, Value) ->
     case catch ets:update_element(TableName, Key, Value) of
        {'EXIT', _Reason} ->
            error;
        Success ->
            Success
    end.


%% -----------------------------------------------------------------------------
%% Function: delete(TableName, Key) -> true | flase | error
%%              TableName: 表名[atom]
%%              Key: key值[term]
%% Descrip: 根据Key值删除数据
%%
%% -----------------------------------------------------------------------------
delete (TableName, Key) ->
    case catch ets:delete(TableName, Key) of
        {'EXIT', _Reason} ->
            error;
        Success ->
            Success
    end.


%% -----------------------------------------------------------------------------
%% Function: delete_object(TableName, Object) -> true | error
%%              TableName: 表名[atom]
%%              Object: 表数据[tuple()]
%% Descrip: 删除表某一数据
%%
%% -----------------------------------------------------------------------------
delete_object (TableName, Object) ->
    case catch ets:delete_object(TableName, Object) of
        true ->
            true;
        _ ->
            error
    end.


%% -----------------------------------------------------------------------------
%% Function: delete_all(TableName) -> true | error
%%              TableName: 表名[atom]
%% Descrip: 删除表所有数据
%%
%% -----------------------------------------------------------------------------
delete_all (TableName) ->
    case catch ets:delete_all_objects(TableName) of
        true ->
            true;
        _ ->
            error
    end.


%% -----------------------------------------------------------------------------
%% Function: drop(TableName) -> true | flase | error
%%              TableName: 表名[atom]
%% Descrip: 删除表
%%
%% -----------------------------------------------------------------------------
drop (TableName) ->
    case catch ets:delete(TableName) of
        {'EXIT', _Reason} ->
            error;
        Success ->
            Success
    end.


select_delete (TableName, MatchSpec) ->
    case catch ets:select_delete(TableName, MatchSpec) of
        {'EXIT', _Reason} ->
            error;
        Success ->
            Success
    end.

tab2list (TableName) ->
    case catch ets:tab2list(TableName) of
        {'EXIT', _Reason} ->
            error;
        Success ->
            Success
    end.
    
    
first (TableName) ->
    ets:first(TableName).
    
    
next (TableName, Key) ->
    ets:next(TableName, Key).
    
reload_template (TableName) ->
    case lists:member(TableName, game_db:get_all_template_table()) of
        true ->
            GameDbTableName = game_db:ets(TableName),
            ets:delete_all_objects(GameDbTableName),
            game_db_init:load(TableName);
        _ ->
            noop
    end.

reload_template_not_check (TableName) ->
    GameDbTableName = game_db:ets(TableName),
    ets:delete_all_objects(GameDbTableName),
    game_db_init:load(TableName).

reload_player_table (TableName, IsFlag) ->
    case ?IS_DEBUG of 
        true ->
            if
                IsFlag ->
                    [ets:delete_all_objects(list_to_atom("t_" ++ atom_to_list(TableName) ++ "_" ++ integer_to_list(Id))) || Id <- lists:seq(0, 99)];
                true ->
                    ets:delete_all_objects(list_to_atom("t_" ++ atom_to_list(TableName)))
            end,
            game_db_init:load(TableName);
        _ ->
            noop
    end.

reload_all_template () ->
    [
        reload_template_not_check(TableName)
        ||
        TableName <- game_db:get_all_template_table()
    ],
    ok.

load_new (TableName) ->
    game_db_init_srv:load_new(TableName).




