-module (four_color_sup).

-author ('Chen HongYi').

-behaviour (supervisor).

-export ([
    start_link/0,
    init/1
]).
-export ([
    auto_play/0
]).

-include ("define.hrl").


start_link () ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init (_) ->
    {
        ok,
        {
            {one_for_one, 10, 10},
            [
                {
                    four_color_srv,
                    {four_color_srv, start_link, []},
                    transient,
                    brutal_kill,
                    worker,
                    [four_color_srv]
                },
                {
                    four_color_auto_srv,
                    {four_color_auto_srv, start_link, []},
                    transient,
                    brutal_kill,
                    worker,
                    [four_color_auto_srv]
                }
            ]
        }
    }.

%% @todo   机器人自动开玩
auto_play () ->
    [
        supervisor:start_child(?MODULE, 
            {
                PlayerRegisteredName, 
                {four_color_robot_srv, start_link, [PlayerRegisteredName]}, 
                transient, 
                brutal_kill, 
                worker, 
                [four_color_robot_srv]
            }
        )
        ||
        PlayerRegisteredName <- ?FOUR_COLOR_PLAYER_SRV_LIST
    ],
    timer:sleep(1000),
    ?FOUR_COLOR_AUTO_SRV ! {auto_play}.



