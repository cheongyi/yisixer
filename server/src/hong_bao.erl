-module (hong_bao).

-author     ("CHEONGYI").
-date       ({2019, 06, 11}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2019 YiSiXEr").

-compile(export_all).
-export ([
    test/2
]).

-define (MIN_1_FEN,     1). % 每个人最少能收到 1分
-define (YUAN_TO_FEN, 100). % 元转分(1元=100分)


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
test (Total, Number) when Total > 0 andalso Number > 0 ->
    TotalFen    = Total * ?YUAN_TO_FEN,
    loop_open(TotalFen, Number, 1, {TotalFen, 0}, []).

loop_open (TotalFen, Index, Index, {Min, Max}, List) ->
    Money       = TotalFen,
    NewTotal    = TotalFen - Money,
    io:format("~2..0w Money $ ~-4.2.0f === Total $ ~-4.2.0f~n", [Index, Money / ?YUAN_TO_FEN, NewTotal / ?YUAN_TO_FEN]),
    io:format("~nMin:~p~nMax:~p~n", [min(Min, TotalFen) / ?YUAN_TO_FEN, max(Max, TotalFen) / ?YUAN_TO_FEN]),
    io:format("~p = ~p~n", [lists:sum([TotalFen | List]), [TotalFen | List]]);
loop_open (TotalFen, Number, Index, {Min, Max}, List) ->
    SafeTotal   = (TotalFen - (Number - Index) * ?MIN_1_FEN) div (Number - Index),   % 随机安全上限
    Money       = lib_misc:random_number(SafeTotal),
    NewTotal    = TotalFen - Money,
    io:format("~2..0w Money $ ~-4.2.0f === Total $ ~-4.2.0f~n", [Index, Money / ?YUAN_TO_FEN, NewTotal / ?YUAN_TO_FEN]),
    loop_open(NewTotal, Number, Index + 1, {min(Min, Money), max(Max, Money)}, [Money | List]).
