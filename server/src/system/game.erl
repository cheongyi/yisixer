-module (game).

-author     ("CHEONGYI").
-date       ({2017, 11, 09}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2017 YiSiXEr").

-behaviour  (application).
-behaviour  (supervisor).

-export ([start/0, stop/0, restart/0]).
-export ([start/2, stop/1]).
-export ([init/1]).

-include("define.hrl").

-define (SERVER, ?MODULE).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    erl -s game start
start () ->
    application:start(?SERVER).

stop () ->
    stop(300, 1800).

restart () ->
    stop(),
    start().


%%% ========== ======================================== ====================
%%% callbacks  function
%%% ========== ======================================== ====================
start (_Type, _Args) ->
    Result = supervisor:start_link({local, ?SERVER}, ?MODULE, []),

    filelib:ensure_dir(?GAME_DATA_DIR),
    filelib:ensure_dir(?WAR_REPORT_DIR),

    % 启动inets服务
    inets:start(),

    % 启动game系统相关进程
    start_child(game_log,           worker),        % 启动进程 --- 日志
    start_child(game_perf,          worker),        % 启动进程 --- 性能分析
    start_child(game_ets,           worker),        % 启动进程 --- 游戏内ets
    % start_child(mysql,              worker),        % 启动进程 --- 游戏内mysql
    start_child(game_mysql,         worker),        % 启动进程 --- 游戏内mysql
    timer:sleep(1000),
    start_child(game_db_sync_sup,   supervisor),    % 启动督程 --- 游戏数据同步
    start_child(game_db_init_srv,   worker),        % 启动进程 --- 游戏数据库初始化
    game_db_init_srv:wait_for_loaded(),

    % start_child(socket_client_sup,  supervisor),    % 启动督程 --- 套接字客户端

    % 启动玩法功能相关进程
    start_child(test_sup,           supervisor),    % 启动督程 --- 测试
    start_child(four_color_sup,     supervisor),    % 启动督程 --- 四色牌

    % start_child(socket_server_sup,  supervisor),    % 启动督程 --- 套接字服务器

    start_child(reloader,           worker),        % 启动进程 --- 代码自动载入

    ?INFO("========== Game start ==========~n", []),
    Result.

stop (_State) ->
    ok.

init ([]) ->
    {ok, {{one_for_one, 10, 10}, []}}.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
stop (TimeOutOffline, TimeOutSync) ->
    % 中断socket链接
    % supervisor:terminate_child(?SERVER, socket_server_sup),
    % 踢掉在线玩家
    % mod_online:wait_all_online_player_exit(TimeOutOffline),
    % 等待数据写入
    game_db_sync_to_file:wait_for_all_data_sync(TimeOutSync),
    game_db_sync_to_db:wait_for_all_data_sync(TimeOutSync),
    % 关闭应用game
    application:stop(?SERVER).

%%% @doc    动态启动game的子进程
start_child (Module, Type) ->
    Shutdown = case Type of
        worker      -> ?SHUTDOWN_WORKER;
        supervisor  -> ?SHUTDOWN_SUPERVISOR
    end,
    start_child(Module, Module, Shutdown, Type).
start_child (ChildId, Module, Type) ->
    Shutdown = case Type of
        worker      -> ?SHUTDOWN_WORKER;
        supervisor  -> ?SHUTDOWN_SUPERVISOR
    end,
    start_child(ChildId, Module, Shutdown, Type).
start_child (ChildId, Module, Shutdown, Type) ->
    StartFunc   = {Module, start_link, []},
    Restart     = permanent,
    Modules     = [Module],
    ChildSpecification  = {ChildId, StartFunc, Restart, Shutdown, Type, Modules},
    SupervisorName      = ?SERVER,
    {ok, _}     = supervisor:start_child(SupervisorName, ChildSpecification).




