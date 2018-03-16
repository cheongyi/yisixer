-module (game_mysql_conn).

-author     ("CHEONGYI").
-date       ({2018, 03, 13}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2018 YiSiXEr").

-behaviour (gen_server).

-compile (export_all).
-export ([start_link/7, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    get_state/0
]).

-include ("define.hrl").
-include ("record.hrl").

-define (SERVER, ?MODULE).
-define (SECURE_CONNECTION, 32768).
-define (MYSQL_4_0, 40). %% Support for MySQL 4.0.x
-define (MYSQL_4_1, 41). %% Support for MySQL 4.1.x et 5.0.x

-record (state, {
    mysql_pid,
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
start_link (Host, Port, User, Password, Database, LogFun, MysqlPid) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [Host, Port, User, Password, Database, LogFun, MysqlPid], []).

%%% @spec   start() -> ServerRet.
%%% @doc    Start the process.
start () ->
    gen_server:start({local, ?SERVER}, ?MODULE, [], []).

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
init ([Host, Port, User, Password, Database, LogFun, MysqlPid]) ->
    {ok, RecvPid} = game_mysql_recv:start_link(Host, Port, LogFun, self()),
    State = #state{
        mysql_pid       = MysqlPid,
        % socket          = Socket,
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
    game_mysql:log(State #state.log_fun, info, "mysql_conn: Received MySQL data when not expecting any ~p"
            "(num ~p) - ignoring it", [Packet, Num]),
    {noreply, State};
handle_info ({mysql_recv, RecvPid, socket, Socket},      State = #state{recv_pid = RecvPid}) ->
    User        = State #state.user,
    Password    = State #state.password,
    LogFun      = State #state.log_fun,
    {ok, MysqlVersion} = mysql_init(RecvPid, Socket, User, Password, LogFun),
    {noreply, State #state{socket = Socket, mysql_version = MysqlVersion}};
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
mysql_init (RecvPid, Socket, User, Password, LogFun) ->
    case do_recv(RecvPid, undefined, LogFun) of
        {ok, Packet, InitSeqNum} ->
            {Version, Salt1, Salt2, Caps} = greeting(Packet, LogFun),
            AuthResp = case Caps band ?SECURE_CONNECTION of
                ?SECURE_CONNECTION ->
                    game_mysql_auth:do_new_auth(RecvPid, Socket, InitSeqNum + 1, User, Password, Salt1, Salt2, LogFun);
                _ ->
                    game_mysql_auth:do_old_auth(RecvPid, Socket, InitSeqNum + 1, User, Password, Salt1, LogFun)
            end,
            case AuthResp of
                {ok, <<0:8, _Rest/binary>>, _RecvSeqNum} ->
                    {ok, Version};
                {ok, <<255:8, Code:16/little, Message/binary>>, _RecvNum} ->
                    game_mysql:log(LogFun, error, 
                        "mysql_conn: init error ~p: ~p~n", [Code, binary_to_list(Message)]),
                    {error, binary_to_list(Message)};
                {ok, RecvPacket, _RecvNum} ->
                    game_mysql:log(LogFun, error, 
                        "mysql_conn: init unknown error ~p~n", [binary_to_list(RecvPacket)]),
                    {error, binary_to_list(RecvPacket)};
                {error, Reason} ->
                    game_mysql:log(LogFun, error, 
                        "mysql_conn: init failed receiving data : ~p~n", [Reason]),
                    {error, Reason}
            end;
        {error, Format, _Reason} ->
            {error, Format}
    end.

do_send (Socket, Data, Num, LogFun) ->
    Packet = <<(size(Data)):24/little, Num:8, Data/binary>>,
    game_mysql:log(LogFun, debug, "Mysql: send packet ~p: ~p", [Num, Packet]),
    gen_tcp:send(Socket, Packet).

do_recv (RecvPid, undefined, LogFun) ->
    receive
        {mysql_recv, RecvPid, data,   Packet, ResponseNum} ->
            {ok, Packet, ResponseNum};
        {mysql_recv, RecvPid, closed, Reason} ->
            {error, "mysql_recv: socket was closed~n", Reason}
    end;
do_recv (RecvPid, SequenceNum, LogFun) ->
    ResponseNum = SequenceNum + 1,
    receive
        {mysql_recv, RecvPid, data,   Packet, ResponseNum} ->
            {ok, Packet, ResponseNum};
        {mysql_recv, RecvPid, closed, Reason} ->
            {error, "mysql_recv: socket was closed~n", Reason}
    end.

%%% @doc    解析初始化连接数据库后返回的招呼
greeting (Packet, LogFun) ->
    <<Protocol:8,         RestProtocol/binary>> = Packet,
    {Version, RestVersion}  = spilt_first_zero(RestProtocol),
    <<ThreadId:32/little, RestThreadId/binary>> = RestVersion,
    {Salt1,   RestSalt1}    = spilt_first_zero(RestThreadId),
    <<Caps:16/little,     RestCaps/binary>>     = RestSalt1,
    <<Server:16/binary-unit:8, RestServer/binary>> = RestCaps,
    {Salt2,   RestSalt2}    = spilt_first_zero(RestServer),
    game_mysql:log(LogFun, debug, 
        "mysql_conn: greeting Packet:~p Protocol:~p Version:~p ThreadId:~p Salt1:~p Caps:~p Server:~p Salt2:~p RestSalt2:~p",
        [Packet, Protocol, Version, ThreadId, Salt1, Caps, Server, Salt2, spilt_first_zero(RestSalt2)]
    ),
    {normalize_version(Version, LogFun), Salt1, Salt2, Caps}.

%%% @doc    分割数据中遇到的第一个0
spilt_first_zero (Data) when is_binary(Data) ->
    game_mysql:spiltbin_first_zero(Data, []);
spilt_first_zero (Data) when is_list(Data) ->
    {String, [0 | Rest]} = lists:splitwith(fun(Element) ->Element /= 0 end, Data),
    {String, Rest}.

%%% @doc    标准化版本
normalize_version([$4, $., $0 | _T], LogFun) ->
    mysql:log(LogFun, debug, "Switching to MySQL 4.0.x protocol.~n"),
    ?MYSQL_4_0;
normalize_version([$4, $., $1 | _T], _LogFun) ->
    ?MYSQL_4_1;
normalize_version([$5 | _T], LogFun) ->
    mysql:log(LogFun, debug, "Switching to MySQL 4.1.x protocol.~n"),
    %% MySQL version 5.x protocol is compliant with MySQL 4.1.x:
    ?MYSQL_4_1;
normalize_version(_Other, LogFun) ->
    mysql:log(LogFun, error, "MySQL version not supported: MySQL Erlang module might not work correctly.~n"),
    %% Error, but trying the oldest protocol anyway:
    ?MYSQL_4_0.














