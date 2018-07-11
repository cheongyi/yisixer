-module (test_proc).

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("WhoAreYou").
-date       ({2017, 11, 13}).
-vsn        ("1.0.0").

-export ([start_link/0]).
-export ([init/0]).

-include ("define.hrl").
% -include ("record.hrl").

-define (SERVER, ?MODULE).

-record (state, {}).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
start_link () ->
    proc_lib:start_link(?MODULE, init, []).

init () ->
    register(?SERVER, self()),
    proc_lib:init_ack({ok, self()}),
    loop(#state{}).


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
loop (State) ->
    receive
        _ ->
            ok
    end,
    loop(State).



