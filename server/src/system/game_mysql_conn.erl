-module (game_mysql_conn).

%%% @doc    游戏数据库连接

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 13}).
-vsn        ("1.0.0").

-behaviour (gen_server).

% -compile (export_all).
-export ([start_link/7, start/0, stop/0]).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([
    fetch/3, fetch/4,                           % 发送一个Query
    do_send/4,                                  % 发送数据包
    do_recv/3,                                  % 接收数据包
    get_state/0                                 % 获取进程状态数据
]).

-include ("define.hrl").
% -include ("record.hrl").
-include ("mysql.hrl").

-define (SERVER, ?MODULE).
-define (SECURE_CONNECTION, 32768).
-define (MYSQL_QUERY_OP, 3).
-define (DEFAULT_STANDALONE_TIMEOUT, 3600000).
-define (DEFAULT_RESULT_TYPE, list).
-define (MYSQL_4_0, 40). %% Support for MySQL 4.0.x
-define (MYSQL_4_1, 41). %% Support for MySQL 4.1.x et 5.0.x

-record (state, {
    mysql_pid,
    socket,
    user,       % undefined|string()
    password,   % undefined|string()
    database,   % undefined|string()
    log_fun,
    data    = <<>>,
    recv_pid,
    mysql_version
}).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @spec   start_link() -> ServerRet.
%%% @doc    Start the process and link gen_server.
start_link (Host, Port, User, Password, Database, LogFun, MysqlPid) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [Host, Port, User, Password, Database, LogFun, MysqlPid], []).

%%% @spec   start() -> ServerRet.
%%% @doc    Start the process.
start () ->
    gen_server:start({local, ?SERVER}, ?MODULE, [], []).

%%% @spec   stop() -> ok.
%%% @doc    Stop the process.
stop () ->
    gen_server:call(?SERVER, stop).

%%% @doc    获取进程状态数据
get_state () ->
    gen_server:call(?SERVER, get_state).

%%% @doc    发送一个Query
fetch (Pid, Query, From) ->
    send_query(Pid, Query, From, []).
fetch (Pid, Query, From, Timeout) ->
    send_query(Pid, Query, From, [{timeout, Timeout}]).


%%% ========== ======================================== ====================
%%% gen_server 6 callbacks
%%% ========== ======================================== ====================
%%% @spec   init([]) -> {ok, State}.
%%% @doc    gen_server init, opens the server in an initial state.
init ([Host, Port, User, Password, Database, LogFun, MysqlPid]) ->
    {ok, RecvPid} = game_mysql_recv:start_link(Host, Port, LogFun, self()),
    State = #state{
        mysql_pid       = MysqlPid,
        % socket          = Socket,
        user            = User,
        password        = Password,
        database        = Database,
        log_fun         = LogFun,
        recv_pid        = RecvPid,
        mysql_version   = undefined
    },
    {ok, State}.

%%% @spec   handle_call(Args, From, State) -> tuple().
%%% @doc    gen_server callback.
handle_call (get_state, _From, State) ->
    {reply, State, State};
handle_call (stop, _From, State) ->
    {stop, shutdown, stopped, State};
handle_call (Request, From, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {call, Request, From}]),
    {reply, {error, badrequest}, State}.

%%% @spec   handle_cast(Cast, State) -> tuple().
%%% @doc    gen_server callback.
handle_cast (Request, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {cast, Request}]),
    {noreply, State}.

%%% @spec   handle_info(Info, State) -> tuple().
%%% @doc    gen_server callback.
handle_info ({fetch, TimerOutRef, Query, GenSrvFrom, Options}, State) ->
    %% GenSrvFrom is either a gen_server:call/3 From term(), or a pid if no
    %% gen_server was used to make the query
    Result = do_query(State, Query, Options),
    % ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {fetch, Result, GenSrvFrom, erlang:read_timer(TimerOutRef)}]),
    case is_pid(GenSrvFrom) of
        true ->
            %% The query was not sent using gen_server mechanisms
            GenSrvFrom ! {fetch_result, TimerOutRef, self(), Result};
        false ->
            %% the timer is canceled in wait_fetch_result/2, but we wait on that funtion only if the query 
            %% was not sent using the mysql gen_server. So we at least should try to cancel the timer here 
            %% (no warranty, the gen_server can still receive timeout messages)
            erlang:cancel_timer(TimerOutRef),  
            gen_server:reply(GenSrvFrom, Result)
    end,
    % ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {fetch, Result, GenSrvFrom, erlang:read_timer(TimerOutRef)}]),
    {noreply, State};
handle_info ({mysql_recv, RecvPid, data,   Packet, SequenceNum}, State = #state{recv_pid = RecvPid}) ->
    game_mysql:log(State #state.log_fun, info, 
        "mysql_conn: recv data when not expecting any (~p): ~p - ignoring it~n", [SequenceNum, Packet]),
    {noreply, State};
handle_info ({mysql_recv, RecvPid, socket, Socket},              State = #state{recv_pid = RecvPid}) ->
    User        = State #state.user,
    Password    = State #state.password,
    Database    = State #state.database,
    LogFun      = State #state.log_fun,
    {ok, MysqlVersion} = mysql_init(RecvPid, Socket, User, Password, LogFun),
    do_query(RecvPid, Socket, LogFun, "SET NAMES utf8",           MysqlVersion, [{result_type, binary}]),
    do_query(RecvPid, Socket, LogFun, "use " ++ Database,         MysqlVersion, [{result_type, binary}]),
    do_query(RecvPid, Socket, LogFun, "SET FOREIGN_KEY_CHECKS=0", MysqlVersion, [{result_type, binary}]),
    {noreply, State #state{socket = Socket, mysql_version = MysqlVersion}};
handle_info (Info, State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {info, Info}]),
    {noreply, State}.

%%% @spec   terminate(Reason, State) -> ok.
%%% @doc    gen_server termination callback.
terminate (Reason, _State) ->
    ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {terminate, Reason}]),
    ok.

%%% @spec   code_change(_OldVsn, State, _Extra) -> tuple().
%%% @doc    gen_server code_change callback (trivial).
code_change (_Vsn, State, _Extra) ->
    {ok, State}.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
mysql_init (RecvPid, Socket, User, Password, LogFun) ->
    case do_recv(RecvPid, undefined, LogFun) of
        {ok, Packet, InitSeqNum} ->
            {Version, Salt1, Salt2, Caps} = greeting(Packet, LogFun),
            AuthResp = case Caps band ?SECURE_CONNECTION of
                ?SECURE_CONNECTION ->
                    game_mysql_auth:do_new_auth(RecvPid, Socket, InitSeqNum + 1, User, Password, Salt1, Salt2, LogFun);
                _ ->
                    game_mysql_auth:do_old_auth(RecvPid, Socket, InitSeqNum + 1, User, Password, Salt1, LogFun)
            end,
            case AuthResp of
                {ok, <<0:8, _Rest/binary>>, _RecvSeqNum} ->
                    game_mysql:log(LogFun, info, 
                        "mysql_init: success(~p): ~p~n", [_RecvSeqNum, _Rest]),
                    {ok, Version};
                {ok, <<255:8, Code:16/little, Message/binary>>, _RecvSeqNum} ->
                    game_mysql:log(LogFun, error, 
                        "mysql_init: error ~p: ~p~n", [Code, binary_to_list(Message)]),
                    {error, binary_to_list(Message)};
                {ok, RecvPacket, _RecvSeqNum} ->
                    game_mysql:log(LogFun, error, 
                        "mysql_init: unknown error ~p~n", [binary_to_list(RecvPacket)]),
                    {error, binary_to_list(RecvPacket)};
                {error, Reason} ->
                    game_mysql:log(LogFun, error, 
                        "mysql_init: failed receiving data : ~p~n", [Reason]),
                    {error, Reason}
            end;
        {error, Reason} ->
            {error, Reason}
    end.

%%% @doc    解析初始化连接数据库后返回的招呼
greeting (Packet, LogFun) ->
    <<Protocol:8,         RestProtocol/binary>> = Packet,
    {Version, RestVersion}  = spilt_first_zero(RestProtocol),
    <<ThreadId:32/little, RestThreadId/binary>> = RestVersion,
    {Salt1,   RestSalt1}    = spilt_first_zero(RestThreadId),
    <<Caps:16/little,     RestCaps/binary>>     = RestSalt1,
    <<Server:16/binary-unit:8, RestServer/binary>> = RestCaps,
    {Salt2,   RestSalt2}    = spilt_first_zero(RestServer),
    game_mysql:log(LogFun, debug, 
        "mysql_conn: greeting Packet:~p~n"
        "Protocol:~p Version:~p ThreadId:~p Salt1:~p Caps:~p~n"
        "Server:~p~n Salt2:~p RestSalt2:~p~n",
        [Packet, Protocol, Version, ThreadId, Salt1, Caps, Server, Salt2, spilt_first_zero(RestSalt2)]
    ),
    {normalize_version(Version, LogFun), Salt1, Salt2, Caps}.

%%% @doc    分割数据中遇到的第一个0
spilt_first_zero (Data) when is_binary(Data) ->
    game_mysql:spiltbin_first_zero(Data, []);
spilt_first_zero (Data) when is_list(Data) ->
    {String, [0 | Rest]} = lists:splitwith(fun(Element) ->Element /= 0 end, Data),
    {String, Rest}.

%%% @doc    标准化版本
normalize_version([$4, $., $0 | _T], LogFun) ->
    game_mysql:log(LogFun, debug, "Switching to MySQL 4.0.x protocol.~n"),
    ?MYSQL_4_0;
normalize_version([$4, $., $1 | _T], _LogFun) ->
    ?MYSQL_4_1;
normalize_version([$5 | _T], LogFun) ->
    game_mysql:log(LogFun, debug, "Mysql: ~p switching to MySQL 4.1.x protocol.~n", [[$5 | _T]]),
    %% MySQL version 5.x protocol is compliant with MySQL 4.1.x:
    ?MYSQL_4_1;
normalize_version(_Other, LogFun) ->
    game_mysql:log(LogFun, error, "MySQL version not supported: MySQL Erlang module might not work correctly.~n"),
    %% Error, but trying the oldest protocol anyway:
    ?MYSQL_4_0.


%%% @doc    发送数据包
do_send (Socket, Data, SequenceNum, LogFun) ->
    Packet = <<(size(Data)):24/little, SequenceNum:8, Data/binary>>,
    game_mysql:log(LogFun, debug, "Mysql: send packet (~p): ~p~n", [SequenceNum, Packet]),
    gen_tcp:send(Socket, Packet).

%%% @doc    接收数据包
do_recv (RecvPid, undefined, LogFun) ->
    receive
        {mysql_recv, RecvPid, data,   Packet, ResponseNum} ->
            game_mysql:log(LogFun, info, "Mysql: recv data un(~p): ~p~n", [ResponseNum, Packet]),
            {ok, Packet, ResponseNum};
        {mysql_recv, RecvPid, closed, Reason} ->
            {error, io_lib:format("mysql_recv: socket was closed:~p~n", [Reason])}
    end;
do_recv (RecvPid, SequenceNum, LogFun) ->
    ResponseNum = SequenceNum + 1,
    receive
        {mysql_recv, RecvPid, data,   Packet, ResponseNum} ->
            game_mysql:log(LogFun, info, "Mysql: recv data   (~p): ~p~n", [ResponseNum, Packet]),
            {ok, Packet, ResponseNum};
        {mysql_recv, RecvPid, closed, Reason} ->
            {error, io_lib:format("mysql_recv: socket was closed:~p~n", [Reason])}
    end.

%%% @doc    执行SQL语句
do_query (State, Query, Options) ->
    do_query(
        State #state.recv_pid,
        State #state.socket,
        State #state.log_fun,
        Query, 
        State #state.mysql_version,
        Options
    ).
do_query (RecvPid, Socket, LogFun, Query, MysqlVersion, Options) when
    is_pid(RecvPid) andalso
    is_list(Query)
->
    Packet = list_to_binary([?MYSQL_QUERY_OP, Query]),
    case do_send(Socket, Packet, 0, LogFun) of
        ok ->
            get_query_response(RecvPid, LogFun, MysqlVersion, Options);
        {error, Reason} ->
            {error, io_lib:format("Mysql: failed send data on socket:~p  ~p", [Socket, Reason])}
    end.

%%% @doc    获取执行返回
get_query_response (RecvPid, LogFun, MysqlVersion, Options) ->
    case do_recv(RecvPid, undefined, LogFun) of
        {ok, <<FieldCount:8, Rest/binary>>, _RecvSeqNum} ->
            case FieldCount of
                0 ->
                    %% No Tabular data
                    {AffectRows, RestAffect} = get_with_length(Rest),
                    {InsertId,  _RestInsert} = get_with_length(RestAffect),
                    {updated, #mysql_result{affect_rows = AffectRows, insert_id = InsertId}};
                255 ->
                    <<_MsgLen:16/little, Message/binary>> = Rest,
                    {error, #mysql_result{error = binary_to_list(Message)}};
                _ ->
                    %% Tabular data received
                    case get_fields(RecvPid, LogFun, MysqlVersion, []) of
                        {ok, Fields} ->
                            ResultType = get_option(result_type, Options, ?DEFAULT_RESULT_TYPE),
                            case get_rows(RecvPid, LogFun, FieldCount, ResultType, []) of
                                {ok, Rows} ->
                                    {data,  #mysql_result{field_info = Fields, rows = Rows}};
                                {error, Reason} ->
                                    {error, #mysql_result{error = Reason}}
                            end;
                        {error, Reason} ->
                            {error, #mysql_result{error = Reason}}
                    end
            end;
        {error, Reason} ->
            {error, #mysql_result{error = Reason}}
    end.

%%% @doc    获取长度和字节
get_with_length (<<252:8, Length:16/little, Rest/binary>>) ->
    {Length, Rest};
get_with_length (<<253:8, Length:24/little, Rest/binary>>) ->
    {Length, Rest};
get_with_length (<<254:8, Length:64/little, Rest/binary>>) ->
    {Length, Rest};
get_with_length (<<Length:8, Rest/binary>>) when Length < 251 ->
    {Length, Rest}.

%%% @doc    根据长度切割字节
splitbin_with_length (<<252:8, Length:16/little, Rest/binary>>) ->
    split_binary(Rest, Length);
splitbin_with_length (<<253:8, Length:24/little, Rest/binary>>) ->
    split_binary(Rest, Length);
splitbin_with_length (<<254:8, Length:64/little, Rest/binary>>) ->
    split_binary(Rest, Length);
splitbin_with_length (<<251:8,    Rest/binary>>) ->
    {null, Rest};
splitbin_with_length (<<Length:8, Rest/binary>>) when Length < 251 ->
    split_binary(Rest, Length).

%%% @doc    获取字段结果集
%%% @Descrip    Support for MySQL 4.0.x:
get_fields (RecvPid, LogFun, ?MYSQL_4_0, List) ->
    case do_recv(RecvPid, undefined, LogFun) of
        {ok, Packet, _RecvSeqNum} ->
            case Packet of
                <<254:8, Rest/binary>> when size(Rest) < 8 ->
                    {ok, lists:reverse(List)};
                _ ->
                    {Table,     RestTable}  = splitbin_with_length(Packet),
                    {Field,     RestField}  = splitbin_with_length(RestTable),
                    {LengthBin, RestLen}    = splitbin_with_length(RestField),
                    LengthBinLen = size(LengthBin) * 8,
                    <<Length:LengthBinLen/little>> = LengthBin,
                    {Type,      RestType}   = splitbin_with_length(RestLen),
                    {_Flags,    _Rest5}     = splitbin_with_length(RestType),
                    This = {
                        binary_to_list(Table),
                        binary_to_list(Field),
                        Length,
                        %% TODO: Check on MySQL 4.0 if types are specified
                        %%       using the same 4.1 formalism and could
                        %%       be expanded to atoms:
                        binary_to_list(Type)
                    },
                    get_fields(RecvPid, LogFun, ?MYSQL_4_0, [This | List])
            end;
        {error, Reason} ->
            {error, Reason}
    end;
%%% @Descrip    Support for MySQL 4.1.x and 5.x:
get_fields (RecvPid, LogFun, ?MYSQL_4_1, List) ->
    case do_recv(RecvPid, undefined, LogFun) of
        {ok, Packet, _RecvSeqNum} ->
            case Packet of
                <<254:8, Rest/binary>> when size(Rest) < 8 ->
                    {ok, lists:reverse(List)};
                _ ->
                    {_Catalog,  Rest}       = splitbin_with_length(Packet),
                    {_Database, RestDb}     = splitbin_with_length(Rest),
                    {Table,     RestTable}  = splitbin_with_length(RestDb),
                    %% OrgTable is the real table name if Table is an alias
                    {_OrgTable, RestOrgT}   = splitbin_with_length(RestTable),
                    {Field,     RestField}  = splitbin_with_length(RestOrgT),
                    %% OrgField is the real field name if Field is an alias
                    {_OrgField, RestOrgF}   = splitbin_with_length(RestField),

                    <<
                        _Metadata:8/little, _Charset:16/little,
                        Length:32/little,   Type:8/little,
                        _Flags:16/little,   _Decimals:8/little, _Rest7/binary
                     >> = RestOrgF,

                    This = {
                        binary_to_list(Table),
                        binary_to_list(Field),
                        Length,
                        get_field_datatype(Type)
                    },
                    get_fields(RecvPid, LogFun, ?MYSQL_4_1, [This | List])
            end;
        {error, Reason} ->
            {error, Reason}
    end.

%%% @doc    获取结果行集
get_rows (RecvPid, LogFun, Fieldcount, ResultType, List) ->
    case do_recv(RecvPid, undefined, LogFun) of
        {ok, Packet, _Num} ->
            case Packet of
                <<254:8, Rest/binary>> when size(Rest) < 8 ->
                    {ok, lists:reverse(List)};
                _ ->
                    {ok, This} = get_row(Packet, Fieldcount, ResultType, []),
                    get_rows(RecvPid, LogFun, Fieldcount, ResultType, [This | List])
            end;
        {error, Reason} ->
            {error, Reason}
    end.
%%% @doc    获取结果行
get_row (_Data, 0, _ResultType, List) ->
    {ok, lists:reverse(List)};
get_row (Data, Fieldcount, ResultType, List) ->
    {Col, Rest} = splitbin_with_length(Data),
    This = case Col of
        null ->
           null;
        _ ->
            if
               ResultType == list   -> binary_to_list(Col);
               ResultType == binary -> Col
            end
    end,
    get_row(Rest, Fieldcount - 1, ResultType, [This | List]).

%%% @doc    获取对应选项
get_option (Key, Options, Default) ->
    case lists:keyfind(Key, 1, Options) of
        {Key, Value} ->
            Value;
        _ ->
            Default
    end.

%%% @doc    获取字段数据类型
get_field_datatype (0)   -> 'DECIMAL';
get_field_datatype (1)   -> 'TINY';
get_field_datatype (2)   -> 'SHORT';
get_field_datatype (3)   -> 'LONG';
get_field_datatype (4)   -> 'FLOAT';
get_field_datatype (5)   -> 'DOUBLE';
get_field_datatype (6)   -> 'NULL';
get_field_datatype (7)   -> 'TIMESTAMP';
get_field_datatype (8)   -> 'LONGLONG';
get_field_datatype (9)   -> 'INT24';
get_field_datatype (10)  -> 'DATE';
get_field_datatype (11)  -> 'TIME';
get_field_datatype (12)  -> 'DATETIME';
get_field_datatype (13)  -> 'YEAR';
get_field_datatype (14)  -> 'NEWDATE';
get_field_datatype (16)  -> 'BIT';
get_field_datatype (246) -> 'DECIMAL';
get_field_datatype (247) -> 'ENUM';
get_field_datatype (248) -> 'SET';
get_field_datatype (249) -> 'TINYBLOB';
get_field_datatype (250) -> 'MEDIUM_BLOG';
get_field_datatype (251) -> 'LONG_BLOG';
get_field_datatype (252) -> 'BLOB';
get_field_datatype (253) -> 'VAR_STRING';
get_field_datatype (254) -> 'STRING';
get_field_datatype (255) -> 'GEOMETRY'.

%%% @doc    发送一个Query
send_query (Pid, Query, From, Options) when is_pid(Pid) andalso is_list(Query) ->
    Self        = self(),
    Timeout     = get_option(timeout, Options, ?DEFAULT_STANDALONE_TIMEOUT),
    TimeoutRef  = erlang:start_timer(Timeout, self(), timeout),
    Pid ! {fetch, TimeoutRef, Query, From, Options},
    % ?INFO("~p, ~p, ~p~n", [?MODULE, ?LINE, {fetch, Pid, From}]),
    case From of
        Self ->
            %% We are not using a mysql_dispatcher, await the response
            wait_fetch_result(TimeoutRef, Pid);
        _ ->
            %% From is gen_server From, Pid will do gen_server:reply() when it has an answer
            ok
    end.

%%% @doc    等待fetch结果
wait_fetch_result (TimeoutRef, Pid) ->
    receive
        {fetch_result, TimeoutRef, Pid, Result} ->
            case erlang:cancel_timer(TimeoutRef) of
                false ->
                    receive
                    {timeout, TimeoutRef, _} ->
                        ok
                    after 0 ->
                        ok
                    end;
                _ ->
                    ok
            end,
            Result;
        {fetch_result, _BadRef, Pid, _Result} ->
            wait_fetch_result(TimeoutRef, Pid);
        {timeout, TimeoutRef, _} ->
            % stop(Pid),
            {error, "query timed out"}
    end.

%%% @doc    结束进程
% stop (Pid) ->
%     Pid ! close.












