-module (ssl_socket_server_acceptor).

%%% @doc    套接字服务器接收者
%%% @end

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 08, 23}).
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
start_link (ChildId, ListenSsl) ->
    gen_server:start_link({local, ChildId}, ?MODULE, [ListenSsl], []).

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
init ([ListenSsl]) ->
    {ok, #state{listen = ListenSsl}, 0}.

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
handle_info (timeout, State = #state{listen = ListenSsl}) ->
    ssl_accept(ListenSsl),
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
ssl_accept (ListenSsl) ->
    case (catch ssl:transport_accept(ListenSsl, ?LISTEN_TIMEOUT)) of
        {ok, SocketSsl} ->
            ok = ssl:ssl_accept(SocketSsl),
            try_handle_connection(SocketSsl);
        {error, Reason} ->
            handle_error(Reason);
        {'EXIT', Reason} ->
            handle_error({'EXIT', Reason})
    end.

%%% @doc    尝试操作处理连接
try_handle_connection (SocketSsl) ->
    case catch handle_connection(SocketSsl) of
        {'EXIT', Reason} ->
            handle_error({handle_connection, Reason});
        _ -> 
            ok
    end.

%%% @doc    操作处理连接
handle_connection (SocketSsl) ->
    case socket_client_sup:start_child() of
        {ok, Pid} ->
            socket_client_srv:set_socket_ssl(Pid, SocketSsl);
        {error, Reason} ->
            ssl:close(SocketSsl),
            handle_error(Reason)
    end.

%%% @doc    操作处理错误
%%% Too many connection...
handle_error (max_conn)     -> ?SLEEP(200);
%%% file table overflow -> 文件表溢出
handle_error ({enfile, _})  -> ?SLEEP(200);
%%% Too many open files -> 打开的文件太多
handle_error (emfile)       -> ?SLEEP(200);
%% This will only happen when the client is terminated abnormaly
%% and is not a problem for the server, so we want
%% to terminate normal so that we can restart without any 
%% error messages.
%%% connection reset by peer -> 对等连接复位
handle_error (econnreset)   -> exit(normal);
%%%  software caused connection abort -> 软件导致连接中止
handle_error (econnaborted) -> ok;
%%%  timeout -> 超时
handle_error (timeout)      -> ok;
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


