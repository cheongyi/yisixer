-module (game_mysql).

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 13}).
-vsn        ("1.0.0").

-behaviour (gen_server).

% -compile (export_all).
-export ([start_link/0, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    %% 启动进程
    start_link/5, start_link/6, start_link/9,
    fetch/2, fetch/3,                           % 发送一个Query并等待其结果
    %% 打印日志消息
    log/3, log/4,
    spiltbin_first_zero/2,                      % 分割字节中遇到的第一个0

    get_result_field_info/1,
    get_result_rows/1,
    get_result_affected_rows/1,
    get_result_reason/1,
    get_result_insert_id/1,

    get_state/0                                 % 获取进程状态数据
]).

-include("define.hrl").
-include("mysql.hrl").

-define (SERVER, ?MODULE).
-define (MYSQL_ID,       gamedb).
-define (MYSQL_HOST,     ?GET_ENV_STR(mysql_host,     "127.0.0.1")).
-define (MYSQL_PORT,     ?GET_ENV_INT(mysql_port,     3306)).
-define (MYSQL_USER,     ?GET_ENV_STR(mysql_user,     "root")).
-define (MYSQL_PASSWORD, ?GET_ENV_STR(mysql_password, "wlwlwl")).
-define (MYSQL_DATABASE, ?GET_ENV_STR(mysql_database, "farm")).
-define (MYSQL_POOLSIZE, ?GET_ENV_INT(mysql_poolsize, 1)).
-define (MYSQL_RECONNECT, false).
-define (MYSQL_LOG_FUN(),
    fun(Level, Message, Arguments) ->
        case Level of
            error -> ?ERROR(Message, Arguments);
            % _     -> ?INFO(Message, Arguments);
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

%%% @spec   start() -> ServerRet.
%%% @doc    Start the process.
start () ->
    gen_server:start({local, ?SERVER}, ?MODULE, [], []).

%%% @spec   stop() -> ok.
%%% @doc    Stop the process.
stop () ->
    gen_server:call(?SERVER, stop).

%%% @doc    获取进程状态数据
get_state () ->
    gen_server:call(?SERVER, get_state).


%%% @doc    启动进程
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
    ?INFO("Mysql: driver started id('~p') on ~s:~p use ~s ==~n", [Id, Host, Port, Database]),
    Result.

%%% @doc    发送一个Query并等待其结果
%%% @descrip    Send a query and wait for the result
fetch (Id, Query) when is_list(Query) ->
    fetch(Id, Query, infinity).
fetch (Id, Query, Timeout) when is_list(Query) ->
    gen_server:call(?SERVER, {fetch, Id, Query}, Timeout).

%%% @doc    打印日志消息
log (LogFun, Level, Message) ->
    log(LogFun, Level, Message, []).
log (LogFun, Level, Message, Arguments) when is_function(LogFun) ->
    LogFun(Level, Message, Arguments);
log (_LogFun, _Level, Message, Arguments) ->
    ?INFO(Message, Arguments).

%%% @doc    分割字节中遇到的第一个0
spiltbin_first_zero (<<0:8,       Rest/binary>>, List) ->
    {lists:reverse(List), Rest};
spiltbin_first_zero (<<Element:8, Rest/binary>>, List) ->
    spiltbin_first_zero(Rest, [Element | List]);
spiltbin_first_zero (<<>>, List) ->
    {lists:reverse(List), <<>>}.

get_result_field_info (MysqlResult) ->
    MysqlResult #mysql_result.field_info.
get_result_rows (MysqlResult) ->
    MysqlResult #mysql_result.rows.
get_result_affected_rows (MysqlResult) ->
    MysqlResult #mysql_result.affect_rows.
get_result_insert_id (MysqlResult) ->
    MysqlResult #mysql_result.insert_id.
get_result_reason (MysqlResult) ->
    MysqlResult #mysql_result.error.


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
            log(LogFun, error, "Mysql: init ~p~nfailed start first MySQL connection handler, exit!~n", [InitReason]),
            {stop, {error, InitReason}}
    end.

%%% @spec   handle_call(Args, From, State) -> tuple().
%%% @doc    gen_server callback.
handle_call({fetch, Id, Query}, From, State) ->
    log(State #state.log_fun, debug, "Mysql: fetch (~p): ~p~n", [Id, Query]),
    {ok, MysqlConn, RestOfConnList} = get_next_mysql_connection_for_id(Id, State #state.conn_list, []),
    game_mysql_conn:fetch(MysqlConn #mysql_connection.conn_pid, Query, From),
    NewConnList = RestOfConnList ++ [MysqlConn],
    {noreply, State #state{conn_list = NewConnList}};
handle_call (get_state, _From, State) ->
    {reply, State, State};
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

%%% @doc    获取对应ID的数据库连接
get_next_mysql_connection_for_id (Id, [#mysql_connection{id = Id} = MysqlConn | List], Res) ->
    {ok, MysqlConn, lists:reverse(Res) ++ List};
get_next_mysql_connection_for_id (Id, [MysqlConn | List], Res) when is_record(MysqlConn, mysql_connection) ->
    get_next_mysql_connection_for_id(Id, List, [MysqlConn | Res]);
get_next_mysql_connection_for_id (_Id, [], _Res) ->
    nomatch.


