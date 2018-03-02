-module (test).

-compile (export_all).

-include("define.hrl").
% -include ("../src/test_record.erl").

% get_record () ->
%     #test_record{}.

debug_catch () ->
    ?CATCH(fun() -> ?DEBUG("debug_catch~n", []), exit(debug_catch) end),
    ok.