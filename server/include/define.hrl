-ifdef (debug).
    -define (IS_DEBUG,          true).
    -define (DEBUG(Msg, Args), 
        io:format(
            "[Debug]=T=~w=P=~-12w=L=~-4w=M=~-32.32. w~n" ++ Msg, 
            [?MODULE, ?LINE, get(the_player_id), erlang:localtime() | Args]
        )
    ).
    -define (FORMAT(Msg, Args), io:format(Msg, Args)).
-else.
    -define (IS_DEBUG,          false).
    -define (DEBUG(Msg,  Args), ok).
    -define (FORMAT(Msg, Args), ok).
-endif.


-define (GAME_LOG_DIR, "./log/").       % 错误日志存放路劲
-define (DATA_DIR, "./data/").          % 游戏数据存放路劲
-define (WAR_REPORT_DIR, ?DATA_DIR ++ "war_report/").   % 战报数据存放路劲

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

%%% 时间相关
-define (DAY_SECONDS, 86400).           % 一天的秒数
-define (WEEK_DAY_NUMBER, 7).           % 一周的天数
-define (WEEK_SECONDS, ?WEEK_DAY_NUMBER * ?DAY_SECONDS).    % 一周的秒数





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




