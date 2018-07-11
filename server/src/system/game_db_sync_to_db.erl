-module (game_db_sync_to_db).

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 19}).
-vsn        ("1.0.0").

-behaviour  (gen_server).

-export ([start_link/0, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    wait_for_all_data_sync/1,                   % 等待所有数据同步
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

%%% @doc    等待所有数据同步
wait_for_all_data_sync (TimeOut) ->
    wait_for_all_data_sync_2(TimeOut, 0).
wait_for_all_data_sync_2 (TimeOut, TimeOut) ->
    case io:get_chars("Sync to db time out, continue?[Y/n] : ", 1) of
        "n" ->
            io:format("wait for all player data sync to db   ... time out"),
            time_out;
        _   ->
            wait_for_all_data_sync_2(TimeOut, 0)
    end;
wait_for_all_data_sync_2 (TimeOut, Time) ->
    io:format("wait for all player data sync to db   ... "),
    receive
    after 1000 ->
        case get_message_queue_len() of
            0 -> io:format("done~n");
            N -> io:format("~p~n", [N]), 
                wait_for_all_data_sync_2(TimeOut, Time + 1)
        end
    end.

%%% @doc    获取消息队列长度
get_message_queue_len () ->
    {message_queue_len, Len} = process_info(whereis(?SERVER), message_queue_len),
    Len.


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
handle_info ({to_db, SqlList}, State) ->
    try game_mysql:fetch(gamedb, [SqlList], infinity) of
        _Result ->
            ok
    catch
        Error ->
            ?ERROR("~p : SqlList = ~p~n  Error = ~p~n", [?SERVER, SqlList, Error])
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
%%% @doc    获取日志文件



