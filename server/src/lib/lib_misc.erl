-module (lib_misc).

%%% @doc    公用库函数

-author ("CHEONGYI").

-copyright ("Copyright © 2017 YiSiXEr").

-compile (export_all).

-export ([
    try_apply_to_online_player/4,               % 尝试同步给在线玩家应用MFA
    try_async_apply_to_online_player/4,         % 尝试异步给在线玩家应用MFA
    try_async_apply_to_online_player/5,         % 尝试异步给在线玩家应用MFA
    try_apply/3                                 % 尝试应用MFA
]).
-export ([
    % key_index_of_record/2,                      % 获取键在记录的索引
    index_of_tuple/2,                           % 获取元素在元组的索引
    index_of_list/2                             % 获取元素在列表的索引
]).

-include ("define.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    定时发送消息
send_after (Time, Dest, Msg) ->
    if
        is_pid(Dest) ->
            erlang:send_after(Time, Dest, Msg);
        true ->
            erlang:send_after(Time, whereis(Dest), Msg)
    end.

%%% @doc    定时应用MFA
apply_after (Time, Module, Function, Arguments) ->
    timer:apply_after(max(Time, 0), Module, Function, Arguments).


%%% @doc    尝试同步给在线玩家应用MFA(不在线则给游戏工作进程)
try_apply_to_online_player (PlayerId, M, F, A) when
    is_number(PlayerId) andalso
    is_atom(M) andalso is_atom(F) andalso is_list(A)
->
    try mod_online:apply_to_online_player(PlayerId, M, F, A) of
        false ->
            put(do_work_param, {M, F, A}),
            R = game_worker:do_work(M, F, A),
            erase(do_work_param),
            R;
        Result ->
            Result
    catch
        _ : Reason ->
            {error, Reason}
    end.
    
%%% @doc    尝试异步给在线玩家应用MFA(不在线则给游戏工作进程)
try_async_apply_to_online_player (PlayerId, M, F, A) ->
    try_async_apply_to_online_player(PlayerId, M, F, A, null).
try_async_apply_to_online_player (PlayerId, M, F, A, CallBack) when
    is_number(PlayerId) andalso
    is_atom(M) andalso is_atom(F) andalso is_list(A)
->
    TheCallBack = if
        is_tuple(CallBack)  -> {self(), CallBack};
        true                -> null
    end,
    try mod_online:async_apply_to_online_player(PlayerId, M, F, A, TheCallBack) of
        false ->
            put(do_work_param, {M, F, A}),
            if
                is_tuple(CallBack) ->
                    R = game_worker:do_work(M, F, A),
                    erase(do_work_param),
                    {CM, CF, CA} = CallBack,
                    try_apply(CM, CF, [R | CA]);
                true -> 
                    R = game_worker:async_do_work(M, F, A),
                    erase(do_work_param),
                    R
            end;
        Result ->
            Result
    catch
        _ : Reason ->
            {error, Reason}
    end.

%%% @doc    尝试应用MFA
try_apply (M, F, A) ->
    case catch apply(M, F, A) of
        {'EXIT', Reason} -> 
            ?ERROR(
                "try_apply:~n"
                "  {M, F, A} = {~p, ~p, ~p}~n"
                "  Reason    = ~p~n",
                [M, F, A, Reason]
            ),
            try_apply_failed;
        Result ->
            Result
    end.


% %%% @doc    获取键在记录的索引
% key_index_of_record (Key, Record) ->
%     RecordName  = element(1, Record),
%     FieldList   = record_info(fields, RecordName),    % 这个编译过不去
%     index_of_list_3(Element, FieldList, 2).

%%% @doc    获取元素在元组的索引
index_of_tuple (Element, Tuple) ->
    index_of_list_3(Element, tuple_to_list(Tuple), 1).


%%% @doc    获取元素在列表的索引
index_of_list (Element, List) ->
    index_of_list_3(Element, List, 1).

index_of_list_3 (Element, [Element | List], Index) ->
    Index;
index_of_list_3 (Element, [_ | List], Index) ->
    index_of_list_3(Element, List, Index + 1);
index_of_list_3 (_Element, [], _Index) ->
    0.









