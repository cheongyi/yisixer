<?php
    // 判断命令行参数
    if ($argc < 3) {
        echo "Argument error!\n";
        echo "Usage:   php make_erl_file.php [api|mod|sup|srv|app|] directory filename[.erl]\n";
        exit;
    }

    // 参数声明赋值
    $file_type  = $argv[1];
    $directory  = $argv[2];
    $filename   = str_replace(".erl", "", $argv[3]);

    if ($file_type == "api") {
        $filename   = "api_".$filename;
    } elseif ($file_type == "mod") {
        $filename   = "mod_".$filename;
    } elseif ($file_type == "sup") {
        $filename   = $filename."_sup";
    } elseif ($file_type == "srv") {
        $filename   = $filename."_srv";
    }
    $erl_file   = $directory.$filename;

    $file       = fopen($erl_file.".erl", 'x');

    fwrite($file, "-module (".$filename.").");
    write_attributes($file);

    if ($file_type == "api") {
        write_body();
    } elseif ($file_type == "mod") {
        write_body();
    } elseif ($file_type == "sup") {
        write_sup();
    } elseif ($file_type == "srv") {
        write_srv();
    } elseif ($file_type == "app") {
        write_app();
    } else {
        write_body();
    }

    fclose($file);


// =========== ======================================== ====================
// @todo    写入属性
function write_attributes($file) {
    fwrite($file, "

%%% @doc    

-copyright  (\"Copyright © 2017-".date("Y")." YiSiXEr\").
-author     (\"CHEONGYI\").
-date       ({".date("Y, m, d")."}).
-vsn        (\"1.0.0\").
");
}


// @todo    写入属性
function write_body($file) {
    fwrite($file, "
-export ([

]).

% -include (\"define.hrl\").
% -include (\"record.hrl\").
% -include (\"gen/game_db.hrl\").
% -include (\"api/api_code.hrl\").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================




");
}


// @todo    写入sup
function write_sup() {
    global $file;

    fwrite($file, "
-behaviour  (supervisor).

-export ([start_link/0]).
-export ([init/1]).

-include (\"define.hrl\").
-include (\"record.hrl\").

-define (SERVER, ?MODULE).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    Start the process and link.
start_link () ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%% ========== ======================================== ====================
%%% callback
%%% ========== ======================================== ====================
%%% @doc    Process start callback.
init ([]) ->
    ChildSpecs = [

    ],
    {ok, {{one_for_one, 10, 10}, ChildSpecs}}.




");
}


// @todo    写入srv
function write_srv() {
    global $file;

    fwrite($file, "
-behaviour  (gen_server).

-export ([start_link/0, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    get_state/0
]).

-include (\"define.hrl\").
-include (\"record.hrl\").

-define (SERVER, ?MODULE).

-record (state, {}).


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


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================




");
}


// @todo    写入app
function write_app() {
    global $file;

    fwrite($file, "
-behaviour  (application).
-behaviour  (supervisor).

-export ([start/0, stop/0, restart/0]).
-export ([start/2, stop/1]).
-export ([init/1]).

-include(\"define.hrl\").

-define (SERVER, ?MODULE).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    erl -s game start
start () ->
    application:start(?SERVER).

stop () ->
    %% 关闭应用
    application:stop(?SERVER).

restart () ->
    stop(),
    start().


%%% ========== ======================================== ====================
%%% callbacks  function
%%% ========== ======================================== ====================
start (_Type, _Args) ->
    Result = supervisor:start_link({local, ?SERVER}, ?MODULE, []),
    Result.

stop (_State) ->
    ok.

init ([]) ->
    {ok, {{one_for_one, 10, 10}, []}}.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================




");
}
?>