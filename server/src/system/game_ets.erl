-module (game_ets).

-author     ("CHEONGYI").
-date       ({2017, 11, 09}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2017 YiSiXEr").

-export ([start_link/0]).
-export ([stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    create_table/2                              % 新建ETS表
]).

-include ("define.hrl").
-include ("record.hrl").

-define (SERVER, ?MODULE).

-record (state, {}).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start_link() -> ServerRet.
%%% @doc    Start the process and link gen_server.
start_link () ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%% @spec   stop() -> ok.
%%% @doc    Stop the process.
stop () ->
    gen_server:call(?SERVER, stop).

%%% @doc    新建ETS表
create_table (TableName, KetPos) ->
    ?SERVER ! {create_table, TableName, KetPos}.


%%% ========== ======================================== ====================
%%% gen_server 6 callbacks
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, State}.
%%% @doc    gen_server init, opens the server in an initial state.
init ([]) ->
    do_create_table(player_four_color_card, #player_four_color_card.player_id),
    do_create_table(system_four_color_card, #system_four_color_card.owner),
    {ok, #state{}}.

%%% @spec   handle_call(Args, From, State) -> tuple().
%%% @doc    gen_server callback.
handle_call (stop, _From, State) ->
    {stop, shutdown, stopped, State};
handle_call (Request, From, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {call, Request, From}]),
    {reply, {error, badrequest}, State}.

%%% @spec   handle_cast(Cast, State) -> tuple().
%%% @doc    gen_server callback.
handle_cast (Request, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {cast, Request}]),
    {noreply, State}.

%%% @spec   handle_info(Info, State) -> tuple().
%%% @doc    gen_server callback.
handle_info ({create_table, TableName, KetPos}, State) ->
    catch do_create_table(TableName, KetPos),
    {noreply, State};
handle_info (Info, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {info, Info}]),
    {noreply, State}.

%%% @spec   terminate(Reason, State) -> ok.
%%% @doc    gen_server termination callback.
terminate (Reason, _State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {terminate, Reason}]),
    ok.

%%% @spec   code_change(_OldVsn, State, _Extra) -> tuple().
%%% @doc    gen_server code_change callback (trivial).
code_change (_Vsn, State, _Extra) ->
    {ok, State}.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    由进程新建ETS表
do_create_table (TableName, KetPos) ->
    ets:new(TableName, [set, named_table, public, {keypos, KetPos}]).





