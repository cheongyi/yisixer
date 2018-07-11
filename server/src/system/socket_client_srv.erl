-module (socket_client_srv).

%%% @doc    玩家进程

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 04, 25}).
-vsn        ("1.0.0").

-behaviour  (gen_server).

% -compile(export_all).
-export ([start_link/0, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    set_socket/2,               % 设置套接字，一些选项和控制进程
    apply/4, 
    async_apply/4,
    async_apply/5,
    apply_after/2, 
    apply_after_cancel/1, 
    kill_for_game_stop/1, 
    is_player_proc/0,
    is_player_proc/1,

    get_sock/1,
    get_state/0
]).

-define (SERVER, ?MODULE).

% -record (state, {}).

-include ("define.hrl").
-include ("record.hrl").
% -include ("gen/game_db.hrl").
% -include ("api/api_code.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start_link() -> ServerRet.
%%% @doc    Start the process and link gen_server.
start_link () ->
    gen_server:start_link(?MODULE, [], []).

%%% @spec   start() -> ServerRet.
%%% @doc    Start the process.
start () ->
    gen_server:start(?MODULE, [], []).

%%% @spec   stop() -> ok.
%%% @doc    Stop the process.
stop () ->
    gen_server:call(?SERVER, stop).

get_state () ->
    gen_server:call(?SERVER, get_state).

get_sock (Player) ->
    Player ! {self(), get_sock},
    receive
        ClientState ->
            ClientState
    after ?GEN_SERVER_TIME_OUT ->
        time_out
    end.


%%% ========== ======================================== ====================
%%% callback
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, ClientState}.
%%% @doc    gen_server init, opens the server in an initial state.
init ([]) ->
    {ok, #client_state{}}.

%%% @spec   handle_call(Args, From, ClientState) -> tuple().
%%% @doc    gen_server callback.
handle_call (get_state, _From, ClientState) ->
    {reply, ClientState, ClientState};
handle_call (stop, _From, ClientState) ->
    {stop, shutdown, stopped, ClientState};
handle_call (Request, From, ClientState) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {call, Request, From}]),
    {reply, {error, badrequest}, ClientState}.

%%% @spec   handle_cast(Cast, ClientState) -> tuple().
%%% @doc    gen_server callback.
handle_cast ({go, Socket}, _ClientState) ->
    ClientState = start_connection(Socket),
    lib_misc:get_socket_ip_and_port(Socket),
    case catch main_loop(ClientState) of
        {'EXIT', R} -> ?ERROR("main_loop: ~p~n", [R]);
        _           -> ok
    end,
    [{messages, MessageList}] = process_info(self(), [messages]),
    proc_message_queue(MessageList),
    {stop, normal, ClientState};
handle_cast (Request, ClientState) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {cast, Request}]),
    {noreply, ClientState}.

%%% @spec   handle_info(Info, ClientState) -> tuple().
%%% @doc    gen_server callback.
handle_info (Info, ClientState) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {info, Info}]),
    {noreply, ClientState}.

%%% @spec   terminate(Reason, ClientState) -> ok.
%%% @doc    gen_server termination callback.
terminate (Reason, _ClientState) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {terminate, Reason}]),
    ok.

%%% @spec   code_change(_OldVsn, ClientState, _Extra) -> tuple().
%%% @doc    gen_server code_change callback (trivial).
code_change (_Vsn, ClientState, _Extra) ->
    {ok, ClientState}.


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%% @todo   设置套接字，一些选项和控制进程
set_socket (Pid, Socket) ->
    inet:setopts(Socket, [
        {active, false},
        {delay_send, true},
        {packet_size, 1024 * 1024}
    ]),
    ok = gen_tcp:controlling_process(Socket, Pid),
    gen_server:cast(Pid, {go, Socket}).

%%% @doc    尝试应用
try_apply (State, M, F, A) ->
    case catch apply(M, F, A) of
        {'EXIT', Reason} ->
            ?ERROR(
                "try_apply: ~n"
                "    Pid       = ~p~n"
                "    {M, F, A} = ~p~n"
                "    Reason    = ~p~n", 
                [self(), {M, F, A}, Reason]
            ),
            {failed, {'EXIT', Reason}};
        Result ->
            try_notify_player(State),
            {ok, Result}
    end.

%%% @doc    尝试通知玩家
try_notify_player (#client_state{player_id = 0}) ->
    ok;
try_notify_player (#client_state{player_id = undefined}) ->
    ok;
try_notify_player (#client_state{player_id = PlayerId}) ->
    case catch api_player:try_send_player_data_notify(PlayerId) of
        {'EXIT', Reason} ->
            ?ERROR(
                "try_notify_player: ~n"
                "    Pid = ~p, Reason = ~p~n",
                [self(), Reason]
            );
        _ ->
            ok
    end.

%%% @doc    应用给进程
apply (Pid, M, F, A) ->
    SelfPid = self(),
    if
        Pid =:= SelfPid ->
            exit({apply_to_self, M, F, A});
        true ->
            Pid ! {apply, self(), M, F, A},
            receive
                {failed, Reason} -> Reason;
                {ok,     Result} -> Result
            after 3000 ->
                apply_time_out
            end
    end.

%%% @doc    异步应用给进程
async_apply (Pid, M, F, A) ->
    async_apply(Pid, M, F, A, null).
async_apply (Pid, M, F, A, CallBack) ->
    SelfPid = self(),
    if
        Pid =:= SelfPid ->
            exit({async_apply_to_self, M, F, A});
        true ->
            Pid ! {async_apply, M, F, A, CallBack},
            ok
    end.

%%% @doc    异步应用操作
do_async_apply (State, M, F, A, CallBack) ->
    {_, Result} = try_apply(State, M, F, A),
    case CallBack of
        null -> Result;
        {Pid, {CallBackM, CallBackF, CallBackA}} ->
            Pid ! {async_apply_call_back, {CallBackM, CallBackF, [Result | CallBackA]}}
    end.

%%% @doc    定时应用
apply_after (DelayTime, {M, F, A}) ->
    TimerRef = lib_misc:send_after(DelayTime, self(), {apply_after, M, F, A}),
    {apply_after_ref, TimerRef}.

%%% @doc    游戏关闭杀死玩家进程
kill_for_game_stop (Pid) ->
    Pid ! kill_for_game_stop. 

%%% @doc    取消定时应用
apply_after_cancel ({apply_after_ref, TimerRef}) ->
    erlang:cancel_timer(TimerRef).

%% 是否玩家进程
is_player_proc () ->
    ThePlayerId = lib_misc:get_player_id(),
    is_integer(ThePlayerId) andalso ThePlayerId > 0.

is_player_proc (PlayerId) ->
    PlayerId =:= lib_misc:get_player_id().


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    开始连接
start_connection (Socket) ->
    {ok, Sender}    = socket_client_sender:start_link(Socket, self()),
    SenderMonitor   = erlang:monitor(process, Sender),
    set_process_dict(start_conn_time),
    % erlang:send_after(?CHECK_CLIENT_TIME, self(), {check_client}),
    InitState       = #client_state{sock = Socket, sender = Sender, sender_monitor = SenderMonitor},
    NewState        = send_flash_policy(Socket, InitState),
    % erlang:send_after(?CHECK_CLIENT_TIME, self(), {check_client}),
    NewState.

%% @todo   发送Flash策略
send_flash_policy (Socket, State) ->
    case inet:peername(Socket) of
        {ok, {Address, _Port}} ->
            if
                Address == {127, 0, 0, 1} ->
                    wait_for_start(Socket, State);
                    % State;
                true ->
                    wait_for_start(Socket, State)
            end;
        _ ->
            State
    end.

%% @todo   等待启动
wait_for_start (Socket, State) ->
    inet:setopts(Socket, [{packet, 0}, {active, once}]),
    receive
        {check_client} ->
            State;
        {tcp, Socket, Request} ->
            ?DEBUG("~p, ~p, ~p~n", [?LINE, self(), Request]),
            case Request of
                <<1:8>> ->
                    gen_tcp:send(Socket, Request),
                    State;
                % <<"<policy-file-request/>", 0>>
                % <<$<, $p, $o, $l, $i, $c, $y, $-, $f, $i, $l, $e, $-, $r, $e, $q, $u, $e, $s, $t, $/, $>, 0>>
                <<60,112,111,108,105,99,121,45,102,105,108,101,45,114,101,113,117,101,115,116,47,62,0>> ->
                    gen_tcp:send(Socket, <<"<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>\0">>),
                    State;
                _ ->
                    handshake_or_request(Socket, Request, State)
            end;
        _ ->
            wait_for_start(Socket, State)
    end.

%% @todo   握手或者请求
handshake_or_request (Socket, RequestBin, State) ->
    RequestStr = binary_to_list(RequestBin),
    case string:str(RequestStr, "Upgrade: websocket") of
        0 ->
            ?DEBUG("~p, ~p~n", [?LINE, RequestStr]),
            inet:setopts(Socket, [{packet, ?PACKET_HEAD}]),
            <<_PackSize:4/binary, Pack/binary>> = RequestBin,
            case try_route_request(Pack, State) of
                error    -> clean(try_route_request_error_1, State), State;
                NewState -> NewState
            end;
        _ ->
            % ?DEBUG("~p, ~p~n", [?LINE, RequestStr]),
            Accept          = get_handshake_accept(RequestStr),
            HandshakeReturn = [
                "HTTP/1.1 101 Switching Protocols\r\n",
                "Connection: Upgrade\r\n",
                "Upgrade: WebSocket\r\n",
                "Sec-WebSocket-Accept: ", Accept, "\r\n",
                "\r\n"
            ],
            % ?DEBUG("~p, ~p~n", [?LINE, HandshakeReturn]),
            gen_tcp:send(Socket, list_to_binary(HandshakeReturn)),
            State
    end.

%% @todo   获取握手的Accept
%% @remark 如果需要请注意大小写
get_handshake_accept (RequestStr) ->
    get_handshake_accept_bin(string:tokens(RequestStr, "\r\n")).
get_handshake_accept_bin (["Sec-WebSocket-Key: " ++  Key | _RequestList]) ->
    KeyBin = list_to_binary(Key),
    base64:encode(?HASH_SHA(<<KeyBin/binary, "258EAFA5-E914-47DA-95CA-C5AB0DC85B11">>));
get_handshake_accept_bin ([_ | RequestList]) ->
    get_handshake_accept_bin(RequestList);
get_handshake_accept_bin ([]) ->
    <<"">>.


%% @todo   尝试路由请求
try_route_request (Request, State) ->
    case catch game_router:route_request(Request, State) of
        NewState = #client_state{} ->
            try_notify_player(NewState),
            NewState;
        {'EXIT', {tcp_send_error, Reason}} ->
            handle_request_error(Request, {tcp_send_error, Reason}, State),
            error;
        {'EXIT', Reason} ->
            handle_request_error(Request, Reason, State);
        Reason when is_atom(Reason) ->
            handle_request_error(Request, {atom_result, Reason}, State);
        Result ->
            handle_request_error(Request, {unknow_result, Result}, State)
    end.

%% @todo   处理请求错误
handle_request_error (Request, Reason, State) ->
    LastTime = get(last_error_time),
    {LocalTime, _} = statistics(wall_clock),
    if
        LastTime == undefined orelse
        LocalTime - LastTime > 1000 ->
            put(last_error_time, LocalTime),
            ?ERROR(
                "try_route_request: ~n"
                "    Pid      = ~p~n"
                "    Request  = ~p~n"
                "    Reason   = ~p~n"
                "    PlayerId = ~p~n", 
                [self(), Request, Reason, State #client_state.player_id]
            ),
            State;
        true ->
            error
    end.

main_loop (State = #client_state{player_id = PlayerId, sock = Socket, sender = Sender, sender_monitor = SenderMon}) ->
    put(state, State),
    inet:setopts(Socket, [{packet, ?PACKET_HEAD}, {active, once}]),
    % inet:setopts(Socket, [{packet, 4}, {active, once}]),
    receive
        {check_client} ->
            if
                is_number(PlayerId) andalso PlayerId > 0 ->
                    main_loop(State);
                true ->
                    exit({invalid_client, inet:peername(Socket)})
            end;
        %% 0x2：表示这是一个二进制帧（frame）
        {tcp, Socket, <<1:1, 0:3, 2:4, _Rest/binary>> = Request} ->
            ?DEBUG("~p, ~p~n", [?LINE, Request]),
            <<_RequestLen:16, UnMaskRequest/binary>> = websocket_data(Request),
            case try_route_request(UnMaskRequest, State) of
                error    -> 
                    clean(try_route_request_error_2, State);
                NewState -> 
                    put(state, NewState), 
                    main_loop(NewState)
            end;
        %% 0x8：表示连接断开
        {tcp, Socket, <<1:1, 0:3, 8:4, _Rest/binary>>} ->
            clean({tcp_closed, Socket}, State);
        {tcp, Socket, Request} ->
            ?DEBUG("~p, ~p~n", [?LINE, {Request, websocket_data(Request)}]),
            main_loop(State);
        {send, Data} ->
            Sender ! {send, Data},
            main_loop(State);
        {inet_reply, Socket, ok} ->
            main_loop(State);

        {inet_reply, Socket, _}         = CleanReason ->
            clean(CleanReason, State);
        sender_down                     = CleanReason ->
            clean(CleanReason, State);
        kill_for_game_stop              = CleanReason ->
            clean(CleanReason, State);
        {kill, From}                    = CleanReason ->
            clean(CleanReason, State),
            From ! ok;
        {tcp_closed, Socket}            = CleanReason ->
            clean(CleanReason, State);
        {tcp_error, Socket, emsgsize}   = CleanReason ->
            clean(CleanReason, State);
        {tcp_error, Socket, etimedout}  = CleanReason ->
            clean(CleanReason, State);
        {'DOWN', SenderMon, _, _, _}    = CleanReason -> 
            clean(CleanReason, State);

        %% 清理不在在线列表的玩家
        kill_for_clean ->
            StartTime      = get(proc_start_time),
            {LocalTime, _} = statistics(wall_clock),
            if LocalTime - StartTime > 120000 ->
                case get(is_gm) of
                    true -> main_loop(State);
                    _    -> clean(kill_for_clean, State)
                end;
            true ->
                main_loop(State)
            end;

        {From, get_sock} ->
            From ! State #client_state.sock,
            main_loop(State);

        Other ->
            clean(Other, State),
            exit({unknown_info, Other})
    end.



%% @todo   关掉Socket前的清理工作
clean (CleanReason, #client_state{sock = Socket} = _State) ->
    ?INFO("socket clean then close because : ~p~n", [CleanReason]),
    gen_tcp:close(Socket).

%%% @doc    处理未完成的消息队列
proc_message_queue ([Message | Lits]) ->
    proc_message(Message),
    proc_message_queue(Lits);
proc_message_queue ([]) ->
    ok.

proc_message ({apply_after, M, F, A}) ->
    State = get(state),
    try_apply(State, M, F, A);
proc_message ({apply, Pid, M, F, A}) ->
    State = get(state),
    Pid ! try_apply(State, M, F, A);
proc_message ({async_apply, M, F, A, CallBack}) ->
    State = get(state),
    do_async_apply(State, M, F, A, CallBack);
proc_message ({async_apply_call_back, {CallBackM, CallBackF, CallBackA}}) ->
    lib_misc:try_apply(CallBackM, CallBackF, CallBackA);
proc_message (_Message) ->
    ok.


%%% ========== ======================================== ====================
%%% @doc    设置进程字典
set_process_dict (start_conn_time) ->
    {TotalWallClock, _} = statistics(wall_clock),
    put(start_conn_time, TotalWallClock).



%%% @doc    仅处理长度为125以内的文本消息
websocket_data (<< 1:1, 0:3, 2:4,  1:1, 126:7, Len:16,  MaskKey:32,  Rest/bits >>) ->
    websocket_data_3(Rest, Len, MaskKey);
websocket_data (<< 1:1, 0:3, 2:4,  1:1, 127:7, Len:64,  MaskKey:32,  Rest/bits >>) ->
    websocket_data_3(Rest, Len, MaskKey);
websocket_data (<< 1:1, 0:3, 2:4,  1:1, Len:7,          MaskKey:32,  Rest/bits >>) ->
    websocket_data_3(Rest, Len, MaskKey);
websocket_data (Data) when is_list(Data) ->
    websocket_data(list_to_binary(Data));
websocket_data (<< _PacketLen:16, MaskKey:32,  Rest/binary >>) ->
    % <<End:Len/binary, _/bits>> = Rest,
    Text = websocket_unmask(Rest, << MaskKey:32 >>, <<>>),
    Text;
websocket_data (_) ->
    <<>>.

websocket_data_3 (Rest, Len, MaskKey) ->
    <<End:Len/binary, _/bits>> = Rest,
    Text = websocket_unmask(End, << MaskKey:32 >>, <<>>),
    Text.

%%% @doc    由于Browser发过来的数据都是mask的,所以需要unmask
websocket_unmask (<<>>, _, Unmasked) ->
    Unmasked;

websocket_unmask (<< O:32, Rest/binary >>, << MaskKey:32       >>, Acc) ->
    T = O bxor MaskKey,
    websocket_unmask(Rest, << MaskKey:32 >>, << Acc/binary, T:32 >>);

websocket_unmask (<< O:24              >>, << MaskKey:24, _:08 >>, Acc) ->
    T = O bxor MaskKey,
    << Acc/binary, T:24 >>;

websocket_unmask (<< O:16              >>, << MaskKey:16, _:16 >>, Acc) ->
    T = O bxor MaskKey,
    << Acc/binary, T:16 >>;

websocket_unmask (<< O:08              >>, << MaskKey:08, _:24 >>, Acc) ->
    T = O bxor MaskKey,
    << Acc/binary, T:8 >>.

