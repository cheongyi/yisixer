-module (game_db_sync_to_file).

-copyright  ("Copyright © 2018 YiSiXEr").
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
    case io:get_chars("Sync to file time out, continue?[Y/n] : ", 1) of
        "n" ->
            io:format("wait for all player data sync to file ... time out"),
            time_out;
        _   ->
            wait_for_all_data_sync_2(TimeOut, 0)
    end;
wait_for_all_data_sync_2 (TimeOut, Time) ->
    io:format("wait for all player data sync to file ... "),
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
handle_info ({to_file, SqlList}, State) ->
    File = case State #state.file of
        undefined ->
            {{Y, M, D}, {H, MM, SS}} = erlang:localtime(),
            erlang:send_after((?HOUR_TO_SECOND - (MM * 60 + SS)) * 1000, self(), {change_file}),
            get_sql_file({Y, M, D, H});
        OldFile   ->
            OldFile
    end,
    try file:write(File, [<<"\n">> | SqlList])
    catch
        Error ->
            ?ERROR("~p : SqlList = ~p~n  Error = ~p~n", [?SERVER, SqlList, Error])
    end,
    {noreply, State #state{file = File}};
handle_info ({change_file}, State) ->
    File    = State #state.file,
    ok      = file:close(File),
    {{Y, M, D}, {H, MM, SS}} = erlang:localtime(),
    NewFile = get_sql_file({Y, M, D, H}),
    erlang:send_after((?HOUR_TO_SECOND - (MM * 60 + SS)) * 1000, self(), {change_file}),
    {noreply, State #state{file = NewFile}};
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
get_sql_file ({Y, M, D, H}) ->
    FileName = ?GAME_DATA_DIR 
        ++ lib_time:ymdhms_integer_to_cover0str(Y) ++ "_" 
        ++ lib_time:ymdhms_integer_to_cover0str(M) ++ "_" 
        ++ lib_time:ymdhms_integer_to_cover0str(D) ++ "/" 
        ++ lib_time:ymdhms_integer_to_cover0str(H) ++ ".sql",
    case filelib:is_file(FileName) of
        true  -> ok;
        false -> ok = filelib:ensure_dir(FileName)
    end,
    {ok, File} = file:open(FileName, [append, raw, {delayed_write, 1024 * 1000, 6000}]),
    % {ok, File} = case mod_server:get_server_name() of
    %     "s0" ->
    %         file:open(FileName, [append, raw, {delayed_write, 1024 * 1000, 1000}]);
    %     _ServerName ->
    %         file:open(FileName, [append, raw, {delayed_write, 1024 * 1000 * 10, 6000}])
    % end,
    ok = file:write(File, <<"/*!40101 SET NAMES utf8 */;\n">>),
    ok = file:write(File, <<"/*!40101 SET SQL_MODE=''*/;\n">>),
    ok = file:write(File, <<"/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;\n">>),
    ok = file:write(File, <<"/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;\n">>),
    ok = file:write(File, <<"/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;\n">>),
    ok = file:write(File, <<"/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;\n\n">>),
    File.



