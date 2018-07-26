-module (game_db_sync_sup).

%%% @doc    游戏数据库同步督程

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 19}).
-vsn        ("1.0.0").

-behaviour  (supervisor).

-export ([start_link/0]).
-export ([init/1]).

-include ("define.hrl").

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
        {game_db_sync_srv,      {game_db_sync_srv,      start_link, []}, permanent, brutal_kill, worker, [game_db_sync_srv]},
        {game_db_sync_to_file,  {game_db_sync_to_file,  start_link, []}, permanent, brutal_kill, worker, [game_db_sync_to_file]},
        {game_db_sync_to_db,    {game_db_sync_to_db,    start_link, []}, permanent, brutal_kill, worker, [game_db_sync_to_db]}
    ],
    {ok, {{one_for_one, 10, 10}, ChildSpecs}}.