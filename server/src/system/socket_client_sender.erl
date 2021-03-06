-module (socket_client_sender).

%%% @doc    套接字客户端发送者

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 04, 25}).
-vsn        ("1.0.0").

-behaviour  (gen_server).

-export ([start_link/2, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    get_state/0
]).

-define (SERVER, ?MODULE).

-record (state, {sock, parent, parentmonitor}).

-include ("define.hrl").
% -include ("record.hrl").
% -include ("gen/game_db.hrl").
% -include ("api/api_code.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start_link() -> ServerRet.
%%% @doc    Start the process and link gen_server.
start_link (Socket, Parent) ->
    gen_server:start_link(?MODULE, [Socket, Parent], []).

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
%%% @spec   init([]) -> {ok, State}.
%%% @doc    gen_server init, opens the server in an initial state.
init ([Socket, Parent]) ->
    ParentMonitor = erlang:monitor(process, Parent),
    {ok, #state{sock = Socket, parent = Parent, parentmonitor = ParentMonitor}}.

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
handle_info ({send, Data},                  State = #state{sock = Socket}) ->
    lib_misc:tcp_send(Socket, Data), 
    {noreply, State};
handle_info ({inet_reply, Socket, ok},      State = #state{sock = Socket}) ->
    {noreply, State};
handle_info ({inet_reply, Socket, _},       State = #state{sock = Socket}) ->
    {stop,    inet_reply_error, State};
handle_info ({'DOWN', ParentMonitor, _, _, Reason}, State = #state{parentmonitor = ParentMonitor}) ->
    {stop,    Reason,           State};
handle_info (main_loop_exit,                State) ->
    {stop,    main_loop_exit,   State};
handle_info (Info, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {info, Info}]),
    {noreply, State}.

%%% @spec   terminate(Reason, State) -> ok.
%%% @doc    gen_server termination callback.
terminate (Reason, _ClientState) ->
    ?INFO("~p, ~p, ~p~n~n~n~n~n", [?MODULE, ?LINE, {terminate, Reason}]),
    ok.

%%% @spec   code_change(_OldVsn, State, _Extra) -> tuple().
%%% @doc    gen_server code_change callback (trivial).
code_change (_Vsn, State, _Extra) ->
    {ok, State}.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================


