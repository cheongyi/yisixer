-module (lib_misc).

%%% @doc    公用库函数
%%% @doc    计时起点时间为 UNIX时间 {{1970, 01, 01}, {00, 00, 00}}
%%% @doc    62167219200 = calendar:datetime_to_gregorian_seconds({{1970, 01, 01}, {00, 00, 00}})
%%% @doc    线上版本统一用 格林尼\威治标准时间（Greenwich Mean Time，GMT）
%%% @doc    开发版本则采用 本地时区如中国时区cn:+0800相差
%%% @doc    28800 = 62167248000 - 62167219200 = 3600 * 8

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 07, 11}).
-vsn        ("1.0.0").

-compile(export_all).

-export ([
]).

-include("define.hrl").

-define (DATA_LEN_SIZE, 2).     % 数据长度占字节数
-define (DAY_BEGIN_HMS,             {00, 00, 00}).      % 一天开始的时分秒
-define (UNIX_FIRST_YEAR_TIMESTAMP, 62167219200).       % 计算机元年时间戳


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    定时发送消息
send_after (Time, Dest, Msg) ->
    Pid     = if
        is_pid(Dest) -> Dest;
        true         -> whereis(Dest)
    end,
    Timer   = erlang:send_after(max(Time, 0), Pid, Msg),
    ?TIMER({self(), {Pid, Dest}, Time, Msg}),
    Timer.

%%% @doc    定时应用MFA
apply_after (Time, Module, Function, Arguments) ->
    {ok, TRef}  = timer:apply_after(max(Time, 0), Module, Function, Arguments),
    ?TIMER({self(), {Module, Function}, Time, Arguments}),
    TRef.



%%% @doc    TCP发送
-ifdef (debug).
tcp_send (Socket, OutBin) ->
    Bin  = build_client_data(OutBin),
    ?DEBUG("~p~n", [Bin]),
    case gen_tcp:send(Socket, Bin) of
        {error, Reason} ->
            exit({game_tcp_send_error, Reason});
        _ ->
            true
    end.
-else.
tcp_send (Socket, OutBin) ->
    IsCanSend = true,
    if
        IsCanSend ->
            Bin  = build_client_data(OutBin),
            CompressBin = if
                size(Bin) > 64 ->
                    Mod = binary:part(Bin, 0, 4),
                    case Mod of
                        %% admin模块不压缩
                        <<0, 99, _, _>> ->
                            Bin;
                        _ ->
                            zlib:compress(Bin)
                    end;
                true ->
                    Bin
            end,
            case gen_tcp:send(Socket, CompressBin) of
                {error, Reason} ->
                    exit({game_tcp_send_error, Reason});
                _ ->
                    true
            end;
        true ->
            noop
    end.
-endif.


%%% @doc    获取socket中的Ip和Port
get_socket_ip_and_port (Socket) ->
    {ok, {Address, Port}}   = inet:peername(Socket),
    % put(client_address, Address),
    IpAddress   = inet_parse:ntoa(Address),
    ?DEBUG("get_socket_ip_and_port:~p~n", [{IpAddress, Address, Port}]),
    {IpAddress, Port}.


%%% @doc    构建客户端数据|130二进制
build_client_data (Data) ->
    DataLen = size(Data) + ?DATA_LEN_SIZE, % 包括自己
    Body    = <<DataLen:16/little-unsigned, Data/binary>>,
    BodyLen = size(Body),
    BinLen  = payload_length_to_binary(BodyLen),
    << 1:1, 0:3, 2:4, 0:1, BinLen/bits, Body/binary >>.

payload_length_to_binary (Len) ->
    case Len of
        Len when Len =< 125                 -> << Len:7         >>;
        Len when Len =< 16#FFFF             -> << 126:7, Len:16 >>;
        Len when Len =< 16#7FFFFFFFFFFFFFFF -> << 127:7, Len:64 >>
    end.



%%% ========== ======================================== ====================
%%% 时间相关
%%% ========== ======================================== ====================
-ifdef (debug).
    %%% @spec   get_local_timestamp() -> integer().
    %%% @doc    获取本地时间戳
    get_local_timestamp () ->
        datetime_to_timestamp(erlang:localtime()).
-else.
    %%% @spec   get_local_timestamp() -> integer().
    %%% @doc    获取本地时间戳
    get_local_timestamp () ->
        {T1, T2, _} = now(),
        T1 * 1000000 + T2.
-endif.

%%% @spec   datetime_to_timestamp({{YYYY, MM, DD}, {HH, MM, SS}}) -> integer().
%%% @doc    本地时间元组转成时间戳
datetime_to_timestamp (DateTime) ->
    UTCTime = erlang:localtime_to_universaltime(DateTime),
    calendar:datetime_to_gregorian_seconds(UTCTime) - ?UNIX_FIRST_YEAR_TIMESTAMP.

%%% @spec   timestamp_to_datetime(integer()) -> {{YYYY, MM, DD}, {HH, MM, SS}}.
%%% @doc    本地时间戳转成时间元组
timestamp_to_datetime (TimeStamp) ->
    erlang:universaltime_to_localtime(
        calendar:gregorian_seconds_to_datetime(TimeStamp + ?UNIX_FIRST_YEAR_TIMESTAMP)
    ).


%%% @doc    获取现在整点的时间戳
get_now_hourly_timestamp () ->
    {Date, {Hour, _Minute, _Second}} = erlang:localtime(),
    datetime_to_timestamp({Date, {Hour, 00, 00}}).

%%% @doc    获取今天零点的时间戳
get_today_zero_timestamp () ->
    datetime_to_timestamp({date(), ?DAY_BEGIN_HMS}).

%%% @doc    获取本周开始的时间戳
get_this_week_begin_timestamp () ->
    Date        = date(),
    DayOfWeek   = calendar:day_of_the_week(Date),
    datetime_to_timestamp({Date, ?DAY_BEGIN_HMS}) - (DayOfWeek - 1) * ?DAY_TO_SECOND.

%%% @doc    获取本月开始的时间戳
get_this_month_begin_timestamp () ->
    {Year, Month, _Day} = date(),
    datetime_to_timestamp({{Year, Month, 1}, ?DAY_BEGIN_HMS}).


%%% @spec   ymdhms_integer_to_cover0str(integer()) -> string().
%%% @doc    年、月、日、时、分、秒数字转补零字符串
ymdhms_integer_to_cover0str (Integer) when Integer < 10->
    "0" ++ integer_to_list(Integer);
ymdhms_integer_to_cover0str (Integer) ->
    integer_to_list(Integer).
%%% @spec   ymdhms_tuple_to_cover0str ({{Y, M'o, D}, {H, M'i, S}}) -> "YYYY-MM'o-DD HH:MM'i:SS"
%%% @doc    年月日时分秒元组转补零字符串
ymdhms_tuple_to_cover0str ({Date, Time}) ->
    ymd_tuple_to_cover0str(Date) ++ " " ++ hms_tuple_to_cover0str(Time).
%%% @spec   ymd_tuple_to_cover0str ({Y, M, D},) -> "YYYY-MM-DD"
%%% @doc    年月日元组转补零字符串
ymd_tuple_to_cover0str ({YYYYear, MMonth, DDay}) ->
    integer_to_list(YYYYear)
        ++ "-" ++ ymdhms_integer_to_cover0str(MMonth)
        ++ "-" ++ ymdhms_integer_to_cover0str(DDay).
ymd_tuple_to_cover0str ({YYYYear, MMonth, DDay}, Prefix) ->
    integer_to_list(YYYYear)
        ++ Prefix ++ ymdhms_integer_to_cover0str(MMonth)
        ++ Prefix ++ ymdhms_integer_to_cover0str(DDay).
%%% @spec   hms_tuple_to_cover0str ({H, M, S},) -> "HH:MM:SS"
%%% @doc    时分秒元组转补零字符串
hms_tuple_to_cover0str ({HHour, MMinute, SSecond}) ->
    ymdhms_integer_to_cover0str(HHour)
        ++ ":" ++ ymdhms_integer_to_cover0str(MMinute)
        ++ ":" ++ ymdhms_integer_to_cover0str(SSecond).


%%% @doc    是否今天
is_today (TimeStamp) ->
    is_today(TimeStamp, ?DAY_BEGIN_HMS).
%%% @doc    判断是否是今天时间(_Offset为天分割线默认为{00, 00, 00})
is_today (TimeStamp, {_Hour, _Minute, _Second} = _Offset) ->
    NowTimeStamp    = get_local_timestamp(),
    is_today(TimeStamp, _Offset, NowTimeStamp).

%%% @doc    判断是否是今天(注意NowTimeStamp要传入当前时间,_Offset为天分割线默认为{00, 00, 00})
is_today (TimeStamp, {_Hour, _Minute, _Second} = _Offset, NowTimeStamp) ->
    if
        (NowTimeStamp - TimeStamp) >= ?DAY_TO_SECOND ->
            false;
        true ->
            {NowDate, _Time}    = timestamp_to_datetime(NowTimeStamp),
            _OffsetTimeStamp    = datetime_to_timestamp({NowDate, _Offset}),
            {StartTime, EndTime}= if
                (_Offset == ?DAY_BEGIN_HMS) orelse (_Time > _Offset) ->
                    {_OffsetTimeStamp, _OffsetTimeStamp + ?DAY_TO_SECOND};
                true ->
                    {_OffsetTimeStamp - ?DAY_TO_SECOND, _OffsetTimeStamp}
            end,
            (TimeStamp >= StartTime) andalso (TimeStamp < EndTime)
    end.



%%% ========== ======================================== ====================
%%% @doc    尝试同步给在线玩家应用MFA(不在线则给游戏工作进程)
try_apply_to_online_player (PlayerId, M, F, A) when
    is_number(PlayerId) andalso
    is_atom(M) andalso is_atom(F) andalso is_list(A)
->
    try mod_online:apply_to_online_player(PlayerId, M, F, A) of
        false ->
            put(do_work_param, {M, F, A}),
            R = game_worker:do_work(M, F, A),
            erase(do_work_param),
            R;
        Result ->
            Result
    catch
        _ : Reason ->
            {error, Reason}
    end.
    
%%% @doc    尝试异步给在线玩家应用MFA(不在线则给游戏工作进程)
try_async_apply_to_online_player (PlayerId, M, F, A) ->
    try_async_apply_to_online_player(PlayerId, M, F, A, null).
try_async_apply_to_online_player (PlayerId, M, F, A, CallBack) when
    is_number(PlayerId) andalso
    is_atom(M) andalso is_atom(F) andalso is_list(A)
->
    TheCallBack = if
        is_tuple(CallBack)  -> {self(), CallBack};
        true                -> null
    end,
    try mod_online:async_apply_to_online_player(PlayerId, M, F, A, TheCallBack) of
        false ->
            put(do_work_param, {M, F, A}),
            if
                is_tuple(CallBack) ->
                    R = game_worker:do_work(M, F, A),
                    erase(do_work_param),
                    {CM, CF, CA} = CallBack,
                    try_apply(CM, CF, [R | CA]);
                true -> 
                    R = game_worker:async_do_work(M, F, A),
                    erase(do_work_param),
                    R
            end;
        Result ->
            Result
    catch
        _ : Reason ->
            {error, Reason}
    end.

%%% @doc    尝试应用MFA
try_apply (M, F, A) ->
    case catch apply(M, F, A) of
        {'EXIT', Reason} -> 
            ?ERROR(
                "try_apply:~n"
                "  Pid       = ~p~n"
                "  {M, F, A} = ~p~n"
                "  Reason    = ~p~n",
                [self(), {M, F, A}, Reason]
            ),
            try_apply_failed;
        Result ->
            Result
    end.


%%% ========== ======================================== ====================
%%% @doc    设置玩家ID
put_player_id (PlayerId) ->
    put(?THE_PLAYER_ID, PlayerId).

%%% @doc    获取玩家ID
get_player_id () ->
    get(?THE_PLAYER_ID).


%%% ========== ======================================== ====================
% %%% @doc    获取键在记录的索引
% key_index_of_record (Key, Record) ->
%     RecordName  = element(1, Record),
%     FieldList   = record_info(fields, RecordName),    % 这个编译过不去
%     index_of_list_3(Element, FieldList, 2).

%%% @doc    获取元素在元组的索引
index_of_tuple (Element, Tuple) ->
    index_of_list_3(Element, tuple_to_list(Tuple), 1).


%%% @doc    获取元素在列表的索引
index_of_list (Element, List) ->
    index_of_list_3(Element, List, 1).

index_of_list_3 (Element, [Element | _List], Index) ->
    Index;
index_of_list_3 (Element, [_ | List], Index) ->
    index_of_list_3(Element, List, Index + 1);
index_of_list_3 (_Element, [], _Index) ->
    0.


%%% @doc    列表打乱
shuffle (List) -> shuffle(List, []).

shuffle ([], Acc) -> 
    L = lists:keysort(1, Acc),
    [X || {_, X} <- L];

shuffle ([X | List], Acc) ->
    Rd = rand:uniform(),
    shuffle(List, [{Rd, X} | Acc]).

%%% @doc    列表转成字符串
list_to_string (List) ->
    list_to_string(List, ",").
list_to_string (List, Separator) ->
    string:join(
        [
            if
                is_integer(Element) -> integer_to_list(Element);
                is_float(  Element) ->   float_to_list(Element);
                is_atom(   Element) ->    atom_to_list(Element);
                true                ->         "\"" ++ Element ++ "\""
            end
            ||
            Element <- List
        ],
        Separator
    ).

%%% @doc    字符串长度
%%% @baidu  UTF-8用1到6个字节编码Unicode字符
%%% @baidu  UTF-8编码规则：如果只有一个字节则其最高二进制位为0；如果是多字节，其第一个字节从最高位开始，连续的二进制位值为1的个数决定了其编码的字节数，其余各字节均以10开头
str_length ([])     -> 0;
str_length (String) -> str_length_2(String, 0).

str_length_2 ([], Len)  -> Len;
str_length_2 ([Char1                | String], Len) when Char1 < 16#80 -> str_length_2(String, Len + 1);    % 2#00000000 ~ (2#10000000 - 1)
str_length_2 ([Char1, _             | String], Len) when Char1 < 16#E0 -> str_length_2(String, Len + 2);    % 2#11000000 ~ (2#11100000 - 1)
str_length_2 ([Char1, _, _          | String], Len) when Char1 < 16#F0 -> str_length_2(String, Len + 2);    % 2#11100000 ~ (2#11110000 - 1)
str_length_2 ([Char1, _, _, _       | String], Len) when Char1 < 16#F8 -> str_length_2(String, Len + 2);    % 2#11110000 ~ (2#11111000 - 1)
str_length_2 ([Char1, _, _, _, _    | String], Len) when Char1 < 16#FC -> str_length_2(String, Len + 2);    % 2#11111000 ~ (2#11111100 - 1)
str_length_2 ([Char1, _, _, _, _, _ | String], Len) when Char1 < 16#FE -> str_length_2(String, Len + 2).    % 2#11111100 ~ (2#11111110 - 1)


%%% @doc    数据MD5化
md5 (Code) ->
    lists:flatten([
        io_lib:format("~2.16.0b", [A])
        ||
        A <- binary_to_list(erlang:md5(Code))
    ]).


%% 概率
get_probability (Probability) when Probability =< 0 ->
    false;
get_probability (Probability) when Probability >= 100 ->
    true;
get_probability (Probability) ->
    IntegerProbability = get_limit_integer(Probability),
    if
        IntegerProbability > 0 ->
            % Rate = erlang:ceil(IntegerProbability / Probability * 100),
            Rate = ceil(IntegerProbability / Probability * 100),
            IntegerProbability >= random_number(Rate);
        true ->
            false
    end.

get_limit_integer (Number) ->
    % UNewNumber = erlang:ceil(Number),
    UNewNumber = ceil(Number),
    if
        UNewNumber - Number < 0.00000001 ->
            UNewNumber;
        true ->
            get_limit_integer(Number * 10)
    end.

ceil(X) ->
    T = erlang:trunc(X),
    case X > T of
        true -> T + 1;
        _ -> T
    end.

%% 随机数
random_number (Range) when Range =< 1 ->
    Range;
random_number (Range) ->
    rand:uniform(Range).

random_number_2 (Min, Max) ->
    rand:uniform(max(1, Max - Min)) + Min - 1.

list_unique(List) when is_list(List) ->
    lists:foldl(
        fun(Item, Sum)->
            case lists:member(Item, Sum) of
                false ->
                    [Item | Sum ];
                true  ->
                    Sum
            end
        end,
        [],
        List
    ).

%%% ========== ======================================== ====================
%%% @doc    list_to_binary
lst_to_bin (null) ->
    <<"NULL">>;
lst_to_bin (List) ->
    List2 = escape_str(List, []),
    Bin   = list_to_binary(List2),
    <<"'", Bin/binary, "'">>.
    
%%% @doc    integer_to_binary
int_to_bin (null) ->
    <<"NULL">>;
int_to_bin (Value) ->
    integer_to_binary(Value).

%%% @doc    float_to_binary
rel_to_bin (null) ->
    <<"NULL">>;
rel_to_bin (Value) when is_integer(Value) ->
    integer_to_binary(Value);
rel_to_bin (Value) ->
    float_to_binary(Value).

%%% @doc    escape_str
escape_str ([$'   | String], Result) ->
    escape_str(String, [$'   | [$\\ | Result]]);
escape_str ([$"   | String], Result) ->
    escape_str(String, [$"   | [$\\ | Result]]);
escape_str ([$\\  | String], Result) ->
    escape_str(String, [$\\  | [$\\ | Result]]);
escape_str ([Char | String], Result) ->
    escape_str(String, [Char | Result]);
escape_str ([], Result) ->
    lists:reverse(Result).







