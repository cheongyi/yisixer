-module (hong_bao).

%%% @doc    参考链接：https://www.cnblogs.com/dreign/p/4610766.html

-author     ("CHEONGYI").
-date       ({2019, 06, 11}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2019 YiSiXEr").

-compile(export_all).
-export ([
    test/3
]).

-include("define.hrl").

-define (MIN_1_FEN,    20). % 每个人最少能收到 1分
-define (YUAN_TO_FEN, 100). % 元转分(1元=100分)


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
test (Total, Number, MineId) when Total > 0 andalso Number > 0 andalso Total * ?YUAN_TO_FEN >= Number->
    TotalFen    = trunc(Total * ?YUAN_TO_FEN),
    IndexList   = lib_misc:shuffle(lists:seq(1, Number)),
    io:format(lists:flatten(lists:duplicate(Number, "|=============")) ++ "|||==========|==========|========|~n", []),
    % io:format("+-------------+-------------+-------------+-------------+-------------+"
    %            "-------------+-------------+-------------+-------------+-------------+++----------+----------+~n", []),
    loop_open(TotalFen, Number, 1, MineId, 0, {TotalFen, 0}, [], IndexList).

loop_open (TotalFen, Index, Index, MineId, Mine, {Min, Max}, List, [Cur | _]) ->
    Money       = TotalFen,
    NewTotal    = TotalFen - Money,
    NewMine     = Mine + ?IIF((TotalFen rem 10) == MineId, 1, 0),
    [
        io:format("| (~2..0w) $ ~4.2.0f ", [CurIndex, EachMoney / ?YUAN_TO_FEN])
        ||
        {CurIndex, EachMoney} <- lists:sort([{Cur, TotalFen} | List])
    ],
    % io:format("(~2..0w) $ ~4.2.0f +++ $ ~4.2.0f~n", [Index, Money / ?YUAN_TO_FEN, NewTotal / ?YUAN_TO_FEN]),
    io:format("||| Min:~.2f | Max:~.2f | Mine:~p |~n", [min(Min, TotalFen) / ?YUAN_TO_FEN, max(Max, TotalFen) / ?YUAN_TO_FEN, NewMine]),
    % io:format("+-------------+-------------+-------------+-------------+-------------+"
    %            "-------------+-------------+-------------+-------------+-------------+----------+-----------+~n", []),
    % io:format("~p = ~p~n", [lists:sum([TotalFen | List]), [TotalFen | List]]),
    ok;
loop_open (TotalFen, Number, Index, MineId, Mine, {Min, Max}, List, [Cur | IndexList]) ->
    SafeTotal   = (TotalFen - (Number - Index) * ?MIN_1_FEN) div (Number - Index),   % 随机安全上限
    RandomMoney = lib_misc:random_number_2(?MIN_1_FEN, SafeTotal),
    MinMoney    = if
        RandomMoney >= ?MIN_1_FEN ->
            RandomMoney;
        true ->
            min(?MIN_1_FEN + lib_misc:random_number(?MIN_1_FEN - RandomMoney), SafeTotal)
    end,
    Money       = case lib_misc:get_probability(1 / Number * 95) of
        true ->
            (MinMoney div 10) * 10 + MineId;
        _ ->
            NonMineIdList   = lists:seq(0, 9) -- [MineId],
            (MinMoney div 10) * 10 + lists:nth(lib_misc:random_number(length(NonMineIdList)), NonMineIdList)
    end,
    NewMine     = Mine + ?IIF((Money rem 10) == MineId, 1, 0),
    % Money       = max(?MIN_1_FEN, lib_misc:random_number(SafeTotal)),
    % Money       = max(1, lib_misc:random_number(SafeTotal)),
    NewTotal    = TotalFen - Money,
    % io:format("(~2..0w) $ ~4.2.0f +++ $ ~4.2.0f~n", [Index, Money / ?YUAN_TO_FEN, NewTotal / ?YUAN_TO_FEN]),
    % io:format("| (~2..0w) $ ~4.2.0f ", [Index, Money / ?YUAN_TO_FEN]),
    loop_open(NewTotal, Number, Index + 1, MineId, NewMine, {min(Min, Money), max(Max, Money)}, [{Cur, Money} | List], IndexList).
