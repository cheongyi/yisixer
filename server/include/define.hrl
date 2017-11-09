-ifdef (debug).
    -define (IS_DEBUG,          true).
    -define (DEBUG(Msg, Args), 
        io:format(
            "[debug] - from player:~p ~p(~p) ~p~n" ++ Msg, 
            [?MODULE, ?LINE, erlang:localtime() | Args]
        )
    ).
    -define (FORMAT(Msg, Args), io:format(Msg, Args)).
-else.
    -define (IS_DEBUG,          false).
    -define (DEBUG(Msg,  Args), ok).
    -define (FORMAT(Msg, Args), ok).
-endif.


-define (GAME_LOG_DIR, "./log/").
-define (DATA_DIR, "./data/").
-define (WAR_REPORT_DIR, ?DATA_DIR ++ "war_report/").

-define (SHUTDOWN_WORKER,       16#ABCDEF0).        % 一个工作进程将怎样被终止
-define (SHUTDOWN_SUPERVISOR,   infinity).          % 一个监督进程将怎样被终止


%% 日志写入
-define (INFO(Msg,    Args), game_log:write(info,    Msg, Args)).
-define (ERROR(Msg,   Args), game_log:write(error,   Msg, Args)).
-define (WARNING(Msg, Args), game_log:write(warning, Msg, Args)).


%% 获取应用环境变量值
-define (GET_ENV(Key, Default),     (
    case application:get_env(Key) of
        {ok, Val} -> Val;
        undefined -> Default
    end
)).
-define (GET_ENV_STR(Key, Default), (
    case application:get_env(Key) of
        {ok, Val} when is_list(Val)     -> Val;
        {ok, Val} when is_atom(Val)     -> atom_to_list(Val);
        {ok, Val} when is_integer(Val)  -> integer_to_list(Val);
        undefined                       -> Default
    end
)).
-define (GET_ENV_INT(Key, Default), (
    case application:get_env(Key) of
        {ok, Val} when is_integer(Val)  -> Val;
        {ok, Val} when is_list(Val)     -> list_to_integer(Val);
        {ok, Val} when is_atom(Val)     -> list_to_integer(atom_to_list(Val));
        undefined                       -> Default
    end
)).
-define (GET_ENV_ATOM(Key, Default),(
    case application:get_env(Key) of
        {ok, Val} when is_atom(Val)     -> Val;
        {ok, Val} when is_list(Val)     -> list_to_atom(Val);
        {ok, Val} when is_integer(Val)  -> list_to_atom(integer_to_list(Val));
        undefined                       -> Default
    end
)).