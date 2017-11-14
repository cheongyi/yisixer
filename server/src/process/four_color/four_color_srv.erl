-module (four_color_srv).

-author ('Chen HongYi').

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
        {start} ->
            put(status, start),
            ?DEBUG("~p:game start!~n", [?MODULE]);
        {stop} ->
            put(status, colse),
            ?DEBUG("~p:game stop!~n", [?MODULE]);
        {random_distribute_card} ->
            mod_four_color_srv:init_four_color_card_data();
        {open_gambling, PlayerRegisteredName} ->
            PlayerRegisteredName ! {open_gambling, PlayerRegisteredName};
        {hucard, PlayerRegisteredName, CardHeNumber} ->
            ?DEBUG("====== Gambling over!!! ======~n~p hucard(~p) at ~p!!!~n~n~n", [
                PlayerRegisteredName, CardHeNumber, time()]),
            timer:sleep(60000),
            ?FOUR_COLOR_AUTO_SRV ! {auto_play};
        {lost_gambling} ->
            ?DEBUG("====== Gambling lost!!! ====== at ~p~n~n~n", [
                time()]),
            timer:sleep(160000),
            ?FOUR_COLOR_AUTO_SRV ! {auto_play};
        {away_card, PlayerRegisteredName, PlayerAwayCard} ->
            TodoType    = away_card_finish_hucard,
            Msg         = {
                TodoType, 
                db_four_color:get_player_number_by_todo_type(TodoType), 
                PlayerRegisteredName, 
                PlayerAwayCard
            },
            ?FOUR_COLOR_AUTO_SRV ! {
                isneed_away_or_pump_card,
                db_four_color:get_next_player_registered_name(PlayerRegisteredName),
                Msg
            };
        {pump_card, PlayerRegisteredName} ->
            mod_four_color_srv:proc_pump_card(PlayerRegisteredName);
        {noneed_away_or_pump_card, PlayerRegisteredName, AwayOrPumpCard} ->
            mod_four_color_srv:proc_away_or_pump_card_to_ming(PlayerRegisteredName, AwayOrPumpCard);
        Other ->
            ?DEBUG("~p:~p~n", [?MODULE, Other])
    end,
    loop().






