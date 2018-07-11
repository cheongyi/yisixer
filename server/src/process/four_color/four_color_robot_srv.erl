-module (four_color_robot_srv).

-author     ("CHEONGYI").

-compile (export_all).
-export ([
    start_link/1,
    init/1
]).

-include ("define.hrl").

start_link (ProcessName) ->
    proc_lib:start_link(?MODULE, init, [ProcessName]).

init (ProcessName) ->
    register(ProcessName, self()),
    proc_lib:init_ack({ok, self()}),
    loop().

loop () ->
    receive
        {distribute_card_to_player, RandomCardList} ->
            mod_four_color:init_player_four_color_card(RandomCardList);
        {open_gambling, PlayerRegisteredName} ->
            mod_four_color:banker_is_hucard_else_away_card(PlayerRegisteredName);
        {away_card, PlayerRegisteredName} ->
            ?FOUR_COLOR_SRV ! mod_four_color:player_away_card(PlayerRegisteredName);
        {isneed_away_or_pump_card, Msg} ->
            mod_four_color:player_isneed_away_or_pump_card(Msg);
        Other ->
            ?DEBUG("~p:~p~n", [?MODULE, Other])
    end,
    loop().














