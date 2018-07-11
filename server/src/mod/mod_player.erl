-module (mod_player).

%%% @doc    

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("WhoAreYou").
-date       ({2018, 06, 22}).
-vsn        ("1.0.0").

% -compile(export_all).
-export ([
    login/6,                    % 玩家登陆
    ensure_player_hash/2,       % 确保玩家哈希
    ensure_player_game_fun/2,   % 确保玩家功能开放

    get_player/1,               % 获取玩家
    get_player_key/1,           % 获取玩家权值
    get_player_data/1,          % 获取玩家数据
    get_player_data_of_type/2,  % 获取玩家对应数据
    get_player_data_by_uid/2    % 获取玩家ID对应数据
]).

-export([
    increase_ingot/3,           % 增加金币
    decrease_ingot/3,           % 扣除金币

    get_and_erase_player_data_notify_list/0     % 获取通知列表
]).

-include ("define.hrl").
-include ("gen/game_db.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    玩家登陆
login (UserName, HashCode, LoginTime, Stage, Source, Sock) ->
    case validate_login(UserName, HashCode, LoginTime, Stage) of
        true ->
            case is_player_initialized(UserName) of
                false ->
                    {IpAddress, _}  = lib_misc:get_socket_ip_and_port(Sock),
                    try new_player(UserName, HashCode, LoginTime, Stage, Source, IpAddress) of
                        {ok, Player}    ->
                            mod_online:add_online_player(Player #player.id, Sock),
                            {first_time, Player}
                    catch
                        _ : InitReason  ->
                            ?ERROR("user:~p, hash:~p, time:~p, stage:~p, init error:~p~n", [UserName, HashCode, LoginTime, Stage, InitReason]),
                            InitReason
                    end;
                {true, Player} ->
                    mod_online:add_online_player(Player #player.id, Sock),
                    {login_succeed, Player}
            end;
        _ ->
            login_failed
    end.

%%% @doc    确保玩家哈希
ensure_player_hash (PlayerId, HashCode) ->
    PlayerTrace = get_player_trace(PlayerId),
    case PlayerTrace #player_trace.hash_code of
        HashCode -> true;
        _        -> exit(hash_code)
    end.

    
%% 
%%% @doc    确保玩家功能开放,没开放直接退出
ensure_player_game_fun (PlayerId, FunctionId) ->
    case check_player_game_fun(PlayerId, FunctionId) of
        true ->
            ok;
        _ ->
            exit({game_function_lock, {PlayerId, FunctionId}})
    end.

%%% @doc    检查玩家功能开放
check_player_game_fun (PlayerId, FunctionId) ->
    PlayerLevel  = get_player_data_of_type(PlayerId, player_level),
    GameFunction = get_game_function(FunctionId),
    PlayerLevel >= GameFunction #game_function.unlock_lv.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    验证登陆
validate_login (UserName, HashCode, LoginTime, Stage) ->
    % if
    %     ?IS_DEBUG ->
    %         true;
    %     true ->
            NowTimeStamp    = lib_misc:get_local_timestamp(),
            if 
                abs(NowTimeStamp - LoginTime) =< ?CHECK_CLIENT_TIME ->
                    Platform    = get_platform_by_name(Stage),
                    HashCodeLow = string:to_lower(HashCode),
                    HashCodeHy  = lib_misc:md5(
                        UserName ++
                        Platform #platform.private_key ++ 
                        integer_to_list(LoginTime)
                    ),
                    string:equal(HashCodeLow, HashCodeHy);
                true ->
                    false
            % end
    end.


%%% @doc    是否玩家已初始化
is_player_initialized (UserName) ->
    case try_get_player_by_username(UserName) of
        null ->
            false;
        Player ->
            if
                Player #player.nickname == "" -> false;
                true -> {true, Player}
            end
    end.

%%% @doc    新玩家
new_player (UserName, HashCode, LoginTime, Stage, Source, IpAddress) ->
    Platform        = get_platform_by_name(Stage),
    NowTimeStamp    = lib_misc:get_local_timestamp(),
    Tran = fun() ->
        {ok, Player} = game_db_data:write(
            #player{
                username    = UserName,
                nickname    = UserName,
                platform_id = Platform #platform.id,
                source      = Source,
                regdate     = LoginTime
            }
        ),
        PlayerId    = Player #player.id,
        {ok, _}     = game_db_data:write(
            #player_key{
                player_id           = PlayerId
            }
        ),
        {ok, _}     = game_db_data:write(
            #player_data{
                player_id   = PlayerId,
                ingot       = 0,
                level       = 1
            }
        ),
        {ok, _}     = game_db_data:write(
            #player_trace{
                player_id        = PlayerId,
                hash_code        = HashCode,
                first_login_ip   = IpAddress,
                first_login_time = NowTimeStamp,
                last_login_ip    = IpAddress,
                last_login_time  = NowTimeStamp
            }
        ),
        Player
    end,
    {atomic, NewPlayer} = game_db_data:do(Tran),
    lib_ets:insert(player_username_index, {UserName, NewPlayer #player.id}),
    {ok, NewPlayer}.



%%% ========== ======================================== ====================
%%% 数据操作
%%% ========== ======================================== ====================
%%% @doc    尝试根据用户名称获取玩家
try_get_player_by_username (UserName) ->
    case ets:lookup(player_username_index, UserName) of
        []              -> null;
        [{_, PlayerId}] -> get_player(PlayerId)
    end.

%%% @doc    尝试根据昵称获取玩家
try_get_player_by_nickname (NickName) ->
    case ets:lookup(player_nickname_index, NickName) of
        []              -> null;
        [{_, PlayerId}] -> get_player(PlayerId)
    end.


%%% @doc    获取玩家record
get_player (PlayerId) ->
    [Player]    = game_db_data:read(#pk_player{id = PlayerId}),
    Player.

%%% @doc    获取玩家权值
get_player_key (PlayerId) ->
    [PlayerKey]     = game_db_data:read(#pk_player_key{player_id = PlayerId}),
    PlayerKey.

%%% @doc    获取玩家数据
get_player_data (PlayerId) ->
    [PlayerData]    = game_db_data:read(#pk_player_data{player_id = PlayerId}),
    PlayerData.

%%% @doc    获取玩家追踪
get_player_trace (PlayerId) ->
    [PlayerTrace]   = game_db_data:read(#pk_player_trace{player_id = PlayerId}),
    PlayerTrace.

%%% @doc    获取对应类型的玩家数据
get_player_data_of_type (Player, nickname) ->
    Player #player.nickname;

get_player_data_of_type (PlayerData, player_level)      ->
    PlayerData #player_data.level;
get_player_data_of_type (PlayerData, player_experience) ->
    PlayerData #player_data.experience;
get_player_data_of_type (PlayerData, player_ingot) ->
    PlayerData #player_data.ingot;

get_player_data_of_type (_PlayerData, _DataType) ->
    null.

%%% @doc    获取玩家ID对应数据
get_player_data_by_uid (PlayerId, DataType) ->
    get_player_data_of_type(get_player_record_by_field(PlayerId, DataType), DataType).

%%% @doc    根据字段获取对应的玩家记录
get_player_record_by_field (PlayerId, DataType) ->
    if
        DataType == nickname    ->
            get_player(PlayerId);
        true ->
            get_player_data(PlayerId)
    end.



%%% @doc    根据名称获取平台record
get_platform_by_name (Stage) ->
    code_db:get_logic(platform_by_name, [Stage]).

%%% @doc    获取游戏功能
get_game_function (FunctionId) ->
    code_db:get(game_function, [FunctionId]).


%%% ========== ======================================== ====================
%%% 玩家资源数据操作
%%% ========== ======================================== ====================
%%% @doc    增加金币
increase_ingot (PlayerId, Value, Type) ->
    if
        Type =:= ?LOGT_CHARGE -> %%% 充值 不考虑 外挂
            put(?INGOT_OP_REASON, Type),
            {ok, NewIngot} = go_increase_ingot(PlayerId, Value, 0, Type),
            erase(?INGOT_OP_REASON),
            {ok, NewIngot};
        true ->
            put(?INGOT_OP_REASON, Type),
            {ok, NewIngot} = go_increase_ingot(PlayerId, 0, Value, Type),
            erase(?INGOT_OP_REASON),
            {ok, NewIngot}
    end.

go_increase_ingot (PlayerId, ChargeValue, Value, Type) when 
    (is_integer(      Value) andalso       Value > 0) orelse
    (is_integer(ChargeValue) andalso ChargeValue > 0)
->
    PlayerData          = get_player_data(PlayerId),
    NewPlayerData       = PlayerData #player_data{
        ingot           = PlayerData #player_data.ingot + Value,
        charge_ingot    = PlayerData #player_data.charge_ingot + ChargeValue
    },
    game_db_data:write(
        NewPlayerData
    ),
    add_player_ingot_change_log(
        PlayerId,
        ChargeValue,
        Value,
        NewPlayerData #player_data.charge_ingot,
        NewPlayerData #player_data.ingot,
        Type
    ),
    notify_player_data(PlayerId, player_ingot),
    {ok, NewPlayerData #player_data.ingot + NewPlayerData #player_data.charge_ingot}.

%%% @doc    扣除金币
decrease_ingot (PlayerId, Value, Type) ->
    put(?INGOT_OP_REASON, Type),
    R = case go_decrease_ingot(PlayerId, Value, Type) of
            false ->
                false;
            {ok, _NewIngot} = Result ->
                if
                    Type == ?LOGT_SYSTEM_COST ->
                        ok;
                    true ->
                        noop
                end,
                Result
        end,
    erase(?INGOT_OP_REASON),
    R.

go_decrease_ingot (PlayerId, Value, Type) when
    is_integer(Value) andalso Value > 0
->
    PlayerData = get_player_data(PlayerId),
    if
        PlayerData #player_data.ingot + PlayerData #player_data.charge_ingot < Value ->
            false;
        true ->
            {UseChargeIngot, UseIngot, NewChargeIngot, NewIngot} = if
                PlayerData #player_data.charge_ingot < Value ->
                    {
                        PlayerData #player_data.charge_ingot,
                        Value - PlayerData #player_data.charge_ingot,
                        0,
                        PlayerData #player_data.ingot - (Value - PlayerData #player_data.charge_ingot)
                    };
                true ->
                    {
                        Value,
                        0,
                        PlayerData #player_data.charge_ingot - Value,
                        PlayerData #player_data.ingot
                    }

            end,
            game_db_data:write(
                PlayerData #player_data{
                    ingot        = NewIngot,
                    charge_ingot = NewChargeIngot
                }
            ),
            add_player_ingot_change_log(
                PlayerId,
                0 - UseChargeIngot,
                0 - UseIngot,
                NewChargeIngot,
                NewIngot,
                Type
            ),
            notify_player_data(PlayerId, player_ingot),
            {ok, NewIngot + NewChargeIngot}
    end.

%%% @doc    增加玩家金币变动记录
add_player_ingot_change_log (PlayerId, ChangeChargeValue, ChangeValue, NewChargeIngot, NewIngot, Type) ->
    NowTimeStamp = lib_misc:get_local_timestamp(),
    game_db_data:write(
        #player_ingot_log{
            player_id           = PlayerId,
            charge_value        = ChangeChargeValue,
            after_charge_value  = NewChargeIngot,
            value               = ChangeValue,
            after_value         = NewIngot,
            op_type             = Type,
            op_time             = NowTimeStamp
        }
    ).



%%% ========== ======================================== ====================
%%% @doc    主动通知客户端玩家变更的数据
notify_player_data (PlayerId, DataType) ->
    case lib_ets:get(online_player, PlayerId) of
        []  ->
            false;
        [_] ->
            DataTypeList = get(player_data_notify_list),
            if
                DataTypeList == undefined ->
                    put(player_data_notify_list, [DataType]);
                true ->
                    put(player_data_notify_list, [DataType | DataTypeList])
            end
    end,
    ok.

%%% @doc    获取通知列表
get_and_erase_player_data_notify_list () ->
    case erase(player_data_notify_list) of
        undefined ->
            null;
        List ->
            lib_misc:list_unique(List)
    end.

