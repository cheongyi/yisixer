-module (mod_online).

%%% @doc    

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("WhoAreYou").
-date       ({2018, 06, 22}).
-vsn        ("1.0.0").

-compile(export_all).
-export ([

]).

-include("record.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    增加在线玩家
add_online_player (PlayerId, Socket) when is_number(PlayerId) ->
    lib_ets:insert(online_player, #online_player{ 
        player_id  = PlayerId, 
        socket     = Socket,
        process_id = self()
    }),
    ok.

%%% @doc    删除在线玩家
del_online_player (PlayerId) when is_number(PlayerId) ->
    lib_ets:delete(online_player, PlayerId),
    ok.

%%% @doc    统计在线玩家
count_online_player () ->
    ets:info(online_player, size).


%%% @doc    主动推送消息
send_to_online_player (PlayerId, Data) ->
    send_to_online_player(PlayerId, Data, false).
send_to_online_player (PlayerId, Data, IsDelay) when
    is_number(PlayerId) andalso is_binary(Data)
->
    case check_get_online_player(PlayerId) of
        undefined ->
            false;
        OnlinePlayer ->
            PlayerPid   = OnlinePlayer #online_player.process_id,
            case socket_client_srv:is_player_proc(PlayerId) of
                true ->
                    if
                        IsDelay ->
                            PlayerPid ! {send, Data};
                        true ->
                            Socket  = OnlinePlayer #online_player.socket,
                            lib_misc:tcp_send(Socket, Data)
                    end;
                _ ->
                    PlayerPid ! {send, Data}
            end
    end.


%%% @doc    同步应用给在线玩家
apply_to_online_player (PlayerId, M, F, A) when
    is_number(PlayerId) andalso
    is_atom(M) andalso is_atom(F) andalso is_list(A)
->
    case check_get_online_player(PlayerId) of
        undefined ->
            false;
        OnlinePlayer ->
            PlayerPid   = OnlinePlayer #online_player.process_id,
            case socket_client_srv:apply(PlayerPid, M, F, A) of
                apply_time_out ->
                    catch del_online_player(PlayerId),
                    erlang:suspend_process(PlayerPid),
                    false;
                Result ->
                    Result
            end
    end.

%%% @doc    异步应用给在线玩家
async_apply_to_online_player (PlayerId, M, F, A, CallBack) when
    is_number(PlayerId) andalso
    is_atom(M) andalso is_atom(F) andalso is_list(A)
->
    case check_get_online_player(PlayerId) of
        undefined ->
            false;
        OnlinePlayer ->
            PlayerPid   = OnlinePlayer #online_player.process_id,
            spawn(socket_client_srv, async_apply, [PlayerPid, M, F, A, CallBack]),
            ok
    end.


%%% @doc    获取玩家的进程Pid
check_get_online_player (PlayerId) ->
    case lib_ets:get(online_player, PlayerId) of
        [] ->
            undefined;
        [OnlinePlayer] ->
            PlayerPid   = OnlinePlayer #online_player.process_id,
            case erlang:process_info(PlayerPid, min_heap_size) of
                undefined ->
                    catch del_online_player(PlayerId),
                    undefined;
                _ ->
                    OnlinePlayer
            end
    end.


%%% @doc    等待在线玩家退出
wait_all_online_player_exit (TimeOut) ->
    wait_all_online_player_exit(TimeOut, 0).

wait_all_online_player_exit (TimeOut, TimeOut) ->
    [
        exit(Pid, game_stop)
        ||
        {_SrvName, Pid, worker, [socket_client_srv]} <- supervisor:which_children(socket_client_sup)
    ],
    ok;
wait_all_online_player_exit (TimeOut, Time) ->
    socket_client_sup:kill_all(),
    io:format("wait for all online player exit ... "),
    receive
    after 1000 ->
        case socket_client_sup:count_child() of
            0 -> io:format("done~n"),    ok;
            N -> io:format("~p~n", [N]), wait_all_online_player_exit(TimeOut, Time + 1)
        end
    end.


