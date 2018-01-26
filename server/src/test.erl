-module (test).

-compile (export_all).

-include ("../src/test_record.erl").

get_record () ->
    #test_record{}.