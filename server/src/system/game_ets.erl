-module(game_ets).

-author ("CHEONGYI").

-export([start_link/0]).
-export([init/0]).
-export([
    create_table/2
]).

-include("record.hrl").


%% ======================================================================

start_link () ->
    proc_lib:start_link(?MODULE, init, []).
    
init () ->
    register(?MODULE, self()),
    do_create_table(player_four_color_card, #player_four_color_card.player_id),
    do_create_table(system_four_color_card, #system_four_color_card.owner),
    proc_lib:init_ack({ok, self()}),
    loop().
    
loop () ->
    receive
        {create_table, TableName, KetPos} ->
            catch do_create_table(TableName, KetPos),
            loop();
        _ -> 
            loop()
    end.

create_table (TableName, KetPos) ->
    ?MODULE ! {create_table, TableName, KetPos}.

do_create_table (TableName, KetPos) ->
    ets:new(TableName, [set, named_table, public, {keypos, KetPos}]).



