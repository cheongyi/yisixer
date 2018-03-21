-module (tool).

-copyright  ("Copyright © 2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 20}).
-vsn        ("1.0.0").

% -compile (export_all).
-export ([start/0, stop/0, restart/0]).
-export ([
]).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc
start () ->
    % os:cmd("php format.php"),
    %% 读取默认输出端里输入的前 N 个字符
% 请选择一个操作：
%   1 - 生成代码(服务端)
%   2 - 编译项目(服务端)
%   3 - 生成代码(客户端)
%   4 - 更新脚本(数据库)
%   x - 退出
% > 
    Operation = io:get_line("
Please choose an operation :
  1 - Generate code (Server)
  2 - Compile  proj (Server)
  3 - Generate code (Client)
  4 - Update   db   (Change)
  x - Exit
> "),
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, Operation]),
    case string:sub_string(Operation, 1, 1) of
        "1" ->
            % 服务端代码生成完毕
            % 服务端数据库映射代码生成完毕
            % 关键字未改变，不需要生成
            % 区域代码未改变，不需要生成
            generate_server_protocol(),
            start();
        "2" ->
            start();
        "3" ->
            % 客户端代码生产完毕
            % 客户端数据库映射代码生成完毕
            start();
        "4" ->
            % svn更新database完毕
            % 更新database完毕
            start();
        "x" ->
            erlang:halt();
        _   ->
            start()
    end.

stop () ->
    erlang:halt().

restart () ->
    stop(),
    start().


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
-define (PROTOCOL_DIR, "server/protocol/").         % 协议路径
-define (API_OUT_DIR,  "server/src/gen/api_out/").  % api_out路径
-record (protocol_module, {
    id      = 0,    % 模块ID
    name    = "",   % 模块名字
    action  = [],   % 模块接口  [#protocol_action{}...],
    class   = [],   % 模块类名  [#protocol_class{}...]
    note    = ""    % 模块注释
}).
-record (protocol_action, {
    id      = 0,    % 接口ID
    name    = "",   % 接口名字
    in      = [],   % 客户端进来参数   [#protocol_field{}...]
    out     = [],   % 服务端出去参数   [#protocol_field{}...]
    note    = ""    % 接口注释
}).
-record (protocol_class, {
    name    = "",   % 类名字
    field   = [],   % 类字段   [#protocol_field{}...]
    note    = ""    % 类注释
}).
-record (protocol_field, {
    line    = 0,    % 字段行数
    name    = "",   % 字段名字
    type    = "",   % 字段类型
    note    = ""    % 字段注释
}).
%%% @doc    生成协议(服务端代码)
generate_server_protocol () ->
    {ok, FileNameList}  = file:list_dir(?PROTOCOL_DIR),
    % generate_server_protocol (FileNameList).
    generate_server_protocol (["100_test.txt"]).
generate_server_protocol ([]) ->
    ok;
generate_server_protocol ([FileName | List]) ->
    ProtocolModule  = read_server_protocol(FileName),
    write_server_src_gen_api_out(ProtocolModule),
    generate_server_protocol (List).

read_server_protocol (FileName) ->
    erase(read_line),
    {ok, File}          = file:open(?PROTOCOL_DIR ++ FileName, [read]),
    ProtocolModuleInit  = protocol_module_init(FileName),
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, ProtocolModuleInit]),
    ProtocolModuleTitle = read_server_protocol_module_title(File, ProtocolModuleInit),
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, ProtocolModuleTitle]),
    ProtocolAction      = read_server_protocol_action_list(File, ProtocolModuleTitle),
    file:close(File),
    ProtocolAction.

%%% @doc    协议文件初始化
protocol_module_init (FileName) ->
    IdIndex     = string:str(FileName, "_"),
    NameIndex   = string:str(FileName, "."),
    ModuleIdStr = string:sub_string(FileName,           1, IdIndex   - 1),
    ModuleName  = string:sub_string(FileName, IdIndex + 1, NameIndex - 1),
    #protocol_module{
        id      = ModuleIdStr,
        name    = ModuleName
    }.

%%% @doc    读取协议文件标题
read_server_protocol_module_title (File, ProtocolModule) ->
    update_line_number(),
    ModuleIdStr     = ProtocolModule #protocol_module.id,
    ModuleName      = ProtocolModule #protocol_module.name,
    NameEqualId     = ModuleName ++ "=" ++ ModuleIdStr,
    case file:read_line(File) of
        {ok, Data} ->
            case remove_space_newline(Data) of
                NameEqualId     ->
                    put(name_equal_id, true),
                    read_server_protocol_module_title(File, ProtocolModule);
                "//" ++ Note    ->
                    NewNote = ProtocolModule #protocol_module.note ++ "\n%" ++ Note,
                    NewProtocolModule = ProtocolModule #protocol_module{
                        note    = NewNote
                    },
                    read_server_protocol_module_title(File, NewProtocolModule);
                "{" ->
                    case erase(name_equal_id) of
                        true -> ProtocolModule;
                        _    -> error_module_title_brace
                    end;
                ""  ->
                    read_server_protocol_module_title(File, ProtocolModule)
            end;
        'eof'      ->
            ProtocolModule;
        Other      ->
            Other
    end.

%%% @doc    读取协议文件结束
read_server_protocol_module_title_end (File, Note) ->
    case update_and_read_line(File) of
        {ok, Data} ->
            case remove_space_newline(Data) of
                "}" ->
                    put(protocol_module_end, true),
                    read_server_protocol_module_title_end(File, Note);
                ""  ->
                    read_server_protocol_module_title_end(File, Note);
                "//" ++ NewNote    ->
                    read_server_protocol_module_title_end(File, Note ++ "\n% " ++ NewNote);
                "class" ++ Class ->
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, Class]),
                    {class, #protocol_class{name = Class, note = Note}};
                ActionTitle  ->
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, ActionTitle]),
                    {action, ActionTitle, Note}
            end;
        'eof'      ->
            case erase(protocol_module_end) of
                true -> eof;
                _    -> error_module_title_eof
            end;
        Other      ->
            Other
    end.

%%% @doc    读取协议文件接口
read_server_protocol_action_list (File, ProtocolModule) ->
    case read_server_protocol_module_title_end(File, "") of
        {class, ProtocolClassInit}  ->
            put(protocol_action_class_start, true),
            ProtocolClass       = read_server_protocol_class(File, ProtocolClassInit),
            NewProtocolModule   = ProtocolModule #protocol_module{
                class   = [ProtocolClass | ProtocolModule #protocol_module.class]
            },
            read_server_protocol_action_list(File, NewProtocolModule);
        {action, ActionTitle, Note} ->
            ProtocolActionInit  = protocol_action_init(ActionTitle, Note),
            ProtocolAction      = read_server_protocol_action(File, ProtocolActionInit),
            NewProtocolModule   = ProtocolModule #protocol_module{
                action   = [ProtocolAction | ProtocolModule #protocol_module.action]
            },
            read_server_protocol_action_list(File, NewProtocolModule);
        _ ->
            ProtocolModule
    end.

%%% @doc    读取协议类
read_server_protocol_class (File, ProtocolClass) ->
    case read_server_protocol_field(File, #protocol_field{}) of
        "{"     ->
            put(protocol_action_class_brace_start, true),
            case erase(protocol_action_class_start) of
                true -> read_server_protocol_class(File, ProtocolClass);
                _    -> {error, protocol_action_class_start}
            end;
        "}"     ->
            case erase(protocol_action_class_brace_start) of
                true -> ProtocolClass;
                _    -> {error, protocol_action_class_brace_start}
            end;
        {field, ProtocolField} ->
            NewProtocolClass = ProtocolClass #protocol_class{
                field   = [ProtocolField | ProtocolClass #protocol_class.field]
            },
            read_server_protocol_class(File, NewProtocolClass);
        'eof'      ->
            case erase(protocol_module_end) of
                true -> eof;
                _    -> error_action
            end;
        Other      ->
            Other
    end.

%%% @doc    协议接口初始化
protocol_action_init (ActionTitle, Note) ->
    [ActionName, ActionIdStr] = string:split(ActionTitle, "="),
    #protocol_action{
        id      = ActionIdStr,
        name    = ActionName,
        note    = Note
    }.

%%% @doc    读取协议接口
read_server_protocol_action (File, ProtocolAction) ->
    case update_and_read_line(File) of
        {ok, Data} ->
            case remove_space_newline(Data) of
                "{"     ->
                    put(protocol_action_brace_start, true),
                    InList              = read_server_protocol_action_in(File,  []),
                    OutList             = read_server_protocol_action_out(File, []),
                    NewProtocolAction   = ProtocolAction #protocol_action{
                        in      = InList,
                        out     = OutList
                    },
                    read_server_protocol_action(File, NewProtocolAction);
                "}"     ->
                    case erase(protocol_action_brace_start) of
                        true -> ProtocolAction;
                        _    -> {error, protocol_action_brace_start}
                    end
            end;
        'eof'      ->
            case erase(protocol_module_end) of
                true -> eof;
                _    -> error_action
            end;
        Other      ->
            Other
    end.

%%% @doc    读取协议接口in
read_server_protocol_action_in (File, List) ->
    case read_server_protocol_field(File, #protocol_field{}) of
        "in"    ->
            put(protocol_action_in_start, true),
            read_server_protocol_action_in(File, List);
        "{"     ->
            put(protocol_action_in_brace_start, true),
            case erase(protocol_action_in_start) of
                true -> read_server_protocol_action_in(File, List);
                _    -> {error, protocol_action_in_start}
            end;
        "}"     ->
            case erase(protocol_action_in_brace_start) of
                true -> List;
                _    -> {error, protocol_action_in_brace_start}
            end;
        {field, ProtocolField} ->
            read_server_protocol_action_in(File, [ProtocolField | List]);
        'eof'      ->
            case erase(protocol_module_end) of
                true -> eof;
                _    -> error_action
            end;
        Other      ->
            Other
    end.

%%% @doc    读取协议接口out
read_server_protocol_action_out (File, List) ->
    case read_server_protocol_field(File, #protocol_field{}) of
        "out"   ->
            put(protocol_action_out_start, true),
            read_server_protocol_action_out(File, List);
        "{"     ->
            put(protocol_action_out_brace_start, true),
            case erase(protocol_action_out_start) of
                true -> read_server_protocol_action_out(File, List);
                _    -> {error, protocol_action_out_start}
            end;
        "}"     ->
            case erase(protocol_action_out_brace_start) of
                true -> List;
                _    -> {error, protocol_action_out_brace_start}
            end;
        {field, ProtocolField} ->
            read_server_protocol_action_out(File, [ProtocolField | List]);
        'eof'      ->
            case erase(protocol_module_end) of
                true -> eof;
                _    -> error_action
            end;
        Other      ->
            Other
    end.

%%% @doc    读取协议字段
read_server_protocol_field (File, ProtocolField) ->
    case update_and_read_line(File) of
        {ok, Data} ->
            RemoveData = remove_space_newline(Data),
            case string:split(RemoveData, ":") of
                [FieldName, FieldRest] ->
                    ProtocolFieldName   = ProtocolField #protocol_field{
                        line    = get(read_line),
                        name    = FieldName
                    },
                    ProtocolFieldType   = case string:split(FieldRest, "//") of
                        [FieldType, FieldNote] ->
                            ProtocolFieldName #protocol_field{
                                note    = ProtocolFieldName #protocol_field.note ++ "\n% " ++ FieldNote,
                                type    = FieldType
                            };
                        [FieldType] ->
                            ProtocolFieldName #protocol_field{
                                type    = FieldType
                            }
                    end,
                    {field, ProtocolFieldType};
                ["//" ++ Note]    ->
                    NewProtocolField = ProtocolField #protocol_field{
                        note    = ProtocolField #protocol_field.note ++ "\n% " ++ Note
                    },
                    read_server_protocol_field(File, NewProtocolField);
                [""] ->
                    read_server_protocol_field(File, ProtocolField);
                [InOutData] ->
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, InOutData]),
                    InOutData
            end;
        'eof'      ->
            case erase(protocol_module_end) of
                true -> eof;
                _    -> error_module_title_eof
            end;
        Other      ->
            Other
    end.

%%% @doc    更新行数
update_and_read_line (File) ->
    update_line_number(),
    file:read_line(File).

update_line_number () ->
    case get(read_line) of
        undefined -> put(read_line, 1);
        ReadLine  -> put(read_line, 1 + ReadLine)
    end,
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, get(read_line)]),
    ok.

%%% @doc    去除空格和换行
remove_space_newline (Data) ->
    (Data -- string:copies(" ", max(0, length(Data) - 2))) -- "\n".

%%% @doc    写入服务端out文件
write_server_src_gen_api_out (ProtocolModule) ->
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, ProtocolModule]),
    ModuleId            = ProtocolModule #protocol_module.id,
    ModuleName          = ProtocolModule #protocol_module.name,

    ApiOutFileName      = ?API_OUT_DIR ++ "api_" ++ ModuleName ++ "_out.erl",
    {ok, ApiOutFile}    = file:open(ApiOutFileName, [write]),
    {Year, Month, Day}  = date(),
    ok = file:write(ApiOutFile, 
"-module (api_" ++ ModuleName ++ "_out).\n"),

    ok = file:write(ApiOutFile, 
"
-copyright  (\"Copyright © " ++ integer_to_list(Year) ++ " YiSiXEr\").\n"),
    ok = file:write(ApiOutFile, 
"-author     (\"CHEONGYI\").\n"),
    ok = file:write(ApiOutFile, 
"-date       ({" ++ lib_time:ymd_tuple_to_cover0str({Year, Month, Day}, ", ") ++ "}).\n"),
    ok = file:write(ApiOutFile, 
"-vsn        (\"1.0.0\").

-export ([\n"),
    write_server_src_gen_api_out_export(ApiOutFile, ProtocolModule #protocol_module.action),
    ok = file:write(ApiOutFile, 
"]).


%%% ========== ======================================== ====================
"),
    write_server_src_gen_api_out_function(ApiOutFile, ModuleId, ProtocolModule #protocol_module.action),
    file:close(ApiOutFile).

%%% @doc    写入服务端out文件导出
write_server_src_gen_api_out_export (ApiOutFile, [ProtocolAction | []]) ->
    ActionName  = ProtocolAction #protocol_action.name,
    ok = file:write(ApiOutFile, 
"    " ++ ActionName ++ "/1\n");
write_server_src_gen_api_out_export (ApiOutFile, [ProtocolAction | List]) ->
    ActionName  = ProtocolAction #protocol_action.name,
    ok = file:write(ApiOutFile, 
"    " ++ ActionName ++ "/1,\n"),
    write_server_src_gen_api_out_export(ApiOutFile, List).

%%% @doc    写入服务端out文件函数
write_server_src_gen_api_out_function (_ApiOutFile, _ModuleId, []) ->
    ok;
write_server_src_gen_api_out_function (ApiOutFile, ModuleId, [ProtocolAction | List]) ->
    ActionId    = ProtocolAction #protocol_action.id,
    ActionName  = ProtocolAction #protocol_action.name,
    ok = file:write(ApiOutFile, ActionName ++ " ({\n"),
    write_server_src_gen_api_out_argument(ApiOutFile, ProtocolAction #protocol_action.out),
    ok = file:write(ApiOutFile, 
"}) ->
    <<
           " ++ ModuleId ++ ":16/unsigned,
        " ++ ActionId ++ ":16/unsigned"),
    write_server_src_gen_api_out_return(ApiOutFile, ProtocolAction #protocol_action.out),
    ok = file:write(ApiOutFile, 
"    >>.\n\n"),
    write_server_src_gen_api_out_function(ApiOutFile, ModuleId, List).

%%% @doc    写入服务端out文件参数
write_server_src_gen_api_out_argument (_ApiOutFile, []) ->
    empty_argument;
write_server_src_gen_api_out_argument (ApiOutFile, [ProtocolField | []]) ->
    FieldLine  = ProtocolField #protocol_field.line,
    FieldName  = ProtocolField #protocol_field.name,
    ok = file:write(ApiOutFile, 
"    _" ++ FieldName ++ "_" ++ integer_to_list(FieldLine) ++ "\n");
write_server_src_gen_api_out_argument (ApiOutFile, [ProtocolField | List]) ->
    FieldLine  = ProtocolField #protocol_field.line,
    FieldName  = ProtocolField #protocol_field.name,
    ok = file:write(ApiOutFile, 
"    _" ++ FieldName ++ "_" ++ integer_to_list(FieldLine) ++ ",\n"),
    write_server_src_gen_api_out_argument(ApiOutFile, List).

%%% @doc    写入服务端out文件参数
write_server_src_gen_api_out_return (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "\n");
write_server_src_gen_api_out_return (ApiOutFile, [ProtocolField | List]) ->
    FieldLine  = ProtocolField #protocol_field.line,
    FieldName  = ProtocolField #protocol_field.name,
    FieldType  = ProtocolField #protocol_field.type,
    ok = file:write(ApiOutFile, ",
        _" ++ FieldName ++ "_" ++ integer_to_list(FieldLine) ++ get_field_type_def(FieldType)),
    write_server_src_gen_api_out_return(ApiOutFile, List).

%%% @doc    获取字段类型对应的字节分类符定义
get_field_type_def ("enum")     ->
    ":8/unsigned";
get_field_type_def ("byte")     ->
    ":8/unsigned";
get_field_type_def ("short")    ->
    ":16/unsigned";
get_field_type_def ("int")      ->
    ":32/unsigned";
get_field_type_def ("long")     ->
    ":64/unsigned";
get_field_type_def ("typeof")   ->
    "/binary";
get_field_type_def ("list")     ->
    "/binary";
get_field_type_def ("string")   ->
    "/binary".











