-module (game_db_sync_srv).

%%% @doc    游戏数据库同步佣程

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 19}).
-vsn        ("1.0.0").

-behaviour  (gen_server).

-export ([start_link/0, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    get_state/0
]).

-include ("define.hrl").
% -include ("record.hrl").

-define (SERVER, ?MODULE).

-record (state, {file}).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start_link() -> ServerRet.
%%% @doc    Start the process and link gen_server.
start_link () ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%% @spec   start() -> ServerRet.
%%% @doc    Start the process.
start () ->
    gen_server:start({local, ?SERVER}, ?MODULE, [], []).

%%% @spec   stop() -> ok.
%%% @doc    Stop the process.
stop () ->
    gen_server:call(?SERVER, stop).

get_state () ->
    gen_server:call(?SERVER, get_state).


%%% ========== ======================================== ====================
%%% gen_server 6 callbacks
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, State}.
%%% @doc    gen_server init, opens the server in an initial state.
init ([]) ->
    {ok, #state{}}.

%%% @spec   handle_call(Args, From, State) -> tuple().
%%% @doc    gen_server callback.
handle_call (get_state, _From, State) ->
    {reply, State, State};
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
handle_info ({sync, TranActionList}, State) ->
    try tran_action_list_to_sql_list(TranActionList) of
        [] ->
            noop;
        SqlList when is_list(SqlList) ->
            game_db_sync_to_file ! {to_file, SqlList},
            game_db_sync_to_db   ! {to_db,   SqlList}
    catch
        _ : Error ->
            ?ERROR("~p : TranActionList = ~p~n  Error = ~p~n", [?SERVER, TranActionList, Error])
    end,
    {noreply, State};
handle_info ({apply, From, M, F, A}, State) ->
    From ! (catch apply(M, F, A)),
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
%%% @doc    事务操作列表转SQL语句列表
tran_action_list_to_sql_list (TranActionList) ->
    tran_action_list_to_sql_list(TranActionList, []).
    
tran_action_list_to_sql_list ([], SqlList) ->
    SqlList;
tran_action_list_to_sql_list ([TranAction | TranActionList], SqlList) ->
    case game_db_sync:tran_action_to_sql(TranAction) of
        none -> tran_action_list_to_sql_list(TranActionList, SqlList);
        Sql  -> tran_action_list_to_sql_list(TranActionList, [Sql | SqlList])
    end.



