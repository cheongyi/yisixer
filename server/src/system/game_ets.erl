-module (game_ets).

-author     ("CHEONGYI").
-date       ({2017, 11, 09}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2017 YiSiXEr").

-export ([start_link/0]).
-export ([init/0]).
-export ([
    create_table/2
]).

-include ("record.hrl").

-define (SERVER, ?MODULE).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    Start the server
start_link () ->
    proc_lib:start_link(?MODULE, init, []).

%%% @doc    新建ETS表
create_table (TableName, KetPos) ->
    ?MODULE ! {create_table, TableName, KetPos}.


%%% ========== ======================================== ====================
%%% callbacks
%%% ========== ======================================== ====================
init () ->
    register(?SERVER, self()),
    do_create_table(player_four_color_card, #player_four_color_card.player_id),
    do_create_table(system_four_color_card, #system_four_color_card.owner),
    proc_lib:init_ack({ok, self()}),
    loop().

%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
loop () ->
    receive
        {create_table, TableName, KetPos} ->
            catch do_create_table(TableName, KetPos),
            loop();
        _ -> 
            loop()
    end.

%%% @doc    由进程新建ETS表
do_create_table (TableName, KetPos) ->
    ets:new(TableName, [set, named_table, public, {keypos, KetPos}]).



