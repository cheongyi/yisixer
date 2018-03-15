-module (test).

-compile (export_all).

-include("define.hrl").
% -include ("../src/test_record.erl").

% get_record () ->
%     #test_record{}.

debug_catch () ->
    ?CATCH(fun() -> ?DEBUG("debug_catch~n", []), exit(debug_catch) end),
    ok.

test() ->  
    P = spawn(fun() -> receive ok -> ok end end),  
    MonitorRef = erlang:monitor(process, P),  
      
    P ! test,  
    io:format("send test~n"),  
    timer:sleep(1000),  
    receive Msg -> io:format("~p~n", [Msg])  
    after 0 -> io:format("timeout~n")  
    end,  
      
    P ! ok,  
    io:format("send ok~n~p~n", [{MonitorRef, P}]),  
    timer:sleep(1000),  
    receive Msg1 -> io:format("~p~n", [Msg1])  
    after 0 -> io:format("timeout~n")  
    end.  