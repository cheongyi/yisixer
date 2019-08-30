-module (mod_test).

-copyright  ("Copyright © 2017-2019 Tools@YiSiXEr").
-author     ("WhoAreYou").
-date       ({2019, 07, 12}).
-vsn        ("1.0.0").

-export ([get/0]).

get () ->
    timer:sleep(6000),
    {
        self(),
        erlang:process_info(self(), monitored_by),
        erlang:process_info(self(), current_stacktrace)
    }.

