-module (game_log).

-author ("CHEONGYI").

-behaviour (gen_server).

-export ([start_link/0]).
-export ([stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([write/3]).

-include ("define.hrl").

-record (state, {date, file}).


%% ======================================================================
%% @todo   启动进程
start_link () ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% @todo   停止进程
stop () ->
    gen_server:call(?MODULE, stop). 

%% ++++++++++++++++++++ gen_server 6 callbacks ++++++++++++++++++++
%% @todo   初始化
init ([]) ->
    filelib:ensure_dir(?GAME_LOG_DIR),
    Date        = date(),
    {ok, File}  = open_log_file(Date),
    {ok, #state{date = Date, file = File}}.

%% @todo   gen_server:call callback
handle_call (stop, _From, State) ->
    {stop, shutdown, stopped, State};
handle_call (Request, From, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {call, Request, From}]),
    {reply, ok, State}.

%% @todo   gen_server:cast callback
handle_cast (Request, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {cast, Request}]),
    {noreply, State}.

%% @todo   ?MODULE ! Msg callback
handle_info ({log, Log}, State = #state{date = Date, file = File}) ->
    NowDate  = date(),
    NewState = case NowDate of
        Date ->
            State;
        _ ->
            ok = file:close(File),
            {ok, NewFile} = open_log_file(NowDate),
            State #state{date = NowDate, file = NewFile}
    end,
    try write_log(Log, NewState #state.file)
    catch
        _ : Reason ->
            ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {write_log_failed, Reason}])
    end,
    {noreply, NewState};
handle_info (Info, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {info, Info}]),
    {noreply, State}.

%% @todo   stop or terminate callback
terminate (Reason, _State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {terminate, Reason}]),
    ok.

%% @doc gen_server code_change callback (trivial).
code_change (_Vsn, State, _Extra) ->
    {ok, State}.


%% ----------------------------------------------------------------------
%% @todo   打开对应日志文件
open_log_file (Date) ->
    FileName = ?GAME_LOG_DIR ++ lib_time:ymd_tuple_to_cover0str(Date, "_") ++ ".error.log",
    file:open(FileName, [append, raw, {delayed_write, 1024 * 100, 2000}]).

%% @todo   打印log信息或写入日志文件
write_log ({info, PlayerId, Message, ArgumentList}, _) ->
    io:format("[info] from player " ++ integer_to_list(PlayerId) ++ " : " ++ Message, ArgumentList);
write_log ({LogType, PlayerId, Message, ArgumentList}, File) ->
    write_log_to_file (File, get_log_title(PlayerId), Message, ArgumentList),
    ?FORMAT(
        lib_time:ymdhms_tuple_to_cover0str(erlang:localtime()) ++ " [~p] from player ~p~n" 
            ++ Message ++ "~n~n",
        [LogType, PlayerId | ArgumentList]
    );
write_log ({info, Message, ArgumentList}, _) ->
    io:format("[info] : " ++ Message, ArgumentList);
write_log ({LogType, Message, ArgumentList}, File) ->
    write_log_to_file (File, get_log_title(), Message, ArgumentList),
    ?FORMAT(
        lib_time:ymdhms_tuple_to_cover0str(erlang:localtime()) ++ " [~p]~n" 
            ++ Message ++ "~n~n",
        [LogType | ArgumentList]
    ).
write_log_to_file (File, LogTitle, Message, ArgumentList) ->
    LogTitle    = get_log_title(),
    LogContent  = io_lib:format(LogTitle ++ Message ++ "~n~n", ArgumentList),
    LogBin      = list_to_binary(LogContent),
    ok          = file:write(File, LogBin).
    
get_log_title(PlayerId) ->
    lib_time:ymdhms_tuple_to_cover0str(erlang:localtime())
        ++ " from player " ++ integer_to_list(PlayerId) ++ "~n".
    
get_log_title() ->
    lib_time:ymdhms_tuple_to_cover0str(erlang:localtime()) ++ "~n".


%% @todo   写日志
write (LogType, Message, ArgumentList) ->
    case get(the_player_id) of
        undefined -> ?MODULE ! {log, {LogType, Message, ArgumentList}};
        PlayerId  -> ?MODULE ! {log, {LogType, PlayerId, Message, ArgumentList}}
    end.



    