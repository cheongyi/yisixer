-module (api_player).

%%% @doc    

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("WhoAreYou").
-date       ({2018, 06, 22}).
-vsn        ("1.0.0").

-export ([
    login/6,                    % 玩家登陆
    get_player_info/1           % 获取玩家信息
]).
-export ([
    try_send_player_data_notify/1               % 
]).

-include ("define.hrl").
-include ("record.hrl").
-include ("gen/game_db.hrl").
-include ("gen/api_enum.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    玩家登陆
login (UserName, HashCode, LoginTime, Stage, Source, State  = #client_state{sock = Sock}) ->
    ?DEBUG("~p~n", [{UserName, HashCode, LoginTime, Stage, Source}]),
    {Result, Player}    = try mod_player:login(UserName, HashCode, LoginTime, Stage, Source, Sock) of
        {login_succeed, ThePlayer} ->
            {?LOGIN_SUCCEED, ThePlayer};
        {first_time,    ThePlayer} ->
            {?FIRST_TIME,    ThePlayer};
        login_failed ->
            {?LOGIN_FAILED,  #player{id = 0}}
    catch
        _ : _Reason ->
            {?LOGIN_FAILED,  #player{id = 0}}
    end,
    PlayerId    = Player #player.id,
    NewState    = State #client_state{
        player_id   = PlayerId
    },
    if
        PlayerId > 0 ->
            put(?THE_PLAYER_ID, PlayerId),
            Pid = list_to_atom("player_" ++ integer_to_list(PlayerId)),
            supervisor:terminate_child(socket_client_sup, whereis(Pid)),
            register(Pid, self()),
            ok;
        true -> noop
    end,
    IsMinorAccount  = ?ENUM_FALSE,
    EnableTime      = 0,
    ?DEBUG("~p~n", [{Result, PlayerId, IsMinorAccount, EnableTime}]),
    OutBin  = api_player_out:login({Result, PlayerId, IsMinorAccount, EnableTime}),
    {NewState, OutBin}.

%%% @doc    获取玩家信息
get_player_info (State  = #client_state{player_id = PlayerId}) ->
    Player      = mod_player:get_player(PlayerId),
    PlayerData  = mod_player:get_player_data(PlayerId),
    OutBin  = api_player_out:get_player_info({
        mod_player:get_player_data_of_type(Player,      nickname),
        mod_player:get_player_data_of_type(PlayerData,  player_level),
        mod_player:get_player_data_of_type(PlayerData,  player_experience),
        mod_player:get_player_data_of_type(PlayerData,  player_ingot)
    }),
    {State, OutBin}.



%%% @doc    获取玩家信息
try_send_player_data_notify (PlayerId) ->
    case mod_player:get_and_erase_player_data_notify_list() of
        null ->
            ok;
        DataTypeList ->
            DataList = [
                get_notify_data(PlayerId, DataType)
                ||
                DataType <- DataTypeList
            ],
            OutBin = api_player_out:update_player_data({DataList}),
            mod_online:send_to_online_player(PlayerId, OutBin)
    end,
    ok.

%%% @doc    玩家数据类型原子转枚举
player_data_type_atom_to_enum (DataType) ->
    case DataType of
        player_level        -> ?PLAYER_LEVEL;           %% 玩家等级
        player_experience   -> ?PLAYER_EXPERIENCE;      %% 玩家经验
        player_ingot        -> ?PLAYER_INGOT            %% 玩家金币
    end.

%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    获取通知数据
get_notify_data (PlayerId, DataType) ->
    case DataType of
        {Type, Value} ->
            {player_data_type_atom_to_enum(Type), Value};
        _ ->
            DataValue   = mod_player:get_player_data_of_type(PlayerId, DataType),
            {player_data_type_atom_to_enum(DataType), DataValue}
    end.




