-module (game_mysql_recv).

-author     ("CHEONGYI").
-date       ({2018, 03, 13}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2018 YiSiXEr").

-behaviour (gen_server).

% -compile (export_all).
-export ([start_link/4, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    get_state/0                                 % 获取进程状态数据
]).

-include ("define.hrl").
% -include ("record.hrl").

-define (SERVER, ?MODULE).

-record (state, {
    conn_pid,
    socket,
    log_fun,
    data    = <<>>
}).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start_link() -> ServerRet.
%%% @doc    Start the process and link gen_server.
start_link (Host, Port, LogFun, ConnPid) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [Host, Port, LogFun, ConnPid], []).

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


%%% ========== ======================================== ====================
%%% gen_server 6 callbacks
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, State}.
%%% @doc    gen_server init, opens the server in an initial state.
init ([Host, Port, LogFun, ConnPid]) ->
    {ok, Sock} = gen_tcp:connect(Host, Port, [binary, {packet, 0}]),
    ConnPid ! {mysql_recv, self(), socket, Sock},
    State = #state{
        conn_pid    = ConnPid,
        socket      = Sock,
        log_fun     = LogFun
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
handle_info ({tcp,        Sock, InData}, State = #state{socket = Sock}) ->
    Data    = list_to_binary([State #state.data, InData]),
    NewData = send_packet(State #state.conn_pid, Data),
    {noreply, State #state{data = NewData}};
handle_info ({tcp_error,  Sock, Reason}, State = #state{socket = Sock}) ->
    game_mysql:log(State #state.log_fun, error, "mysql_recv: Socket ~p tcp_error.~n", [Sock]),
    {stop, {tcp_error, Reason}, State};
handle_info ({tcp_closed, Sock},         State = #state{socket = Sock}) ->
    game_mysql:log(State #state.log_fun, error, "mysql_recv: Socket ~p tcp_closed.~n", [Sock]),
    {stop, normal, State};
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
%%% @doc    Send data to conn_pid if we have enough data
send_packet (ConnPid, <<Len:24/little, Num:8, Data/binary>>) when
    Len =< size(Data)
->
    {Packet, Rest} = split_binary(Data, Len),
    ConnPid ! {mysql_recv, self(), data, Packet, Num},
    send_packet(ConnPid, Rest);
send_packet (_Parent, Date) ->
    Date.




