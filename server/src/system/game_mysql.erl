-module (game_mysql).

-author     ("CHEONGYI").
-date       ({2018, 03, 13}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2018 YiSiXEr").

-behaviour (gen_server).

-export ([start_link/0]).
-export ([stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    start_link/5, start_link/6, start_link/9,

    %% 打印日志消息
    log/3, log/4
]).

-include("define.hrl").

-define (SERVER, ?MODULE).
-define (MYSQL_ID,       gamedb).
-define (MYSQL_HOST,     ?GET_ENV_STR(mysql_host,     "127.0.0.1")).
-define (MYSQL_PORT,     ?GET_ENV_INT(mysql_port,     3306)).
-define (MYSQL_USER,     ?GET_ENV_STR(mysql_user,     "root")).
-define (MYSQL_PASSWORD, ?GET_ENV_STR(mysql_password, "wlwlwl")).
-define (MYSQL_DATABASE, ?GET_ENV_STR(mysql_database, "yisixer")).
-define (MYSQL_POOLSIZE, ?GET_ENV_INT(mysql_poolsize, 1)).
-define (MYSQL_RECONNECT, false).
-define (MYSQL_LOG_FUN(),
    fun(Level, Message, Arguments) ->
        case Level of
            error -> ?ERROR(Message, Arguments);
            _     -> ?DEBUG(Message, Arguments);
            _     -> ok
        end
    end
).

-record (state, {
    conn_list   = [],   % [#mysql_connection{}]
    log_fun,            % undefined|function for logging
    gc_timer            % undefined|timer:tref()
}).
-record (mysql_connection, {
    id,         % term()    User of 'mysql' modules id of this socket group
    conn_pid,   % pid()     mysql_conn process
    reconnect,  % true|false    Should ?SERVER try to reconnect if this connection dies
    host,       % undefined|string()
    port,       % undefined|integer()
    user,       % undefined|string()
    password,   % undefined|string()
    database    % undefined|string()
}).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start_link() -> ServerRet.
%%% @doc    Start the process and link gen_server.
start_link () ->
    % LogFun = fun(Level, Message, Arguments) ->
    %     case Level of
    %         error -> ?ERROR(Message, Arguments);
    %         _     -> ok
    %     end
    % end,
    start_link(?MYSQL_ID, ?MYSQL_HOST, ?MYSQL_PORT, ?MYSQL_USER, ?MYSQL_PASSWORD, ?MYSQL_DATABASE, ?MYSQL_POOLSIZE, ?MYSQL_RECONNECT, ?MYSQL_LOG_FUN()).

start_link (Id, Host,       User, Password, Database) ->
    start_link(Id, Host, ?MYSQL_PORT, User, Password, Database, ?MYSQL_POOLSIZE, ?MYSQL_RECONNECT, ?MYSQL_LOG_FUN()).

start_link (Id, Host,       User, Password, Database, LogFun) when is_function(LogFun) ->
    start_link(Id, Host, ?MYSQL_PORT, User, Password, Database, ?MYSQL_POOLSIZE, ?MYSQL_RECONNECT, LogFun);
start_link (Id, Host, Port, User, Password, Database) ->
    start_link(Id, Host, Port,        User, Password, Database, ?MYSQL_POOLSIZE, ?MYSQL_RECONNECT, ?MYSQL_LOG_FUN()).

start_link (Id, Host, Port, User, Password, Database, PoolSize, Reconnect, LogFun) when
    is_list(Host)     andalso is_integer(Port)     andalso
    is_list(User)     andalso is_list(Password)    andalso
    is_list(Database) andalso is_integer(PoolSize)
->
    crypto:start(),
    Result = gen_server:start_link({local, ?SERVER}, ?MODULE, [Id, Host, Port, User, Password, Database, PoolSize, Reconnect, LogFun], []),
    ?INFO("Mysql: driver start with '~p' on ~s:~p use ~s~n", [Id, Host, Port, Database]),
    Result.

%%% @spec   stop() -> ok.
%%% @doc    Stop the process.
stop () ->
    gen_server:call(?SERVER, stop).


%%% @doc    打印日志消息
log (LogFun, Level, Message) ->
    log(LogFun, Level, Message, []).
log (LogFun, Level, Message, Arguments) when is_function(LogFun) ->
    LogFun(Level, Message, Arguments);
log (_LogFun, _Level, Message, Arguments) ->
    ?INFO(Message, Arguments).


%%% ========== ======================================== ====================
%%% gen_server 6 callbacks
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, State}.
%%% @doc    gen_server init, opens the server in an initial state.
init ([Id, Host, Port, User, Password, Database, PoolSize, Reconnect, LogFun]) ->
    case init_connect(Id, Host, Port, User, Password, Database, PoolSize, Reconnect, LogFun, []) of
        {ok, ConnList}  ->
            {ok, #state{conn_list = ConnList, log_fun = LogFun}};
        {error, InitReason} ->
            log(LogFun, error, "Mysql(1): ~p~nfailed start first MySQL connection handler, exit!~n", [InitReason]),
            {stop, {error, InitReason}}
    end.

%%% @spec   handle_call(Args, From, State) -> tuple().
%%% @doc    gen_server callback.
handle_call (stop, _From, State) ->
    {stop, shutdown, stopped, State};
handle_call (Request, From, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {call, Request, From}]),
    {reply, {error, badrequest}, State}.

%%% @spec   handle_cast(Cast, State) -> tuple().
%%% @doc    gen_server callback.
handle_cast (Request, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {cast, Request}]),
    {noreply, State}.

%%% @spec   handle_info(Info, State) -> tuple().
%%% @doc    gen_server callback.
handle_info (Info, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {info, Info}]),
    {noreply, State}.

%%% @spec   terminate(Reason, State) -> ok.
%%% @doc    gen_server termination callback.
terminate (Reason, _State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {terminate, Reason}]),
    ok.

%%% @spec   code_change(_OldVsn, State, _Extra) -> tuple().
%%% @doc    gen_server code_change callback (trivial).
code_change (_Vsn, State, _Extra) ->
    {ok, State}.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    初始化连接
init_connect (_Id, _Host, _Port, _User, _Password, _Database, 0, _Reconnect, _LogFun, ConnList) ->
    {ok, ConnList};
init_connect (Id, Host, Port, User, Password, Database, PoolSize, Reconnect, LogFun, ConnList) ->
    case game_mysql_conn:start_link(Host, Port, User, Password, Database, LogFun, self()) of
        {ok, ConnPid} ->
            MysqlConnection = #mysql_connection{
                id          = Id,
                conn_pid    = ConnPid,
                reconnect   = Reconnect,
                host        = Host,
                port        = Port,
                user        = User,
                password    = Password,
                database    = Database
            },
            case add_conn_monit(MysqlConnection, ConnList) of
                {ok, NewConnList} ->
                    log(LogFun, info, "Mysql: add connection with '~p' ~p and monit success.~n", [Id, ConnPid]),
                    init_connect(Id, Host, Port, User, Password, Database, PoolSize - 1, Reconnect, LogFun, NewConnList);
                AddReason ->
                    {error, AddReason}
            end;
        ConnReason ->
            ConnReason
    end.

%%% @doc    增加连接记录并监控进程
add_conn_monit (Conn, ConnList) when 
    is_record(Conn, mysql_connection) and is_list(ConnList) 
->
    monitor(process, Conn #mysql_connection.conn_pid),
    {ok, [Conn | ConnList]}.



