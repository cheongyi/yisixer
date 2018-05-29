-module (game_prof).

%%% @doc    游戏性能分析

-author     ("CHEONGYI").
-date       ({2018, 03, 06}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2018 YiSiXEr").

-behaviour  (gen_server).

-export ([start_link/0]).
-export ([stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    statistics_start/0,                 % 统计开始
    statistics_end/2,                   % 统计结束
    write/1                             % 写入游戏性能分析文件
]).

-include ("define.hrl").

-define (SERVER, ?MODULE).
-define (TABLE_NAME, game_prof_data).

-record (state, {}).
-record (?TABLE_NAME, {
    key,
    times       = 0,    
    runtime     = 0,
    wallclock   = 0
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


%%% ========== ======================================== ====================
%%% ++++++++++++++++++++ gen_server 6 callbacks ++++++++++++++++++++
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, State}
%%% @doc    gen_server init, opens the server in an initial state.
init ([]) ->
    filelib:ensure_dir(?GAME_PROF_DIR),
    ets:new(?TABLE_NAME, [set, named_table, protected, {keypos, #game_prof_data.key}]),
    {ok, #state{}}.

%%% @spec   handle_call(Args, From, State) -> tuple()
%%% @doc    gen_server callback.
handle_call ({get_info}, _From, State) ->
    Result = lib_ets:tab2list(?TABLE_NAME),
    {reply, {perf, Result}, State};
handle_call ({get_info, Module}, _From, State) ->
    Result = lib_ets:select(
        ?TABLE_NAME, 
        [{
            #game_prof_data{
                key = {Module, '_', '_'}, 
                _ = '_'
                }, 
                [], 
                {'$_'}
        }]
    ),
    {reply, {perf, Result}, State};
handle_call ({get_info, Module, Fuction}, _From, State) ->
    Result = lib_ets:select(
        ?TABLE_NAME, 
        [{
            #game_prof_data{
                key = {Module, Fuction, '_'}, 
                _ = '_'
                }, 
                [], 
                {'$_'}
        }]
    ),
    {reply, {perf, Result}, State};
handle_call ({get_info, Module, Fuction, ArgsNum}, _From, State) ->
    Result = lib_ets:get(?TABLE_NAME, {Module, Fuction, ArgsNum}),
    {reply, {perf, Result}, State};
handle_call (stop, _From, State) ->
    {stop, shutdown, stopped, State};
handle_call (Request, From, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {call, Request, From}]),
    {reply, {error, badrequest}, State}.

%%% @spec   handle_cast(Cast, State) -> tuple()
%%% @doc    gen_server callback.
handle_cast ({set_info, Key, Runtime, Wallclock}, State) ->
    Date = case lib_ets:get(?TABLE_NAME, Key) of
        [] ->
            #game_prof_data{};
        [TheDate] ->
            TheDate
    end,
    R = 
    lib_ets:insert(
        ?TABLE_NAME, 
        Date #game_prof_data{
            key       = Key,
            times     = Date #game_prof_data.times     + 1,
            runtime   = Date #game_prof_data.runtime   + Runtime,
            wallclock = Date #game_prof_data.wallclock + Wallclock
        }, 
        replace
    ),
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {cast, Date, R}]),
    {noreply, State};
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


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    统计开始
statistics_start () ->
    {RunTime1,   _} = statistics(runtime),
    {WallClock1, _} = statistics(wall_clock),
    {RunTime1, WallClock1}.

%%% @doc    统计结束
statistics_end (Key, {RunTime1, WallClock1}) ->
    {RunTime2,   _} = statistics(runtime),
    {WallClock2, _} = statistics(wall_clock),
    RunTimeSecond   = (RunTime2   - RunTime1)   / 1000.0,
    WallClockSecond = (WallClock2 - WallClock1) / 1000.0,
    gen_server:cast(?SERVER, {set_info, Key, RunTimeSecond, WallClockSecond}).

%%% @doc    写入游戏性能分析文件
write (Mode) ->
    SortFun = fun(A, B) -> 
        case Mode of
            wallclock ->
                RateA = A #game_prof_data.wallclock / A #game_prof_data.times,
                RateB = B #game_prof_data.wallclock / B #game_prof_data.times,
                RateA > RateB;
            runtime ->
                RateA = A #game_prof_data.runtime / A #game_prof_data.times,
                RateB = B #game_prof_data.runtime / B #game_prof_data.times,
                RateA > RateB;
            times ->
                RateA = A #game_prof_data.times,
                RateB = B #game_prof_data.times,
                RateA > RateB;
            total_wallclock ->
                RateA = A #game_prof_data.wallclock,
                RateB = B #game_prof_data.wallclock,
                RateA > RateB;
            total_runtime ->
                RateA = A #game_prof_data.runtime,
                RateB = B #game_prof_data.runtime,
                RateA > RateB
        end
    end,
    {perf, List}= gen_server:call(?SERVER, {get_info}),
    SortList    = lists:sort(SortFun, List),
    FileName    = ?GAME_PROF_DIR ++ lib_time:ymd_tuple_to_cover0str(date(), "_") ++ "." ++ atom_to_list(Mode),
    {ok, File}  = file:open(FileName, [write, raw]),
    file:write(File, io_lib:format("+--------------------+--------------------+--------------------+--------------------+--------------------+~n",[])),
    file:write(File, io_lib:format("| Module:Function/ArgsNum                                      |                    |                    |~n",[])),
    file:write(File, io_lib:format("+--------------------------------------------------------------|                    |                    |~n",[])),
    % file:write(File, io_lib:format("+-- -- -- -- -- -- --+--------------------+--------------------+--------------------+--------------------+~n",[])),
    file:write(File, io_lib:format("| Times              |            Runtime |          Wallclock |      Total Runtime |    Total Wallclock |~n",[])),
    file:write(File, io_lib:format("+--------------------+--------------------+--------------------+--------------------+--------------------+~n",[])),
    file:write(File, io_lib:format("+--------------------+--------------------+--------------------+--------------------+--------------------+~n",[])),
    loop_write(File, SortList).


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    循环写入游戏性能分析文件
loop_write (File, []) ->
    ok = file:close(File);
loop_write (File, [#game_prof_data{key = {Module, Fuction, ArgsNum}, times = Times, runtime = Runtime, wallclock = Wallclock} | List]) ->
    ModuleFunctionArgsNum = atom_to_list(Module) ++ ":" ++ atom_to_list(Fuction) ++ "/" ++ integer_to_list(ArgsNum),
    % ModuleFunctionArgsLen = length(ModuleFunctionArgsNum),
    % if
    %     ModuleFunctionArgsLen < 19 ->
    %         file:write(File, io_lib:format("| ~-19.19. s|                    |                    |                    |                    |~n", [ModuleFunctionArgsNum]));
    %     ModuleFunctionArgsLen < 40 ->
    %         file:write(File, io_lib:format("| ~-40.40. s|                    |                    |                    |~n", [ModuleFunctionArgsNum]));
    %     ModuleFunctionArgsLen < 61 ->
    %         file:write(File, io_lib:format("| ~-61.61. s|                    |                    |~n", [ModuleFunctionArgsNum]));
    %     ModuleFunctionArgsLen < 82 ->
    %         file:write(File, io_lib:format("| ~-82.82. s|                    |~n", [ModuleFunctionArgsNum]));
    %     true ->
    %         file:write(File, io_lib:format("| ~-103.103. s|~n", [ModuleFunctionArgsNum]))
    % end,
    file:write(File, io_lib:format("| ~-61.61. s|                    |                    |~n", [ModuleFunctionArgsNum])),
    file:write(File, io_lib:format("+--------------------------------------------------------------|                    |                    |~n",[])),
    file:write(File, io_lib:format("| Times: ~-11.b |~19.f |~19.f |~19.f |~19.f |~n", [Times, Runtime / Times, Wallclock / Times, Runtime, Wallclock])),
    file:write(File, io_lib:format("+--------------------+--------------------+--------------------+--------------------+--------------------+~n",[])),
    loop_write(File, List).

