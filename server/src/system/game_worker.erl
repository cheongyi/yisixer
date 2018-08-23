-module (game_worker).

%%% @doc    游戏工作进程代理

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 07}).
-vsn        ("1.0.0").

-behaviour (gen_server).

-export ([start_link/0]).
-export ([stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    do_work/3,                                  % 同步工作
    async_do_work/3,                            % 异步工作
    count_work/0,                               % 统计工作消息数
    peek_work/0,                                % 查看工作消息头
    get_state/0                                 % 获取工作状态数据
]).

-include ("define.hrl").

-define (SERVER, ?MODULE).
-define (TABLE_NAME, game_worker_data).
-define (COUNT_RATE, 60).   % 计数比率

-record (state, {count = 0, rate = 0, tref}).
-record (?TABLE_NAME, {
    from,
    count = 0,
    mfa   = {null, null, []},
    player_id,
    registered_name,
    time
}).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start_link() -> ServerRet
%%% @doc    Start the process and link gen_server.
start_link () ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%% @spec   stop() -> ok
%%% @doc    Stop the process.
stop () ->
    gen_server:call(?SERVER, stop).

%%% @doc    同步工作
do_work (M, F, A) ->
    From = self(),
    Time = lib_misc:get_local_timestamp(),
    update_game_worker_data(From, M, F, A, Time),
    case get(is_game_worker) of
        true ->
            apply(M, F, A);
        undefined ->
            case gen_server:call(?SERVER, {put_work, {From, M, F, A, Time}}) of
                {work_done,   Result, M, F, A, Time} -> Result;
                {work_failed, Reason, M, F, A, Time} -> exit(Reason)
            end
    end.

%%% @doc    异步工作
async_do_work (M, F, A) ->
    From = self(),
    Time = lib_misc:get_local_timestamp(),
    update_game_worker_data(From, M, F, A, Time),
    case get(is_game_worker) of
        true ->
            apply(M, F, A);
        undefined ->
            gen_server:cast(?SERVER, {async_put_work, {From, M, F, A}})
    end.

%%% @doc    统计工作消息数
count_work () ->
    {message_queue_len, Len} = erlang:process_info(whereis(?SERVER), message_queue_len),
    Len.
    
%%% @doc    查看工作消息头
peek_work () ->
    {messages, Messages} = erlang:process_info(whereis(?SERVER), messages),
    case Messages of
        [] -> 
            [];
        [Message | _] -> 
            Message
    end.
    
%%% @doc    获取工作状态数据
get_state () ->
    gen_server:call(?SERVER, get_state).


%%% ========== ======================================== ====================
%%% gen_server 6 callbacks
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, State}
%%% @doc    gen_server init, opens the server in an initial state.
init ([]) ->
    put(is_game_worker, true),
    ets:new(?TABLE_NAME, [set, named_table, protected, {keypos, #game_worker_data.from}]),
    Time        = timer:seconds(?COUNT_RATE),
    Msg         = status,
    {ok, TRef}  = timer:send_interval(Time, Msg),
    Self = Dest = self(),
    ?TIMER({Self, {?SERVER, Dest}, Time, Msg}),
    {ok, #state{tref = TRef}}.

%%% @spec   handle_call(Args, From, State) -> tuple()
%%% @doc    gen_server callback.
handle_call ({put_work, {From, M, F, A, Time}}, _From, State) ->
    put(put_work_caller_info, {put_work, From, M, F, A, Time}),
    Reply = case catch apply(M, F, A) of
        {'EXIT', Reason} -> {work_failed, Reason, M, F, A, Time};
        Result           -> {work_done,   Result, M, F, A, Time}
    end,
    erase(), 
    put(is_game_worker, true), 
    {reply, Reply, State #state{count = State #state.count + 1}};
handle_call (get_state, _From, State) ->
    {reply, State, State};
handle_call (stop, _From, State) ->
    {stop, shutdown, stopped, State};
handle_call (Request, _From, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {call, Request, _From}]),
    {reply, {error, badrequest}, State}.

%%% @spec   handle_cast(Cast, State) -> tuple()
%%% @doc    gen_server callback.
handle_cast ({async_put_work, {From, M, F, A}}, State) ->
    Time = lib_misc:get_local_timestamp(),
    put(put_work_caller_info, {async_put_work, From, M, F, A, Time}),
    catch apply(M, F, A),
    erase(), 
    put(is_game_worker, true),
    {noreply, State #state{count = State #state.count + 1}};
handle_cast (Request, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {cast, Request}]),
    {noreply, State}.

%%% @spec   handle_info(Info, State) -> tuple()
%%% @doc    gen_server callback.
handle_info (status, State) ->
    % {noreply, State #state{count = 0, rate = State #state.count / ?COUNT_RATE}};
    {noreply, State #state{count = 0, rate = State #state.count / ?COUNT_RATE}}.
% handle_info (Info, State) ->
%     ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {info, Info}]),
%     {noreply, State}.

%%% @spec   terminate(Reason, State) -> ok
%%% @doc    gen_server termination callback.
terminate (Reason, State) ->
    catch timer:cancel(State #state.tref),
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {terminate, Reason}]),
    ok.

%%% @spec   code_change(_OldVsn, State, _Extra) -> tuple()
%%% @doc    gen_server code_change callback (trivial).
code_change (_Vsn, State, _Extra) ->
    {ok, State}.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    更新游戏工作数据
% update_game_worker_data (M, F, A) ->
%     update_game_worker_data(self(), M, F, A, lib_misc:get_local_timestamp()).
update_game_worker_data (From, M, F, A, Time) ->
    Data = case lib_ets:get(?TABLE_NAME, From) of
        [] ->
            #game_worker_data{};
        [TheData] ->
            TheData
    end,
    RegisteredName = case erlang:process_info(From, registered_name) of
        {registered_name, TheRegisteredName} ->
            TheRegisteredName;
        _ ->
            undefined
    end,
    lib_ets:insert(
        ?TABLE_NAME, 
        Data #game_worker_data{
            from    = From,
            count   = Data #game_worker_data.count + 1,
            mfa     = {M, F, A},
            time    = Time,
            player_id       = get(the_player_id),
            registered_name = RegisteredName
        }, 
        replace
    ).



