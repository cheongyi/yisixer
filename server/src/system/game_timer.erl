-module (game_timer).

%%% @doc    游戏定时器

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 05, 30}).
-vsn        ("1.0.0").

-behaviour  (gen_server).

-export ([start_link/0, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    write/1,                    % 写入数据

    game_mysql_hold_ping/0,     % 数据库保持连接

    get_state/0
]).

-define (SERVER, ?MODULE).

-record (state, {date, file}).
-record (game_timer, {
    player_id,      % = PlayerId,
    from,           % = element(1, Data),
    to,             % = element(2, Data),
    after_time,     % = element(3, Data),
    message,        % = element(4, Data)
    date_time
}).

-include ("define.hrl").

-define (MYSQL_WAIT_TIMEOUT,   (1 * ?HOUR_TO_SECOND) * 1000).       % 关闭连接最大时限
-define (GAME_MYSQL_HOLD_PING_TIMER, game_mysql_hold_ping_timer).   % 游戏数据库保持连接定时器引用


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

%%% @doc    写入数据
write (Data) ->
    ?SERVER ! {data, lib_misc:get_player_id(), Data}.

%%% @doc    数据库保持连接
game_mysql_hold_ping () ->
    catch timer:cancel(get(?GAME_MYSQL_HOLD_PING_TIMER)),
    try game_db_data:fetch("SELECT 1 FROM `db_version` LIMIT 1;")
    catch
        _ : _Reason ->
            ?ERROR("try_connect_db:~p at ~w~n", [_Reason, erlang:localtime()])
    end,
    TRef    = lib_misc:apply_after(?MYSQL_WAIT_TIMEOUT, ?MODULE, game_mysql_hold_ping, []),
    put(?GAME_MYSQL_HOLD_PING_TIMER, TRef).


%%% ========== ======================================== ====================
%%% callback
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, State}.
%%% @doc    gen_server init, opens the server in an initial state.
init ([]) ->
    filelib:ensure_dir(?GAME_TIMER_DIR),
    Date        = date(),
    {ok, File}  = open_log_file(Date),
    {ok, #state{date = Date, file = File}}.

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
handle_cast (game_mysql_hold_ping, State) ->
    game_mysql_hold_ping(),
    {noreply, State};
handle_cast (Request, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {cast, Request}]),
    {noreply, State}.

%%% @spec   handle_info(Info, State) -> tuple().
%%% @doc    gen_server callback.
handle_info ({data, PlayerId, Data}, State = #state{date = Date, file = File}) ->
    NowDate  = date(),
    NewState = case NowDate of
        Date ->
            State;
        _ ->
            ok = file:close(File),
            {ok, NewFile} = open_log_file(NowDate),
            State #state{date = NowDate, file = NewFile}
    end,
    Record  = #game_timer{
        player_id   = PlayerId,
        from        = element(1, Data),
        to          = element(2, Data),
        after_time  = element(3, Data),
        message     = element(4, Data),
        date_time   = erlang:localtime()
    },
    try write_to_file(NewState #state.file, Record)
    catch
        _ : Reason ->
            ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {write_log_failed, Reason}])
    end,
    {noreply, NewState};
handle_info (timeout, State) ->
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
%%% @doc    打开对应日志文件
open_log_file (Date) ->
    FileName = ?GAME_TIMER_DIR ++ lib_misc:ymd_tuple_to_cover0str(Date, "_") ++ ".timer",
    file:open(FileName, [append, raw, {delayed_write, 1024 * 100, 2000}]).

write_to_file (File, Data) ->
    DataString  = io_lib:format("~w~n", [Data]),
    DataBin     = list_to_binary(DataString),
    ok          = file:write(File, DataBin).

