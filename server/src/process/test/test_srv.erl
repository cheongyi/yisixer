-module (test_srv).

-author     ("WhoAreYou").
-date       ({2017, 11, 09}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2017 YiSiXEr").

-behaviour (gen_server).

-export ([start/0, start_link/0]).
-export ([stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include ("define.hrl").

-record (state, {}).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start() -> ServerRet
%%% @doc    Start the process.
start () ->
    gen_server:start({local, ?MODULE}, ?MODULE, [], []).

%%% @spec   start_link() -> ServerRet
%%% @doc    Start the process and link gen_server.
start_link () ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%% @spec   stop() -> ok
%%% @doc    Stop the process.
stop () ->
    gen_server:call(?MODULE, stop).


%%% ========== ======================================== ====================
%%% ++++++++++++++++++++ gen_server 6 callbacks ++++++++++++++++++++
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, State}
%%% @doc    gen_server init, opens the server in an initial state.
init ([]) ->
    {ok, #state{}}.

%%% @spec   handle_call(Args, From, State) -> tuple()
%%% @doc    gen_server callback.
handle_call (stop, _From, State) ->
    {stop, shutdown, stopped, State};
handle_call (Request, From, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {call, Request, From}]),
    {reply, {error, badrequest}, State}.

%%% @spec   handle_cast(Cast, State) -> tuple()
%%% @doc    gen_server callback.
handle_cast (Request, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {cast, Request}]),
    {noreply, State}.

%%% @spec   handle_info(Info, State) -> tuple()
%%% @doc    gen_server callback.
handle_info (Info, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {info, Info}]),
    {noreply, State}.

%%% @spec   terminate(Reason, State) -> ok
%%% @doc    gen_server termination callback.
terminate (Reason, _State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {terminate, Reason}]),
    ok.

%%% @spec   code_change(_OldVsn, State, _Extra) -> tuple()
%%% @doc    gen_server code_change callback (trivial).
code_change (_Vsn, State, _Extra) ->
    {ok, State}.



