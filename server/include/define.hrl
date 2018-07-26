-ifdef (debug).
    -define (IS_DEBUG,          true).
    -define (DEBUG(Msg, Args), 
        io:format(
            "~n==DEBUG== LINE:~-4wMODULE:~-20wPLAYER:~-12wTIME:~w~n========= " ++ Msg, 
            [?LINE, ?MODULE, get(the_player_id), erlang:localtime() | Args]
        )
    ).
    -define (FORMAT(Msg, Args), io:format(Msg, Args)).
    -define (FORMAT(Msg),       io:format(Msg)).
    % -define (CATCH(Fun), catch Fun()).
    -define (CATCH(Fun), Fun()).
-else.
    -define (IS_DEBUG,          false).
    -define (DEBUG(Msg,  Args), ok).
    -define (FORMAT(Msg, Args), ok).
    -define (FORMAT(Msg),       ok).
    -define (CATCH(Fun), catch Fun()).
-endif.
 

-define (GAME_LOG_DIR,  "./log/").          % 游戏日志存放路径
-define (GAME_DATA_DIR, "./data/").         % 游戏数据存放路径
-define (GAME_TIMER_DIR, ?GAME_DATA_DIR ++ "timer/").       % 游戏定时器存放路径
-define (GAME_PROF_DIR,  ?GAME_DATA_DIR ++ "prof/").        % 游戏性能分析存放路径
-define (WAR_REPORT_DIR, ?GAME_DATA_DIR ++ "war_report/").  % 战报数据存放路径

-define (SHUTDOWN_PLAYER,       36#14X2).           % 一个玩家进程将怎样被终止
-define (SHUTDOWN_WORKER,       16#ABCDEF0).        % 一个工作进程将怎样被终止
-define (SHUTDOWN_SUPERVISOR,   infinity).          % 一个监督进程将怎样被终止
-define (WORKER_CHILD_SPEC(Module),                 % 工作进程的子规程
    {Module, {Module, start_link, []}, transient, ?SHUTDOWN_WORKER, worker, [Module]}
).


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

%%% 加密处理
-define (HASH_SHA(Data),             crypto:hash(sha, Data)).
-define (HASH_FINAL(Context),        crypto:hash_final(Context)).
-define (HASH_UPDATE(Context, Salt), crypto:hash_update(Context, Salt)).
-define (HASH_INIT(),                crypto:hash_init(sha)).
-define (PACKET_HEAD, 0).   % 协议包头


%%% 时间相关
-define (MINUTE_TO_SECOND,  60).        % 分转秒
-define (HOUR_TO_MINUTE,    60).        % 时转分
-define (DAY_TO_HOUR,       24).        % 日转时
-define (WEEK_TO_DAY,       7).         % 周转天
-define (YEAR_TO_MONTH,     12).        % 年转月
-define (HOUR_TO_SECOND,    ?MINUTE_TO_SECOND * ?HOUR_TO_MINUTE).  % 时转秒
-define (DAY_TO_SECOND,     ?DAY_TO_HOUR      * ?HOUR_TO_SECOND).  % 天转秒
-define (WEEK_TO_SECOND,    ?WEEK_TO_DAY      * ?DAY_TO_SECOND).   % 周转秒
-define (SLEEP(TimeOut),    receive after TimeOut -> ok end).
-define (TIMER(Data),       game_timer:write(Data)).    % 记录定时器
-define (CHECK_CLIENT_TIME,    50000).
-define (GEN_SERVER_TIME_OUT,   5000).  % gen_server 超时时间
-define (KICKOUT_PLAYER_TIMEOUT, 300).  % 踢出玩家超时时间(秒)


%%% 数据库相关
-define (DELETE_OR_TRUNCATE_ROWS, 10000).   % 逐条删除或清空重建行数判定
-define (INSERT_BATCH_ROWS, 100).           % 表数据插入分批行数
-define (SELECT_LIMIT_ROWS, 500000).        % 表数据查询限制行数
-define (LST_TO_BIN(List),  lib_misc:lst_to_bin(List)).
-define (INT_TO_BIN(Value), lib_misc:int_to_bin(Value)).
-define (REL_TO_BIN(Value), lib_misc:rel_to_bin(Value)).
-define (TRAN_LOG_LIST,     tran_log_list).     % 事务日志列表
-define (TRAN_ACTION_LIST,  tran_action_list).  % 事务动作列表

-define (ETS_TAB(Table),            game_db_table:ets_tab(Table)).          % 数据库表对应的ets table name
-define (ETS_TAB(Table, FragId),    game_db_table:ets_tab(Table, FragId)).  % 数据库表对应的ets table name

-define (INGOT_OP_REASON,   ingot_op_reason).   % 金币操作原因
-define (GKEY_OP_REASON,     gkey_op_reason).   % 金钥操作原因

%% 比率参数
-define (PARAMETER,         10000).
-define (INIT_PACK_EXPAND_ID,   1).             % 初始仓库扩容ID


%%% 玩家相关
-define (THE_PLAYER_ID,      the_player_id).    % 玩家进程字典Key - 玩家ID
-define (PLAYER_NICKNAME_MIN_LENGTH,    04).    % 玩家昵称最小长度，字节：一个汉字相当于2字节
-define (PLAYER_NICKNAME_MAX_LENGTH,    14).    % 玩家昵称最大长度，字节：一个汉字相当于2字节

%% 封号类型
-define (ADMIN_DISLOGIN,         0).    % 后台封号
-define (ABNORMAL_DISLOGIN,      1).    % 外挂封号
-define (MOVE_TO_ANOTHER_SERVER, 2).    % 迁服




