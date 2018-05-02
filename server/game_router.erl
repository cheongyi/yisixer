-module (game_router).

-copyright  ("Copyright @2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 04, 28}).
-vsn        ("1.0.0").

-export ([
    route_request/2
]).

% -include ("game.hrl").
% -include ("gen/game_db.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
route_request (_Pack = <<ModuleId:16/unsigned, ActionId:16/unsigned, Args/binary>>, State) ->
    put(prev_request, {ModuleId, ActionId}),
    TimeRecord  = game_perf:statistics_start(),
    {Module, Fuction, ArgsNum, NewState} = route_relay(ModuleId, ActionId, Args, State),
    game_perf:statistics_end({Module, Fuction, ArgsNum}, TimeRecord),
    NewState.

route_relay (100, ActionId, Args, State) ->
    case ActionId of
        100001 ->
            <<>> = Args,
            NewState = api_test:get_player_info(State),
            {test, get_player_info, 1, NewState};
        100002 ->
            <<_player_id_63:64/signed, _age_64:08/signed, Len65:16/unsigned, _nickname_65:Len65/binary, _seat_number_66:16/signed, _job_number_67:32/signed, _department_68:32/unsigned, _player_info_73/binary>> = Args,
            NewState = api_test:get_other_player_info(_player_id_63, _age_64, binary_to_list(_nickname_65), _seat_number_66, _job_number_67, _department_68, _player_info_73, State),
            {test, get_other_player_info, 8, NewState};
        100003 ->
            <<>> = Args,
            NewState = api_test:get_all_player_info(State),
            {test, get_all_player_info, 1, NewState};
        100004 ->
            <<_game_function_id_106:32/signed>> = Args,
            NewState = api_test:sign_play_player_function(_game_function_id_106, State),
            {test, sign_play_player_function, 2, NewState};
        100099 ->
            <<>> = Args,
            NewState = api_test:jiekou_test(State),
            {test, jiekou_test, 1, NewState}
    end;
route_relay (module_id, _ActionId, _Args, _State) ->
    ok.
