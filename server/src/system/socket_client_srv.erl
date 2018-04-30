-module (socket_client_srv).

%% @doc    玩家进程

-copyright  ("Copyright © 2017-2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 04, 14}).
-vsn        ("1.0.0").

-export ([start_link/0]).
-export ([init/0]).
-export ([
    set_socket/2,
    kill_for_game_stop/1,

    is_player_proc/0,
    is_player_proc/1
]).

-include ("define.hrl").
-include ("record.hrl").


%% ======================================================================
start_link () ->
    {ok, proc_lib:spawn_link(?MODULE, init, [])}.

init () ->
    receive
        {go, Socket} -> start_connection(Socket)
    end.

start_connection (Socket) ->
    ?INFO("socket_client_srv start_connection : ~p~n", [inet:peername(Socket)]),
    Sender       = socket_client_sender:start(Socket, self()),
    SenderMon    = erlang:monitor(process, Sender),
    {RunTime, _} = statistics(wall_clock),
    put(proc_start_time, RunTime),
    % erlang:send_after(5000, self(), {check_client}),

    InitState = #client_state{sock = Socket, sender = Sender, sender_mon = SenderMon},
    NewState  = send_flash_policy(Socket, InitState),

    % erlang:send_after(5000, self(), {check_client}),
    case catch main_loop(NewState) of
        {'EXIT', R} -> ?ERROR("main_loop: ~p~n", [R]);
        _ -> ok
    end,
    
    %% 处理未完成的消息队列
    State = get(state),
    [{messages, MessageList}] = process_info(self(), [messages]),
    F = fun(Message) ->
        case Message of
            _ ->
                ok
        end
    end,
    [catch F(Message) || Message <- MessageList],
    
    exit(Sender, main_loop_exit),
    ok.

main_loop (State = #client_state{player_id = PlayerId, sock = Socket, sender = Sender, sender_mon = SenderMon}) ->
    
    inet:setopts(Socket, [{packet, 0}, {active, once}]),
    % inet:setopts(Socket, [{packet, 4}, {active, once}]),
    receive
        {check_client} ->
            if
                is_number(PlayerId) andalso PlayerId > 0 ->
                    main_loop(State);
                true ->
                    exit({invalid_client, inet:peername(Socket)})
            end;
        {tcp, Socket, Request} ->
            case try_route_request(Request, State) of
                error    -> 
                    clean(try_route_request_error, State);
                NewState -> 
                    put(state, NewState), 
                    main_loop(NewState)
            end;
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
        
        Other ->
            clean(Other, State),
            exit({unknown_info, Other})
    end.

%% @todo   设置套接字，一些选项和控制进程
set_socket (Pid, Socket) ->
    inet:setopts(Socket, [
        {active, false},
        {delay_send, true},
        {packet_size, 1024 * 1024}
    ]),
    ok = gen_tcp:controlling_process(Socket, Pid),
    Pid ! {go, Socket}.

%% @todo   游戏停止时杀掉玩家进程
kill_for_game_stop (Pid) ->
    Pid ! kill_for_game_stop.

%% @todo   关掉Socket前的清理工作
clean (CleanReason, #client_state{sock = Socket} = _State) ->
    ?INFO("socket clean then close because : ~p~n", [CleanReason]),
    gen_tcp:close(Socket).


%% @todo   判断是否玩家进程
is_player_proc () ->
    ThePlayerId = get_the_player_id(),
    is_integer(ThePlayerId) andalso ThePlayerId > 0.

is_player_proc (PlayerId) ->
    PlayerId =:= get_the_player_id().

get_the_player_id () ->
    get(the_player_id).


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

wait_for_start (Socket, State) ->
    inet:setopts(Socket, [{packet, 0}, {active, once}]),
    receive
        {check_client} ->
            State;
        {tcp, Socket, Request} ->
            % ?DEBUG("~p, ~p~n", [?LINE, Request]),
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

handshake_or_request (Socket, RequestBin, State) ->
    RequestStr = binary_to_list(RequestBin),
    case string:str(RequestStr, "Upgrade: websocket") of
        0 ->
            inet:setopts(Socket, [{packet, 4}]),
            <<_PackSize:4/binary, Pack/binary>> = RequestBin,
            case try_route_request(Pack, State) of
                error    -> clean(try_route_request_error, State), State;
                NewState -> NewState
            end;
        _ ->
            Accept          = get_handshake_accept(RequestStr),
            HandshakeReturn = [
                "HTTP/1.1 101 Switching Protocols\r\n",
                "Connection: Upgrade\r\n",
                "Upgrade: websocket\r\n",
                "Sec-WebSocket-Accept: ", Accept, "\r\n",
                "\r\n"
            ],
            gen_tcp:send(Socket, list_to_binary(HandshakeReturn)),
            State
    end.

%% @todo   获取握手的Accept
%% @remark 如果需要请注意大小写
get_handshake_accept (RequestStr) ->
    get_handshake_accept_bin(string:tokens(RequestStr, "\r\n")).
get_handshake_accept_bin (["Sec-WebSocket-Key: " ++  Key | _RequestList]) ->
    KeyBin = list_to_binary(Key),
    base64:encode(crypto:sha(<<KeyBin/binary, "258EAFA5-E914-47DA-95CA-C5AB0DC85B11">>));
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



