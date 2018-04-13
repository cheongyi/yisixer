-module (game_mysql_auth).

-copyright  ("Copyright © 2017 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 15}).
-vsn        ("1.0.0").

% -compile (export_all).
-export ([
    do_new_auth/8,                              % 执行MySQL认证
    do_old_auth/7                               % 执行旧式MySQL认证
]).

-include ("define.hrl").
% -include ("record.hrl").

-define (SERVER, ?MODULE).

-define (HASH_SHA(Data),             crypto:hash(sha, Data)).
-define (HASH_FINAL(Context),        crypto:hash_final(Context)).
-define (HASH_UPDATE(Context, Salt), crypto:hash_update(Context, Salt)).
-define (HASH_INIT(),                crypto:hash_init(sha)).

-define (LONG_PASSWORD,             1).
-define (FOUND_ROWS,                2).
-define (LONG_FLAG,                 4).
-define (CONNECT_WITH_DB,           8).
-define (PROTOCOL_41,               512).
-define (TRANSACTIONS,              8192).
-define (SECURE_CONNECTION,         32768).
-define (CLIENT_MULTI_STATEMENTS,   65536).
-define (CLIENT_MULTI_RESULTS,      131072).
-define (MAX_PACKET_SIZE, 1000000).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    执行MySQL认证
%%% @descrip    Perform MySQL authentication.
do_new_auth (RecvPid, Socket, SequenceNum, User, Password, Salt1, Salt2, LogFun) ->
    Auth    = password_new(Password, Salt1 ++ Salt2),
    Data    = make_new_auth(User, Auth, ""),
    game_mysql_conn:do_send(Socket, Data, SequenceNum, LogFun),
    case game_mysql_conn:do_recv(RecvPid, SequenceNum, LogFun) of
        {ok, <<254:8>>, ResponseNum} ->
            OldAuth = password_old(Password, Salt1),
            game_mysql_conn:do_send(Socket, <<OldAuth/binary, 0:8>>, ResponseNum + 1, LogFun),
            game_mysql_conn:do_recv(RecvPid, SequenceNum + 1, LogFun);
        {ok, Packet, ResponseNum} ->
            {ok, Packet, ResponseNum};
        {error, Reason} ->
            {error, Reason}
    end.

%%% @doc    执行旧式MySQL认证
%%% @descrip    Perform old-style MySQL authentication.
do_old_auth (RecvPid, Socket, SequenceNum, User, Password, Salt1, LogFun) ->
    Auth    = password_old(Password, Salt1),
    Data    = make_old_auth(User, Auth),
    game_mysql_conn:do_send(Socket, Data, SequenceNum, LogFun),
    game_mysql_conn:do_recv(RecvPid, SequenceNum, LogFun).


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    新式加密密码
password_new (Password, Salt) ->
    Digest1 = ?HASH_SHA(Password),
    Digest2 = ?HASH_SHA(Digest1),
    Digest3 = ?HASH_FINAL(
        ?HASH_UPDATE(
            ?HASH_UPDATE(?HASH_INIT(), Salt),
            Digest2
        )
    ),
    bxor_binary(Digest3, Digest1).

bxor_binary (Digest3, Digest1) ->
    list_to_binary(
        dual_map(
            fun(Element3, Element1) -> Element3 bxor Element1 end,
            binary_to_list(Digest3),
            binary_to_list(Digest1),
            []
        )
    ).

dual_map (Fun, [Element3 | Digest3], [Element1 | Digest1], List) ->
    dual_map(Fun, Digest3, Digest1, [Fun(Element3, Element1) | List]);
dual_map (_Fun, [], [], List) ->
    lists:reverse(List).

%%% @doc    生成新式认证
make_new_auth (User, Password, Database) ->
    DbCaps = case Database of
        "" -> 0;
        _  -> ?CONNECT_WITH_DB
    end,
    %% 1 bor 4 bor 8192 bor 512 bor 32768 bor 65536 bor 131072 bor 0|8 bor 2.
    Caps  = ?LONG_PASSWORD
        bor ?LONG_FLAG
        bor ?TRANSACTIONS
        bor ?PROTOCOL_41
        bor ?SECURE_CONNECTION
        bor ?CLIENT_MULTI_STATEMENTS
        bor ?CLIENT_MULTI_RESULTS
        bor  DbCaps
        bor ?FOUND_ROWS,
    MaxSize     = ?MAX_PACKET_SIZE,
    UserBin     = list_to_binary(User),
    PasswordLen = size(Password),
    DatabaseBin = list_to_binary(Database),
    <<
        Caps:32/little, MaxSize:32/little, 8:8, 0:23/integer-unit:8, 
        UserBin/binary, 0:8, 
        PasswordLen:8, Password/binary, DatabaseBin/binary
    >>.


%%% @doc    生成旧式认证
make_old_auth (User, Password) ->
    %% 1 bor 4 bor 8192 bor 512 bor 32768 bor 65536 bor 131072 bor 0|8 bor 2.
    Caps  = ?LONG_PASSWORD 
        bor ?LONG_FLAG
        bor ?TRANSACTIONS 
        bor ?FOUND_ROWS,
    Maxsize      = 0,
    UserBin      = list_to_binary(User),
    PasswordBin  = list_to_binary(Password),
    <<
        Caps:16/little, Maxsize:24/little, 
        UserBin/binary, 0:8,
        PasswordBin/binary
    >>.

%%% @doc    旧式加密密码
password_old (Password, Salt) ->
    {Password1, Password2} = hash(Password),
    {Salt1,     Salt2}     = hash(Salt),
    Seed1 = Password1 bxor Salt1,
    Seed2 = Password2 bxor Salt2,
    List  = rnd(9, Seed1, Seed2),
    {L, [Extra]} = lists:split(8, List),
    list_to_binary(lists:map(fun(Element) -> Element bxor (Extra - 64)end, L)).

hash (String) ->
    hash(String, 1345345333, 305419889, 7).
hash ([C | String], N1, N2, Add) ->
    N1_1  = N1 bxor (((N1 band 63) + Add) * C + N1 * 256),
    N2_1  = N2 + ((N2 * 256) bxor N1_1),
    Add_1 = Add + C,
    hash(String, N1_1, N2_1, Add_1);
hash ([], N1, N2, _Add) ->
    Mask = (1 bsl 31) - 1,
    {N1 band Mask, N2 band Mask}.

rnd (N, Seed1, Seed2) ->
    Mod = (1 bsl 30) - 1,
    rnd(N, [], Seed1 rem Mod, Seed2 rem Mod).

rnd (0, List, _, _) ->
    lists:reverse(List);
rnd (N, List, Seed1, Seed2) ->
    Mod     = (1 bsl 30) - 1,
    NSeed1  = (Seed1 * 3 + Seed2)      rem Mod,
    NSeed2  = (NSeed1    + Seed2 + 33) rem Mod,
    Float   = (float(NSeed1) / float(Mod)) * 31,
    Val     = trunc(Float) + 64,
    rnd(N - 1, [Val | List], NSeed1, NSeed2).







