-module (api_hrl).

-copyright  ("Copyright © 2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 26}).
-vsn        ("1.0.0").

% -compile (export_all).
-export ([
    write/1             % 写入文件server/include/api/*.hrl
]).

-include ("tool.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    写入
write (ProtocolModule) ->
    ModuleClassList     = ProtocolModule #protocol_module.class,
    ModuleActionList    = ProtocolModule #protocol_module.action,
    ModuleName          = ProtocolModule #protocol_module.name,
    ApiHrlFileName      = ?API_HRL_DIR ++ "api_" ++ ModuleName ++ ".hrl",
    {ok, ApiHrlFile}    = file:open(ApiHrlFileName, [write]),
    ClassEnumList       = write_api_hrl_class_enum(ApiHrlFile, ModuleClassList, []),
    write_api_hrl_action_enum(ApiHrlFile, ModuleActionList, ClassEnumList).

%%% @doc    hrl文件写入类声明枚举
write_api_hrl_class_enum  (ApiHrlFile, [ProtocolClass | List], EnumList) ->
    ClassEnumList  = write_api_hrl_field_enum(ApiHrlFile, ProtocolClass #protocol_class.field, EnumList),
    write_api_hrl_class_enum(ApiHrlFile, List, ClassEnumList);
write_api_hrl_class_enum  (_ApiHrlFile, [], EnumList) ->
    EnumList.

%%% @doc    hrl文件写入接口中枚举
write_api_hrl_action_enum (ApiHrlFile, [ProtocolAction | List], EnumList) ->
    InEnumList  = write_api_hrl_field_enum(ApiHrlFile, ProtocolAction #protocol_action.in,  EnumList),
    OutEnumList = write_api_hrl_field_enum(ApiHrlFile, ProtocolAction #protocol_action.out, InEnumList),
    write_api_hrl_action_enum(ApiHrlFile, List, OutEnumList);
write_api_hrl_action_enum (_ApiHrlFile, [], EnumList) ->
    EnumList.

%%% @doc    hrl文件写入字段中枚举
write_api_hrl_field_enum  (ApiHrlFile, [ProtocolField | List], EnumList) ->
    Enum        = lists:reverse(ProtocolField #protocol_field.enum),
    NewEnumList = write_api_hrl_enum(ApiHrlFile, Enum, EnumList),
    write_api_hrl_field_enum(ApiHrlFile, List, NewEnumList);
write_api_hrl_field_enum  (_ApiHrlFile, [], EnumList) ->
    EnumList.

%%% @doc    hrl文件写入枚举
write_api_hrl_enum   (ApiHrlFile, [{EnumUpper, Line, _EnumNote} | List], EnumList) ->
    [RealEnumUpper, RealEnum]    = case string:split(EnumUpper, "=") of
        [TheEnumUpper, TheEnum] -> [TheEnumUpper, TheEnum];
        [EnumUpper]             -> [EnumUpper,    integer_to_list(Line)]
    end,
    NewEnumList = case lists:keyfind(RealEnumUpper, 1, EnumList) of
        {RealEnumUpper, _Line} ->
            EnumList;
        _ ->
            Space       = string:copies(" ", max(1, 40 - length(RealEnumUpper) - length(RealEnum))),
            ok = file:write(ApiHrlFile, 
"-define (" ++ RealEnumUpper ++ "," ++ Space ++ RealEnum ++ ")."),
            ok = io:format(ApiHrlFile, "    % ~s\n", [list_to_binary(_EnumNote)]),
            [{RealEnumUpper, RealEnum} | EnumList]
    end,
    write_api_hrl_enum(ApiHrlFile, List, NewEnumList);
write_api_hrl_enum   (_ApiHrlFile, [], EnumList) ->
    EnumList.




