-module (test).

-author     ("CHEONGYI").
-date       ({2017, 11, 09}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2017 YiSiXEr").

-compile(export_all).
-export ([]).

-include("define.hrl").

%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
print (debug) ->
    ?DEBUG("print [debug]os:getpid() :~p~n", [os:getpid()]);
print (info) ->
    ?INFO("print   [info]os:version():~p~n", [os:getpid()]).
