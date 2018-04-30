-module (socket_server_acceptor).

%%% @doc    

-copyright  ("Copyright © 2017-2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 04, 14}).
-vsn        ("1.0.0").

-behaviour  (gen_server).

-export ([start_link/2, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    get_state/0
]).

-define (SERVER, ?MODULE).
-define (LISTEN_TIMEOUT, 50000).        % 监听超时时间

-record (state, {listen}).

-include ("define.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start_link() -> ServerRet.
%%% @doc    Start the process and link gen_server.
start_link (ChildId, Listen) ->
    gen_server:start_link({local, ChildId}, ?MODULE, [Listen], []).

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
init ([Listen]) ->
    {ok, #state{listen = Listen}, 0}.

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
handle_info (timeout, State #state{listen = Listen}) ->
    acceptor(Listen),
    {noreply, State, 0};
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
%%% @doc    接收监听
acceptor (Listen) ->
    case (catch gen_tcp:accept(Listen, ?LISTEN_TIMEOUT)) of
        {ok, Socket} ->
            try_handle_connection(Socket);
        {error, Reason} ->
            handle_error(Reason);
        {'EXIT', Reason} ->
            handle_error({'EXIT', Reason})
    end.

%%% @doc    尝试操作处理连接
try_handle_connection (Socket) ->
    case catch handle_connection(Socket) of
        {'EXIT', Reason} ->
            handle_error({handle_connection, Reason});
        _ -> 
            ok
    end.

%%% @doc    操作处理连接
handle_connection (Socket) ->
    case socket_client_sup:start_child() of
        {ok, Pid} ->
            socket_client_srv:set_socket(Pid, Socket);
        {error, Reason} ->
            gen_tcp:close(Socket),
            handle_error(Reason)
    end.

%%% @doc    操作处理错误
%%% Out of sockets...
handle_error ({enfile, _})  -> sleep(200);
%%% Too many open files -> Out of sockets...
handle_error (emfile)       -> sleep(200);
%%% Too many connection...
handle_error (max_conn)     -> sleep(200);
handle_error (econnaborted) -> ok;
handle_error (timeout)      -> ok;
%% This will only happen when the client is terminated abnormaly
%% and is not a problem for the server, so we want
%% to terminate normal so that we can restart without any 
%% error messages.
handle_error (econnreset)   -> exit(normal);
handle_error (closed) ->
    ?ERROR(
        "The accept socket was closed by " 
        "a third party. "
        "This will not have an impact on hotwheels"
        "that will open a new accept socket and " 
        "go on as nothing happened. It does however "
        "indicate that some other software is behaving "
        "badly.", 
        []
    ),
    exit(normal);
handle_error ({handle_connection, Reason}) ->
    ?ERROR("handle_connection : ~p~n", [Reason]);
handle_error ({'EXIT', Reason}) ->
    String = lists:flatten(io_lib:format("Accept exit  : ~p", [Reason])),
    accept_failed(String);
handle_error (Reason) ->
    String = lists:flatten(io_lib:format("Accept error : ~p", [Reason])),
    accept_failed(String).

%% @todo   接收失败处理
accept_failed (String) ->
    ?ERROR(String, []),
    exit({accept_failed, String}).    

sleep (T) -> 
    receive after T -> ok end.


