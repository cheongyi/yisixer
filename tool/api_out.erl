-module (api_out).

-copyright  ("Copyright © 2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 26}).
-vsn        ("1.0.0").

% -compile (export_all).
-export ([
    write/1             % 写入文件server/src/gen/api_out/*.erl
]).

-include ("tool.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    写入
write (ProtocolModule) ->
    ModuleId            = ProtocolModule #protocol_module.id,
    ModuleName          = ProtocolModule #protocol_module.name,
    ModuleNote          = ProtocolModule #protocol_module.note,

    ApiOutFileName      = ?API_OUT_DIR ++ "api_" ++ ModuleName ++ "_out.erl",
    {ok, ApiOutFile}    = file:open(ApiOutFileName, [write]),
    {Year, Month, Day}  = date(),
    ok = io:format(ApiOutFile, "%%% ~s", [list_to_binary(ModuleNote)]),
    ok = file:write(ApiOutFile, "
-module (api_" ++ ModuleName ++ "_out).

-copyright  (\"Copyright @" ++ integer_to_list(Year) ++ " YiSiXEr\").
-author     (\"CHEONGYI\").
-date       ({" ++ lib_time:ymd_tuple_to_cover0str({Year, Month, Day}, ", ") ++ "}).
-vsn        (\"1.0.0\").

-export ([\n"),
    write_export(ApiOutFile, ProtocolModule #protocol_module.action),
    ok = file:write(ApiOutFile, 
"    class_to_bin/2
]).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
"),
    write_function(ApiOutFile, ModuleId, ProtocolModule #protocol_module.action),
    write_class(ApiOutFile, ProtocolModule #protocol_module.class),
    write_class_field_list(ApiOutFile, ProtocolModule #protocol_module.class),
    write_action_field_list(ApiOutFile,  ProtocolModule #protocol_module.action),
    file:close(ApiOutFile).

%%% @doc    out文件写入函数导出
write_export (ApiOutFile, [ProtocolAction | List]) ->
    ActionName  = ProtocolAction #protocol_action.name,
    ok = file:write(ApiOutFile, 
"    " ++ ActionName ++ "/1,\n"),
    write_export(ApiOutFile, List);
write_export (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "\n").

%%% @doc    out文件写入函数
write_function (ApiOutFile, ModuleId, [ProtocolAction | List]) ->
    ActionId            = ProtocolAction #protocol_action.id,
    ActionName          = ProtocolAction #protocol_action.name,
    ProtocolActionOut   = ProtocolAction #protocol_action.out,
    ok = file:write(ApiOutFile, ActionName ++ " ({\n"),
    write_function_argument(ApiOutFile, ProtocolActionOut),
    ok = file:write(ApiOutFile, 
"}) ->"),
    write_function_body(ApiOutFile,     ProtocolActionOut),
    ok = file:write(ApiOutFile, 
"    <<
           " ++ ModuleId ++ ":16/unsigned,
        "    ++ ActionId ++ ":16/unsigned"),
    case ProtocolActionOut of
        [] -> noop;
        _  -> ok = file:write(ApiOutFile, ",\n")
    end,
    write_function_return(ApiOutFile,   ProtocolActionOut),
    ok = file:write(ApiOutFile, 
"    >>.\n\n"),
    write_function(ApiOutFile, ModuleId, List);
write_function (ApiOutFile, _ModuleId, []) ->
    ok = file:write(ApiOutFile, "
%%% ========== ======================================== ====================
%%% class_to_bin
%%% ========== ======================================== ====================
").

%%% @doc    out文件写入函数参数
write_function_argument (ApiOutFile, [ProtocolField | []]) ->
    FieldLine   = ProtocolField #protocol_field.line,
    FieldName   = ProtocolField #protocol_field.name,
    ok = file:write(ApiOutFile, 
"    _" ++ FieldName ++ "_" ++ integer_to_list(FieldLine) ++ "\n");
write_function_argument (ApiOutFile, [ProtocolField | List]) ->
    FieldLine   = ProtocolField #protocol_field.line,
    FieldName   = ProtocolField #protocol_field.name,
    ok = file:write(ApiOutFile, 
"    _" ++ FieldName ++ "_" ++ integer_to_list(FieldLine) ++ ",\n"),
    write_function_argument(ApiOutFile, List);
write_function_argument (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "\n").

%%% @doc    out文件写入函数主体
write_function_body (ApiOutFile, [ProtocolField | List]) ->
    FieldLine   = ProtocolField #protocol_field.line,
    FieldName   = ProtocolField #protocol_field.name,
    FieldType   = ProtocolField #protocol_field.type,
    FieldModule = case ProtocolField #protocol_field.module of
        "undefined" ->
            "";
        TheFieldModule  ->
            "api_" ++ TheFieldModule ++ "_out:"
    end,
    FieldClass  = ProtocolField #protocol_field.class,
    Variable    = "_" ++ FieldName ++ "_" ++ integer_to_list(FieldLine),
    if
        %% string
        FieldType == "string"   ->
            ok = file:write(ApiOutFile, "
    " ++ Variable ++ "_Bin    = list_to_binary(" ++ Variable ++ "),
    " ++ Variable ++ "_BinLen = size(" ++ Variable ++ "_Bin),\n");
        %% typeof
        FieldType == "typeof"   ->
            ok = file:write(ApiOutFile, "
    " ++ Variable ++ "_Bin = " ++ FieldModule ++ "class_to_bin(" ++ FieldClass ++ ", " ++ Variable ++ "),\n");
        %% just list
        FieldClass == "undefined" andalso
        FieldType == "list"     ->
            ok = file:write(ApiOutFile, "
    BinList" ++ Variable ++ " = [
        element_to_bin_" ++ integer_to_list(FieldLine) ++ "(" ++ Variable ++ "_Element)
        || 
        " ++ Variable ++ "_Element <- " ++ Variable ++ "
    ], 
    " ++ Variable ++ "_Bin    = list_to_binary(BinList" ++ Variable ++ "),
    " ++ Variable ++ "_BinLen = length(" ++ Variable ++ "),\n");
        %% list class
        FieldType == "list"     ->
            ok = file:write(ApiOutFile, "
    BinList" ++ Variable ++ " = [
        " ++ FieldModule ++ "class_to_bin(" ++ FieldClass ++ ", " ++ Variable ++ "_Element)
        || 
        " ++ Variable ++ "_Element <- " ++ Variable ++ "
    ], 
    " ++ Variable ++ "_Bin    = list_to_binary(BinList" ++ Variable ++ "),
    " ++ Variable ++ "_BinLen = length(" ++ Variable ++ "),\n");
        %% other
        true                    ->
            ignore
    end,
    write_function_body(ApiOutFile, List);
write_function_body (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "\n").

%%% @doc    out文件写入函数返回
write_function_return (ApiOutFile, [ProtocolField | List]) ->
    FieldLine   = ProtocolField #protocol_field.line,
    FieldName   = ProtocolField #protocol_field.name,
    FieldType   = ProtocolField #protocol_field.type,
    Variable    = "_" ++ FieldName ++ "_" ++ integer_to_list(FieldLine),
    ok = file:write(ApiOutFile, 
"        " ++ 
        case FieldType of 
            "string" ->
                Variable ++ "_BinLen:16/unsigned, " ++ Variable ++ get_field_type_bin_suffix(FieldType);
            "typeof" ->
                Variable ++ "_Bin/binary";
            "list"   ->
                Variable ++ "_BinLen:16/unsigned, " ++ Variable ++ get_field_type_bin_suffix(FieldType);
            _        ->
                Variable ++ get_field_type_bin_suffix(FieldType)
        end ++ 
        case List of
            [] ->
                "";
            _ ->
                ",\n"
        end
    ),
    write_function_return(ApiOutFile, List);
write_function_return (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "\n").

%%% @doc    获取字段类型对应的字节后缀
get_field_type_bin_suffix ("empty_enum")-> ":32/unsigned";
get_field_type_bin_suffix ("enum")      -> ":32/unsigned";
get_field_type_bin_suffix ("byte")      -> ":08/signed";
get_field_type_bin_suffix ("short")     -> ":16/signed";
get_field_type_bin_suffix ("int")       -> ":32/signed";
get_field_type_bin_suffix ("long")      -> ":64/signed";
get_field_type_bin_suffix ("list")      -> "_Bin/binary";
get_field_type_bin_suffix ("string")    -> "_Bin/binary".


%%% @doc    out文件写入类声明
write_class (ApiOutFile, [ProtocolClass | List]) ->
    ClassName   = ProtocolClass #protocol_class.name,
    ok = file:write(ApiOutFile, 
"class_to_bin (" ++ ClassName ++ ", {\n"),
    write_function_argument(ApiOutFile, ProtocolClass #protocol_class.field),
    ok = file:write(ApiOutFile, 
"}) ->"),
    write_function_body(ApiOutFile,     ProtocolClass #protocol_class.field),
    ok = file:write(ApiOutFile, 
"    <<\n"),
    write_function_return(ApiOutFile,   ProtocolClass #protocol_class.field),
    ok = file:write(ApiOutFile, 
"    >>;\n"),
    write_class(ApiOutFile, List);
write_class (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, 
"class_to_bin (_ClassName, _Class) ->
    <<>>.


%%% ========== ======================================== ====================
%%% element_to_bin_
%%% ========== ======================================== ====================
").


%%% @doc    out文件写入函数字段列表
write_class_field_list (ApiOutFile, [ProtocolClass | List]) ->
    write_field_list(ApiOutFile, ProtocolClass #protocol_class.field),
    write_class_field_list(ApiOutFile, List);
write_class_field_list (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "\n").

%%% @doc    out文件写入函数字段列表
write_action_field_list (ApiOutFile, [ProtocolAction | List]) ->
    write_field_list(ApiOutFile, ProtocolAction #protocol_action.out),
    write_action_field_list(ApiOutFile, List);
write_action_field_list (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "

%%% ========== ======================================== ====================
%%% end
%%% ========== ======================================== ====================
").

%%% @doc    out文件写入字段列表
write_field_list (ApiOutFile, [ProtocolField | List]) when 
    ProtocolField #protocol_field.type == "list" andalso
    ProtocolField #protocol_field.class == "undefined"
->
    ProtocolFieldLine   = ProtocolField #protocol_field.line,
    ProtocolFieldList   = lists:reverse(ProtocolField #protocol_field.list),
    ok = file:write(ApiOutFile, 
"element_to_bin_" ++ integer_to_list(ProtocolFieldLine) ++ " ({\n"),
    write_function_argument(ApiOutFile, ProtocolFieldList),
    ok = file:write(ApiOutFile, 
"}) ->"),
    write_function_body(ApiOutFile,     ProtocolFieldList),
    ok = file:write(ApiOutFile, 
"    <<\n"),
    write_function_return(ApiOutFile,   ProtocolFieldList),
    ok = file:write(ApiOutFile, 
"    >>.\n\n"),
    write_field_list(ApiOutFile, ProtocolFieldList),
    write_field_list(ApiOutFile, List);
write_field_list (ApiOutFile, [_ProtocolField | List]) ->
    write_field_list(ApiOutFile, List);
write_field_list (_ApiOutFile, []) ->
    ok.




