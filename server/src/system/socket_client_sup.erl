-module (socket_client_sup).

%%% @doc    

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 04, 14}).
-vsn        ("1.0.0").

-behaviour  (supervisor).

-export ([start_link/0]).
-export ([init/1]).
-export ([start_child/0, count_child/0, kill_all/0]).

-define (SERVER, ?MODULE).
-define (GAME_SERVER_MAX_CONN, ?GET_ENV(socket_server_max_conn, 10000)).

-include ("define.hrl").
% -include ("record.hrl").
% -include ("gen/game_db.hrl").
% -include ("api/api_code.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    Start the process and link.
start_link () ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).


%%% @doc    启动子进程
start_child () ->
    MaxConn = ?GAME_SERVER_MAX_CONN,
    case count_child() of
        MaxConn ->
            {error, max_conn};
        _ ->
            supervisor:start_child(?SERVER, [])
    end.

%%% @doc    统计子进程
count_child () ->
    supervisor:count_children(?SERVER).

%%% @doc    关闭子进程
kill_all () ->
    [
        socket_client_srv:kill_for_game_stop(Pid)
        ||
        {_SrvName, Pid, worker, [socket_client_srv]} <- supervisor:which_children(?SERVER)
    ].


%%% ========== ======================================== ====================
%%% callback
%%% ========== ======================================== ====================
%%% @doc    Process start callback.
init ([]) ->
    ChildSpecs = [
        {
            socket_client_srv, 
            {socket_client_srv, start_link, []}, 
            temporary, 
            brutal_kill, 
            worker, 
            [socket_client_srv]
        }

    ],
    {ok, {{simple_one_for_one, 10, 10}, ChildSpecs}}.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================


