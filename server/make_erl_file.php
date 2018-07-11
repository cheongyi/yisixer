<?php
    // 判断命令行参数
    if ($argc < 2) {
        echo "Argument error!\n";
        echo "Usage:   php make_erl_file.php directory/filename[.erl] [api|mod|sup|srv|app|]\n";
        exit;
    }

    // 参数声明赋值
    $erl_file   = explode('/', str_replace(".erl", "", $argv[1]));
    $file_type  = $argv[2];
    $filename   = end($erl_file);

    $erl_file   = implode('/', $erl_file).'.erl';
    if ($file   = @fopen($erl_file, 'x')) {
        write_module($file, $filename);
        write_author($file);

        if ($file_type == "api") {
            write_api($file, $filename);
        } elseif ($file_type == "mod") {
            write_general($file);
        } elseif ($file_type == "sup") {
            write_sup($file);
        } elseif ($file_type == "srv") {
            write_srv($file);
        } elseif ($file_type == "app") {
            write_app($file);
        } else {
            write_general($file);
        }

        fclose($file);
    }
    else {
        echo "Error:   file {$erl_file} already exist!\n";
    }


// =========== ======================================== ====================
// @todo    写入模块声明
function write_module($file, $filename) {
    fwrite($file, "-module (".$filename.").
");
}


// @todo    写入作者信息声明
function write_author($file) {
    fwrite($file, "
%%% @doc    

-copyright  (\"Copyright © 2017-".date("Y")." Tools@YiSiXEr\").
-author     (\"WhoAreYou\").
-date       ({".date("Y, m, d")."}).
-vsn        (\"1.0.0\").
");
}


// @todo    写入常规
function write_general($file) {
    write_export($file);
    write_include($file);
    write_external_api_note($file);
    write_internal_api_note($file);
}


// @todo    写入空export声明
function write_export($file) {
    fwrite($file, "
-export ([

]).
");
}


// @todo    写入include声明
function write_include($file) {
    fwrite($file, "
% -include (\"define.hrl\").
% -include (\"record.hrl\").
% -include (\"gen/api_enum.hrl\").
% -include (\"gen/class.hrl\").
% -include (\"gen/game_db.hrl\").

");
}


// @todo    写入ExternalApi注释
function write_external_api_note($file) {
    fwrite($file, "
%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================");
}


// @todo    写入InternalApi注释
function write_internal_api_note($file) {
    fwrite($file, "
%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================


");
}


// @todo    写入callback注释
function write_callback_note($file) {
    fwrite($file, "
%%% ========== ======================================== ====================
%%% callback
%%% ========== ======================================== ====================");
}


// =========== ======================================== ====================
// @todo    写入api
function write_api($file, $filename) {
    fwrite($file, "
-export ([
    action/1,                   % 
    action/2                    % 
]).
");
    write_include($file);
    write_external_api_note($file);
    fwrite($file, "
%%% @doc    1
action (State  = #client_state{player_id = PlayerId}) ->
    OutBin = {$filename}_out:action({}),
    {State, OutBin}.


%%% @doc    2
action (Args, State  = #client_state{player_id = PlayerId}) ->
    OutBin = {$filename}_out:action({}),
    {State, OutBin}.
");
    write_internal_api_note($file);
}


// @todo    写入sup
function write_sup($file) {
    fwrite($file, "
-behaviour  (supervisor).

-export ([start_link/0]).
-export ([init/1]).

-define (SERVER, ?MODULE).
");

    write_include($file);

    write_external_api_note($file);
    fwrite($file, "
%%% @doc    Start the process and link.
start_link () ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

");

    write_callback_note($file);
    fwrite($file, "
%%% @doc    Process start callback.
init ([]) ->
    ChildSpecs = [

    ],
    {ok, {{one_for_one, 10, 10}, ChildSpecs}}.

");

    write_internal_api_note($file);
}


// @todo    写入srv
function write_srv($file) {
    fwrite($file, "
-behaviour  (gen_server).

-export ([start_link/0, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    get_state/0
]).

-define (SERVER, ?MODULE).

-record (state, {}).
");

    write_include($file);

    write_external_api_note($file);
    fwrite($file, "
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

");

    write_callback_note($file);
    fwrite($file, "
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
    ?INFO(\"~p, ~p, ~p~n\", [?MODULE, ?LINE, {call, Request, From}]),
    {reply, {error, badrequest}, State}.

%%% @spec   handle_cast(Cast, State) -> tuple().
%%% @doc    gen_server callback.
handle_cast (Request, State) ->
    ?INFO(\"~p, ~p, ~p~n\", [?MODULE, ?LINE, {cast, Request}]),
    {noreply, State}.

%%% @spec   handle_info(Info, State) -> tuple().
%%% @doc    gen_server callback.
handle_info (Info, State) ->
    ?INFO(\"~p, ~p, ~p~n\", [?MODULE, ?LINE, {info, Info}]),
    {noreply, State}.

%%% @spec   terminate(Reason, State) -> ok.
%%% @doc    gen_server termination callback.
terminate (Reason, _State) ->
    ?INFO(\"~p, ~p, ~p~n\", [?MODULE, ?LINE, {terminate, Reason}]),
    ok.

%%% @spec   code_change(_OldVsn, State, _Extra) -> tuple().
%%% @doc    gen_server code_change callback (trivial).
code_change (_Vsn, State, _Extra) ->
    {ok, State}.

");

    write_internal_api_note($file);
}


// @todo    写入app
function write_app($file) {
    fwrite($file, "
-behaviour  (application).
-behaviour  (supervisor).

-export ([start/0, stop/0, restart/0]).
-export ([start/2, stop/1]).
-export ([init/1]).

-define (SERVER, ?MODULE).
");

    write_include($file);

    write_external_api_note($file);
    fwrite($file, "
%%% @doc    erl -s game start
start () ->
    application:start(?SERVER).

stop () ->
    %% 关闭应用
    application:stop(?SERVER).

restart () ->
    stop(),
    start().

");

    write_callback_note($file);
    fwrite($file, "
start (_Type, _Args) ->
    Result = supervisor:start_link({local, ?SERVER}, ?MODULE, []),
    Result.

stop (_State) ->
    ok.

init ([]) ->
    {ok, {{one_for_one, 10, 10}, []}}.

");

    write_internal_api_note($file);
}
?>