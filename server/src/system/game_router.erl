-module (game_router).

-author ("CHEONGYI").

-export ([route_request/2]).


%% ======================================================================
route_request (Pack = <<Module:16/unsigned, Action:16/unsigned, Args/binary>>, State) -> 
    NewArgs = if
        Module == 521 orelse Module == 100 orelse Module == 200 ->
            Args;
        Module == 0 andalso Action == 0 ->
            put(prev_request, {Module, Action}),
            Args;
        true ->
            {CurPrevModule, CurPrevAction} = get(prev_request),
            <<PrevModule:16/unsigned, PrevAction:16/unsigned>> = binary:part(Pack, size(Pack) - 4, 4),
            
            if
                CurPrevModule == PrevModule andalso CurPrevAction == PrevAction ->
                    put(prev_request, {Module, Action}),
                    binary:part(Args, 0, size(Args) - 4);
                true ->
                    Args
            end
    end,

    {Time1, _} = statistics(runtime),
    {Time2, _} = statistics(wall_clock),
    {M, A, NewState} = route_request(Module, Action, NewArgs, State),
    {Time3, _} = statistics(runtime),
    {Time4, _} = statistics(wall_clock),
    Sec1 = (Time3 - Time1) / 1000.0,
    Sec2 = (Time4 - Time2) / 1000.0,
    game_prof_srv:set_info(M, A, Sec1, Sec2),
    NewState.

route_request (0, _Action, _Args0, _State) -> 
    case _Action of
        0 -> 
            <<Len1:16/unsigned, PlayerName:Len1/binary>> = _Args0,
            NewState = api_player:login(binary_to_list(PlayerName), _State),
            {player, login, NewState};
        _ ->
            {player, unknow_action, _State}
    end;
route_request (_Module, _Action, _Args0, _State) -> 
    _State.




