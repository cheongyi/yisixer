-module (four_color_auto_srv).

-author     ("CHEONGYI").

-compile (export_all).
-export ([
    start_link/0,
    init/0
]).

-include ("define.hrl").

start_link () ->
    proc_lib:start_link(?MODULE, init, []).

init () ->
    register(?MODULE, self()),
    proc_lib:init_ack({ok, self()}),
    loop().

loop () ->
    receive
        {auto_play} ->
            ?FOUR_COLOR_SRV ! {start},
            ?FOUR_COLOR_SRV ! {random_distribute_card},
            timer:sleep(2000),
            ?FOUR_COLOR_SRV ! {open_gambling, mod_four_color:get_banker_registered_name()};
        {open_gambling, PlayerRegisteredName} ->
            PlayerRegisteredName ! {open_gambling, PlayerRegisteredName};
        {away_card, PlayerRegisteredName} ->
            PlayerRegisteredName ! {away_card, PlayerRegisteredName};
        {pump_card, PlayerRegisteredName} ->
            ?FOUR_COLOR_SRV ! {pump_card, PlayerRegisteredName};
        {isneed_away_or_pump_card, NextPlayerRegisteredName, Msg} ->
            NextPlayerRegisteredName ! {isneed_away_or_pump_card, Msg};
        Other ->
            ?DEBUG("~p:~p~n", [?MODULE, Other])
    end,
    loop().












