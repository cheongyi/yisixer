-module (lib_time).

-author     ("CHEONGYI").
-date       ({2017, 11, 09}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2017 YiSiXEr").

%%% @doc    计时起点时间为 UNIX时间 {{1970, 01, 01}, {00, 00, 00}}
%%% @doc    62167219200 = calendar:datetime_to_gregorian_seconds({{1970, 01, 01}, {00, 00, 00}})
%%% @doc    线上版本统一用 格林尼\威治标准时间（Greenwich Mean Time，GMT）
%%% @doc    开发版本则采用 本地时区如中国时区cn:+0800相差

-compile (export_all).
-export ([
    get_local_timestamp/0,                      % 获取本地时间戳
    datetime_to_timestamp/1,                    % 本地时间元组转成时间戳
    timestamp_to_datetime/1,                    % 本地时间戳转成时间元组

    ymdhms_integer_to_cover0str/1,              % 年、月、日、时、分、秒数字转补零字符串
    ymdhms_tuple_to_cover0str/1,                % 年月日时分秒元组转补零字符串
    ymd_tuple_to_cover0str/1,                   % 年月日元组转补零字符串
    hms_tuple_to_cover0str/1                    % 时分秒元组转补零字符串
]).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
-ifdef (debug).
    %%% @spec   get_local_timestamp() -> integer().
    %%% @doc    获取本地时间戳
    get_local_timestamp () ->
        datetime_to_timestamp(erlang:localtime()).
        % 28800 = 62167248000 - 62167219200
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
    calendar:datetime_to_gregorian_seconds(UTCTime) - 62167219200.

%%% @spec   timestamp_to_datetime(integer()) -> {{YYYY, MM, DD}, {HH, MM, SS}}.
%%% @doc    本地时间戳转成时间元组
timestamp_to_datetime (TimeStamp) ->
    erlang:universaltime_to_localtime(
        calendar:gregorian_seconds_to_datetime(TimeStamp + 62167219200)
    ).

%%% @doc    获取今天零点的时间戳
get_today_zero_timestamp () ->
    datetime_to_timestamp({date(), {00, 00, 00}}).

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



