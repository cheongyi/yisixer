-module (queens).

%%% @doc    八皇后

-author     ("CHEONGYI").
-date       ({2019, 06, 27}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2019 YiSiXEr").

-compile(export_all).
-export ([
    queens/1
]).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
queens (0) -> [[]];
queens (N) ->
    [
        [Row | Columns]
        ||
        Columns <- queens(N -1),
        Row <- [1, 2, 3, 4, 5, 6, 7, 8] -- Columns,
        safe(Row, Columns, 1)
    ].

safe (_Row, [], _N) -> true;
safe (Row, [Column | Columns], N) ->
    (Row /= Column + N) andalso
    (Row /= Column - N) andalso
    safe(Row, Columns, (N + 1)).



-define(MaxQueen, 8).%寻找字符串所有可能的排列
%perms([]) ->% [[]];
%perms(L) ->% [[H | T] || H <- L, T <- perms(L -- [H])].
perms([]) ->[[]];
perms(L) ->[[H | T] || H <- L, T <- perms(L -- [H]), attack_range(H,T) == []].

printf(N) ->
    L = lists:seq(1, N),
    io:format("~p~n", [N]),
    perms(L).
%检测出第一行的数字攻击到之后各行哪些数字%left向下行的左侧检测%right向下行的右侧检测
attack_range(Queen, List) ->attack_range(Queen, left, List) ++ attack_range(Queen, right, List).

attack_range(_, _, []) ->[];
attack_range(Queen, left, [H | _]) when Queen - 1 =:= H ->[H];
attack_range(Queen, right, [H | _]) when Queen + 1 =:= H ->[H];
 
attack_range(Queen, left, [_ | T]) ->attack_range(Queen - 1, left, T);
attack_range(Queen, right, [_ | T]) ->attack_range(Queen + 1, right, T).