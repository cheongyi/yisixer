-module (test).

-compile (export_all).

-include("define.hrl").
% -include ("../src/test_record.erl").

% get_record () ->
%     #test_record{}.

debug_catch () ->
    ?CATCH(fun() -> ?DEBUG("debug_catch~n", []), exit(debug_catch) end),
    ok.


test () ->
    Time = time(),
    case 1 of
        1 ->
            noop;
        _ ->
            X = a
    end,
    try io:format("~p~n", [a]) of
        _ ->
            X
    catch
        _ : _ ->
            ok
    end.