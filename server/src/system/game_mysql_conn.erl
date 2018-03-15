-module (game_mysql_conn).

-author     ("CHEONGYI").
-date       ({2018, 03, 13}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2018 YiSiXEr").

-behaviour (gen_server).

-export ([start_link/7]).
-export ([stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    get_state/0
]).

-include ("define.hrl").
-include ("record.hrl").

-define (SERVER, ?MODULE).
-define (MYSQL_4_0, 40). %% Support for MySQL 4.0.x
-define (MYSQL_4_1, 41). %% Support for MySQL 4.1.x et 5.0.x

-record (state, {
    parent,
    socket,
    user,       % undefined|string()
    password,   % undefined|string()
    log_fun,
    data    = <<>>,
    recv_pid,
    mysql_version
}).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start_link() -> ServerRet.
%%% @doc    Start the process and link gen_server.
start_link (Host, Port, User, Password, Database, LogFun, Parent) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [Host, Port, User, Password, Database, LogFun, Parent], []).

%%% @spec   stop() -> ok.
%%% @doc    Stop the process.
stop () ->
    gen_server:call(?SERVER, stop).

get_state () ->
    gen_server:call(?SERVER, get_state).

%%% ========== ======================================== ====================
%%% gen_server 6 callbacks
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, State}.
%%% @doc    gen_server init, opens the server in an initial state.
init ([Host, Port, User, Password, Database, LogFun, Parent]) ->
    {ok, RecvPid} = game_mysql_recv:start_link(Host, Port, LogFun, self()),
    State = #state{
        parent          = Parent,
        % socket          = Sock,
        user            = User,
        password        = Password,
        log_fun         = LogFun,
        recv_pid        = RecvPid,
        mysql_version   = undefined
    },
    {ok, State}.

%%% @spec   handle_call(Args, From, State) -> tuple().
%%% @doc    gen_server callback.
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
handle_info ({mysql_recv, RecvPid, data,   Packet, Num}, State = #state{recv_pid = RecvPid}) ->
    mysql:log(State #state.log_fun, info, "mysql_conn: Received MySQL data when not expecting any ~p"
            "(num ~p) - ignoring it", [Packet, Num]),
    {noreply, State};
handle_info ({mysql_recv, RecvPid, socket, Sock},        State = #state{recv_pid = RecvPid}) ->
    User        = State #state.user,
    Password    = State #state.password,
    LogFun      = State #state.log_fun,
    {ok, MysqlVersion} = mysql_init(Sock, RecvPid, User, Password, LogFun),
    {noreply, State #state{socket = Sock, mysql_version = MysqlVersion}};
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
mysql_init (Sock, RecvPid, User, Password, LogFun) ->
    {ok, ?MYSQL_4_1}.



