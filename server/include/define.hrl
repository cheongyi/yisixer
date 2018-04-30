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
 

-define (GAME_LOG_DIR,  "./log/").          % 游戏日志存放路劲
-define (GAME_DATA_DIR, "./data/").         % 游戏数据存放路劲
-define (GAME_PERF_DIR,  ?GAME_DATA_DIR ++ "perf/").        % 游戏性能分析存放路劲
-define (WAR_REPORT_DIR, ?GAME_DATA_DIR ++ "war_report/").  % 战报数据存放路劲

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

%%% 时间相关
-define (MINUTE_TO_SECOND,  60).        % 分转秒
-define (HOUR_TO_MINUTE,    60).        % 时转分
-define (DAY_TO_HOUR,       24).        % 日转时
-define (WEEK_TO_DAY,       7).         % 周转天
-define (YEAR_TO_MONTH,     12).        % 年转月
-define (HOUR_TO_SECOND, ?MINUTE_TO_SECOND * ?HOUR_TO_MINUTE).  % 时转秒
-define (DAY_TO_SECOND,  ?DAY_TO_HOUR      * ?HOUR_TO_SECOND).  % 天转秒
-define (WEEK_TO_SECOND, ?WEEK_TO_DAY      * ?DAY_TO_SECOND).   % 周转秒

%%% 数据库相关
-define (DELETE_OR_TRUNCATE_ROWS, 10000).   % 逐条删除或清空重建行数判定
-define (INSERT_BATCH_ROWS, 100).           % 表数据插入分批行数
-define (SELECT_LIMIT_ROWS, 500000).        % 表数据查询限制行数
-define (LST_TO_BIN(List),  lib_misc:lst_to_bin(List)).
-define (INT_TO_BIN(Value), lib_misc:int_to_bin(Value)).
-define (REL_TO_BIN(Value), lib_misc:rel_to_bin(Value)).





%%% 四色牌相关
-define (CAN_WIN_CARD_LENGTH,  21).     % 可胡牌的卡牌长度
-define (CAN_WIN_HE_NUMBER_MIN, 9).     % 可胡牌的最小卡牌合数
-define (CRAD_COLOR_NUMBER_MAX, 4).     % 卡牌颜色数量最大数
-define (SAME_STYLE_NUMBER_MAX, 4).     % 相同样式数量最大数
-define (DIFF_STYLE_NUMBER_MAX, 7).     % 不同样式数量最大数
-define (CRAD_HAND_NUMBER_MAX, 20).     % 卡牌手牌数量最大数
-define (CARD_TOTAL_NUMBER,             % 卡牌总数
    ?CRAD_COLOR_NUMBER_MAX * ?SAME_STYLE_NUMBER_MAX * ?DIFF_STYLE_NUMBER_MAX).
-define (CARD_COLOR_YELLOW, yellow).    % 卡牌颜色-黄
-define (CARD_COLOR_RED,    red).       % 卡牌颜色-红
-define (CARD_COLOR_GREEN,  green).     % 卡牌颜色-青
-define (CARD_COLOR_WHITE,  white).     % 卡牌颜色-白
-define (CARD_COLOR_LIST,
    [?CARD_COLOR_YELLOW, ?CARD_COLOR_RED, ?CARD_COLOR_GREEN, ?CARD_COLOR_WHITE]
).
-define (CARD_STYLE_JIANG,  jiang).     % 卡牌样式-将
-define (CARD_STYLE_SHI,    shi).       % 卡牌样式-士
-define (CARD_STYLE_XIANG,  xiang).     % 卡牌样式-相
-define (CARD_STYLE_CHE,    che).       % 卡牌样式-车
-define (CARD_STYLE_MA,     ma).        % 卡牌样式-马
-define (CARD_STYLE_PAO,    pao).       % 卡牌样式-炮
-define (CARD_STYLE_BING,   bing).      % 卡牌样式-兵
-define (CARD_STYLE_LIST,
    [
        ?CARD_STYLE_JIANG, ?CARD_STYLE_SHI, ?CARD_STYLE_XIANG,
        ?CARD_STYLE_CHE,   ?CARD_STYLE_MA,  ?CARD_STYLE_PAO,
        ?CARD_STYLE_BING
    ]
).

-define (FOUR_COLOR_SRV,                   four_color_srv).     % 四色牌进程
-define (FOUR_COLOR_AUTO_SRV,         four_color_auto_srv).     % 四色牌自动进程
-define (FOUR_COLOR_PLAYER_SRV_A, four_color_player_srv_a).     % 四色牌玩家进程A
-define (FOUR_COLOR_PLAYER_SRV_B, four_color_player_srv_b).     % 四色牌玩家进程B
-define (FOUR_COLOR_PLAYER_SRV_C, four_color_player_srv_c).     % 四色牌玩家进程C
-define (FOUR_COLOR_PLAYER_SRV_D, four_color_player_srv_d).     % 四色牌玩家进程D
-define (FOUR_COLOR_PLAYER_SRV_LIST, 
    [
        ?FOUR_COLOR_PLAYER_SRV_A, 
        ?FOUR_COLOR_PLAYER_SRV_B, 
        ?FOUR_COLOR_PLAYER_SRV_C, 
        ?FOUR_COLOR_PLAYER_SRV_D
    ]
).




