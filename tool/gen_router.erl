-module (gen_router).

-copyright  ("Copyright © 2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 31}).
-vsn        ("1.0.0").

% -compile (export_all).
-export ([
    init/0,             % 初始化game_router文件
    write_relay/2,      % 写入转发
    write_relay_end/1   % 写入转发结束
]).

-include ("tool.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    初始化game_router文件
init () ->
    RouterFileName      = ?GAME_ROUTER_DIR ++ "game_router.erl",
    {ok, RouterFile}    = file:open(RouterFileName, [write]),
    {Year, Month, Day}  = date(),
    ok = file:write(RouterFile, 
"-module (game_router).

-copyright  (\"Copyright @" ++ integer_to_list(Year) ++ " YiSiXEr\").
-author     (\"CHEONGYI\").
-date       ({" ++ lib_time:ymd_tuple_to_cover0str({Year, Month, Day}, ", ") ++ "}).
-vsn        (\"1.0.0\").

-export ([
    route_request/2
]).

% -include (\"game.hrl\").
% -include (\"gen/game_db.hrl\").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
route_request (_Pack = <<ModuleId:16/unsigned, ActionId:16/unsigned, Args/binary>>, State) ->
    put(prev_request, {ModuleId, ActionId}),
    TimeRecord  = game_perf:statistics_start(),
    {Module, Fuction, ArgsNum, NewState} = route_relay(ModuleId, ActionId, Args, State),
    gen_server:cast(game_perf, {set_info, {Module, Fuction, ArgsNum}, RunTimeSecond, WallClockSecond}),
    game_perf:statistics_end({Module, Fuction, ArgsNum}, TimeRecord),
    NewState.
"),
    RouterFile.

%%% @doc    写入转发
write_relay (RouterFile, ProtocolModule) ->
    ModuleId            = ProtocolModule #protocol_module.id,
    ModuleName          = ProtocolModule #protocol_module.name,
    ok = file:write(RouterFile, "
route_relay (" ++ ModuleId ++ ", ActionId, Args, State) ->
    case ActionId of"),
    write_action(RouterFile, ModuleName, ProtocolModule #protocol_module.action),
    ok = file:write(RouterFile, "
    end;").


%%% @doc    写入功能
write_action (RouterFile, ModuleName, [ProtocolAction | List]) ->
    ActionId            = ProtocolAction #protocol_action.id,
    ActionName          = ProtocolAction #protocol_action.name,
    ProtocolActionIn    = ProtocolAction #protocol_action.in,
    ok = file:write(RouterFile, "
        " ++ ActionId ++ " ->"),
    ok = file:write(RouterFile, "
            <<"),
    write_action_in_binary(RouterFile, ProtocolActionIn),
    ok = file:write(RouterFile, ">> = Args,
            NewState = api_" ++ ModuleName ++ ":" ++ ActionName ++ "("),
    write_action_in_args(RouterFile, ProtocolActionIn),
    ok = file:write(RouterFile, "State),
            {" ++ ModuleName ++ ", " ++ ActionName ++ ", " ++ integer_to_list(length(ProtocolActionIn) + 1) ++ ", NewState}"),
    case List of
        [] -> noop;
        _  -> ok = file:write(RouterFile, ";")
    end,
    write_action(RouterFile, ModuleName, List);
write_action (_RouterFile, _ModuleName, []) ->
    ok.

%%% @doc    写入功能in字节
write_action_in_binary (RouterFile, [ProtocolField | List]) ->
    FieldLine   = ProtocolField #protocol_field.line,
    FieldName   = ProtocolField #protocol_field.name,
    FieldType   = ProtocolField #protocol_field.type,
    FieldId     = integer_to_list(FieldLine),
    Variable    = "_" ++ FieldName ++ "_" ++ FieldId,
    ok = file:write(RouterFile, 
        if
            %% string
            FieldType == "list" orelse
            FieldType == "string"   ->
                "Len" ++ FieldId ++ ":16/unsigned, " ++ Variable ++ ":Len" ++ FieldId ++ "/binary";
            % FieldType == "typeof"   ->
            true ->
                Variable ++ api_out:get_field_type_bin_suffix(FieldType)
        end
    ),
    case List of
        [] -> noop;
        _  -> ok = file:write(RouterFile, ", ")
    end,
    write_action_in_binary(RouterFile, List);
write_action_in_binary (_RouterFile, []) ->
    ok.

%%% @doc    写入功能in参数
write_action_in_args (RouterFile, [ProtocolField | List]) ->
    FieldLine   = ProtocolField #protocol_field.line,
    FieldName   = ProtocolField #protocol_field.name,
    FieldType   = ProtocolField #protocol_field.type,
    FieldId     = integer_to_list(FieldLine),
    Variable    = "_" ++ FieldName ++ "_" ++ FieldId,
    ok = file:write(RouterFile, 
        if
            %% string
            FieldType == "list" orelse
            FieldType == "string"   ->
                "binary_to_list(" ++ Variable ++ "), ";
            FieldType == "typeof"   ->
                Variable ++ "Tuple, ";
            true ->
                Variable ++ ", "
        end
    ),
    write_action_in_args(RouterFile, List);
write_action_in_args (_RouterFile, []) ->
    ok.

%%% @doc    写入转发结束
write_relay_end (RouterFile) ->
    ok = file:write(RouterFile, "
route_relay (module_id, _ActionId, _Args, _State) ->
    ok.
"),
    file:close(RouterFile).



