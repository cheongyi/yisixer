-module (socket_client_player).

%%% @doc    

-copyright  ("Copyright © 2017-2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 04, 25}).
-vsn        ("1.0.0").

-behaviour  (gen_server).

-export ([start_link/0, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    get_state/0
]).

-define (SERVER, ?MODULE).

-include ("define.hrl").
% -include ("record.hrl").
% -include ("gen/game_db.hrl").
% -include ("api/api_code.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start_link() -> ServerRet.
%%% @doc    Start the process and link gen_server.
start_link () ->
    gen_server:start_link({local, make_ref()}, ?MODULE, [], []).

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
%%% callback
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, ClientState}.
%%% @doc    gen_server init, opens the server in an initial state.
init ([]) ->
    {ok, #client_state{}}.

%%% @spec   handle_call(Args, From, ClientState) -> tuple().
%%% @doc    gen_server callback.
handle_call (get_state, _From, ClientState) ->
    {reply, ClientState, ClientState};
handle_call (stop, _From, ClientState) ->
    {stop, shutdown, stopped, ClientState};
handle_call (Request, From, ClientState) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {call, Request, From}]),
    {reply, {error, badrequest}, ClientState}.

%%% @spec   handle_cast(Cast, ClientState) -> tuple().
%%% @doc    gen_server callback.
handle_cast (Request, ClientState) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {cast, Request}]),
    {noreply, ClientState}.

%%% @spec   handle_info(Info, ClientState) -> tuple().
%%% @doc    gen_server callback.
handle_info ({go, Socket}, ClientState) ->
    start_connection(Socket, ClientState),
    {noreply, ClientState};
handle_info (Info, ClientState) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {info, Info}]),
    {noreply, ClientState}.

%%% @spec   terminate(Reason, ClientState) -> ok.
%%% @doc    gen_server termination callback.
terminate (Reason, _ClientState) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {terminate, Reason}]),
    ok.

%%% @spec   code_change(_OldVsn, ClientState, _Extra) -> tuple().
%%% @doc    gen_server code_change callback (trivial).
code_change (_Vsn, ClientState, _Extra) ->
    {ok, ClientState}.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
start_connection (Socket, ClientState) ->


