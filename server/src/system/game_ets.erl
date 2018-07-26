-module (game_ets).

%%% @doc    游戏内存表(ETS)

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2017, 11, 09}).
-vsn        ("1.0.0").

-export ([start_link/0]).
-export ([stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    create_table/2                              % 新建ETS表
]).

-include ("define.hrl").
-include ("record.hrl").
-include ("gen/game_db.hrl").

-define (SERVER, ?MODULE).
-define (DEFAULT_KEYPOS, 1).

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
    do_create_table(player_username_index, ?DEFAULT_KEYPOS),
    do_create_table(player_nickname_index, ?DEFAULT_KEYPOS),
    create_player_index(ets:first(?ETS_TAB(player))),
    do_create_table(online_player,      #online_player.player_id),
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


%%% @doc    创建玩家相关索引
create_player_index ('$end_of_table') ->
    ok;
create_player_index (Key) ->
    [Row]   = ets:lookup(?ETS_TAB(player), Key),
    lib_ets:insert(player_username_index, {Row #player.username, Row #player.id}),
    lib_ets:insert(player_nickname_index, {Row #player.nickname, Row #player.id}),
    Next    = ets:next(?ETS_TAB(player), Key),
    create_player_index(Next).



