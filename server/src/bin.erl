-module (bin).

-compile(export_all).

test1 (N) ->
    test1(N, <<>>).

test1 (0, Data) ->
    Data;
test1 (N, Data) ->
    test1(N - 1, <<N:64, Data/binary>>).

test2 (N) ->
    test2(N, <<>>).

test2 (0, Data) ->
    Data;
test2 (N, Data) ->
    test2(N - 1, <<Data/binary, N:64>>).