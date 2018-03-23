-module (server_protocol).

-copyright  ("Copyright © 2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 20}).
-vsn        ("1.0.0").

% -compile (export_all).
-export ([
    read/1,             % 读取文件
    write_api_hrl/1,    % 写入文件server/include/api/*.hrl
    write_api_out/1     % 写入文件server/src/gen/api_out/*.erl
]).

-include ("tool.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    读取
read (FileName) ->
    erase(),
    put(file_name, FileName),
    % erase(read_line),
    {ok, File}          = file:open(?PROTOCOL_DIR ++ FileName, [read]),
    ProtocolModuleInit  = module_init(FileName),
    ProtocolModuleTitle = read_module_name_id(File, ProtocolModuleInit),
    ProtocolAction      = read_class_and_action(File, ProtocolModuleTitle),
    file:close(File),
    ProtocolAction.


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    模块初始化
module_init (FileName) ->
    IdIndex     = string:str(FileName, "_"),
    NameIndex   = string:str(FileName, ".txt"),
    ModuleIdStr = string:sub_string(FileName,           1, IdIndex   - 1),
    ModuleName  = string:sub_string(FileName, IdIndex + 1, NameIndex - 1),
    #protocol_module{
        id      = ModuleIdStr,
        name    = ModuleName
    }.

%%% @doc    读取模块名称ID
read_module_name_id (File, ProtocolModule) ->
    case update_then_read_line(File) of
        {ok, Data} ->
            case remove_space_tabs_newline(Data) of
                "//" ++ NewNote ->
                    Note                = add_note(ProtocolModule #protocol_module.note, NewNote),
                    NewProtocolModule   = ProtocolModule #protocol_module{
                        note    = Note
                    },
                    read_module_name_id(File, NewProtocolModule);
                "{" ->
                    case erase(name_equal_id) of
                        true -> noop;
                        _    -> exit(name_equal_id)
                    end,
                    put(module_brace_start, true),
                    ProtocolModule;
                % ""  ->
                NameEqualId ->
                    case string:split(NameEqualId, "=") of
                        [Name, Id] ->
                            IsNameEqualId   = Name == ProtocolModule #protocol_module.name andalso
                                list_to_integer(Id) == list_to_integer(ProtocolModule #protocol_module.id),
                            if
                                IsNameEqualId ->
                                    put(name_equal_id, true);
                                true ->
                                    noop
                            end;
                        _ ->
                            noop
                    end,
                    read_module_name_id(File, ProtocolModule)
            end;
        'eof' ->
            case erase(module_brace_end) of
                true -> eof;
                _    -> exit(module_brace_end)
            end;
        Other ->
            Other
    end.

%%% @doc    读取模块尖括号结束
read_module_brace_end (File, Note) ->
    case update_then_read_line(File) of
        {ok, Data} ->
            RemoveData = remove_space_tabs_newline(Data),
            case string:split(RemoveData, "//") of
                ["}" | NewNote]   ->
                    case 
                        erase(module_brace_start) == true orelse 
                        erase(class_brace_end)    == true orelse 
                        erase(action_brace_end)   == true
                    of
                        true -> noop;
                        _    -> exit(module_brace_start)
                    end,
                    put(module_brace_end, true),
                    read_module_brace_end(File, add_note(Note, NewNote));
                [""]  ->
                    read_module_brace_end(File, Note);
                ["", NewNote]    ->
                    read_module_brace_end(File, add_note(Note, NewNote));
                ["class" ++ Class | NewNote] ->
                    %% 有接口会以class开头命名
                    case lists:member($=, Class) of
                        false ->
                            case 
                                erase(module_brace_start) == true orelse 
                                erase(class_brace_end)    == true orelse 
                                erase(action_brace_end)   == true
                            of
                                true -> noop;
                                _    -> exit(module_brace_start)
                            end,
            io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, Class]),
                            {class, Class, add_note(Note, NewNote)};
                        true ->
                            case 
                                erase(module_brace_start) == true orelse 
                                erase(class_brace_end)    == true orelse 
                                erase(action_brace_end)   == true
                            of
                                true -> noop;
                                _    -> exit(module_brace_start)
                            end,
            io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, "class" ++ Class]),
                            {action, "class" ++ Class, add_note(Note, NewNote)}
                    end;
                [ActionTitle | NewNote] ->
                    case 
                        erase(module_brace_start) == true orelse 
                        erase(class_brace_end)    == true orelse 
                        erase(action_brace_end)   == true
                    of
                        true -> noop;
                        _    -> exit(module_brace_start)
                    end,
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, ActionTitle]),
                    {action, ActionTitle, add_note(Note, NewNote)}
            end;
        'eof' ->
            case erase(module_brace_end) of
                true -> eof;
                _    -> exit(module_brace_end)
            end;
        Other ->
            Other
    end.

%%% @doc    读取类声明和接口
read_class_and_action (File, ProtocolModule) ->
    case read_module_brace_end(File, "") of
        {class, Class, Note}  ->
            ProtocolClassInit   = class_init(Class, Note),
            ProtocolClass       = read_class(File, ProtocolClassInit),
            NewProtocolModule   = ProtocolModule #protocol_module{
                class   = [ProtocolClass | ProtocolModule #protocol_module.class]
            },
            read_class_and_action(File, NewProtocolModule);
        {action, ActionTitle, Note} ->
            ProtocolActionInit  = action_init(File, ActionTitle, Note),
            ProtocolAction      = read_action(File, ProtocolActionInit),
            NewProtocolModule   = ProtocolModule #protocol_module{
                action   = [ProtocolAction | ProtocolModule #protocol_module.action]
            },
            read_class_and_action(File, NewProtocolModule);
        _ ->
            ProtocolModule
    end.

%%% @doc    类声明初始化
class_init (Class, Note) ->
    ClassName   = case string:split(Class, "{") of
        [TheClassName, ""] ->
            put(class_brace_start, true),
            TheClassName;
        [TheClassName] ->
            put(class_start, true),
            TheClassName
    end,
    #protocol_class{
        line    = get(read_line), 
        name    = ClassName, 
        note    = Note
    }.

%%% @doc    读取类声明
read_class (File, ProtocolClass) ->
    case read_field(File, #protocol_field{}) of
        {ok, "{"}   ->
            case erase(class_start) of
                true -> noop;
                _    -> exit(class_start)
            end,
            put(class_brace_start, true),
            read_class(File, ProtocolClass);
        {ok, "}"}   ->
            case erase(class_brace_start) of
                true -> noop;
                _    -> exit(class_brace_start)
            end,
            put(class_brace_end, true),
            ProtocolClass;
        {field, ProtocolField} ->
            NewProtocolClass = ProtocolClass #protocol_class{
                field   = [ProtocolField | ProtocolClass #protocol_class.field]
            },
            read_class(File, NewProtocolClass);
        Other ->
            Other
    end.

%%% @doc    接口初始化
action_init (File, ActionTitle, Note) ->
    [ActionName, ActionIdRest] = string:split(ActionTitle, "="),
    case string:split(ActionIdRest, "{") of
        [TheActionIdStr, ""] ->
            put(action_brace_start, true),
            InList  = read_action_in(File,  []),
            OutList = read_action_out(File, []),
            #protocol_action{
                id      = TheActionIdStr,
                name    = ActionName,
                note    = Note,
                in      = InList,
                out     = OutList
            };
        [TheActionIdStr] ->
            put(action_start, true),
            #protocol_action{
                id      = TheActionIdStr,
                name    = ActionName,
                note    = Note
            }
    end.

%%% @doc    读取接口
read_action (File, ProtocolAction) ->
    case update_then_read_line(File) of
        {ok, Data} ->
            case remove_space_tabs_newline(Data) of
                "{"     ->
                    case erase(action_start) of
                        true -> noop;
                        _    -> exit(action_start)
                    end,
                    put(action_brace_start, true),
                    InList              = read_action_in(File,  []),
                    OutList             = read_action_out(File, []),
                    NewProtocolAction   = ProtocolAction #protocol_action{
                        in      = InList,
                        out     = OutList
                    },
                    read_action(File, NewProtocolAction);
                "}"     ->
                    case erase(action_brace_start) of
                        true -> noop;
                        _    -> exit(action_brace_start)
                    end,
                    put(action_brace_end, true),
                    ProtocolAction;
                ""      ->
                    read_action(File, ProtocolAction)
            end;
        'eof' ->
            case erase(module_brace_end) of
                true -> eof;
                _    -> exit(module_brace_end)
            end;
        Other ->
            Other
    end.

%%% @doc    读取接口in
read_action_in (File, List) ->
    case read_field(File, #protocol_field{}) of
        {ok, "in"} ->
            put(action_in_start, true),
            read_action_in(File, List);
        {ok, "in{"} ->
            put(action_in_brace_start, true),
            read_action_in(File, List);
        {ok, "in{}"} ->
            put(action_in_brace_end, true),
            List;
        {ok, "{}"} ->
            case erase(action_in_start) of
                true -> noop;
                _    -> exit(action_in_start)
            end,
            put(action_in_brace_end, true),
            List;
        {ok, "{"} ->
            case erase(action_in_start) of
                true -> noop;
                _    -> exit(action_in_start)
            end,
            put(action_in_brace_start, true),
            read_action_in(File, List);
        {ok, "}"} ->
            case erase(action_in_brace_start) of
                true -> noop;
                _    -> exit(action_in_brace_start)
            end,
            put(action_in_brace_end, true),
            List;
        {field, ProtocolField} ->
            read_action_in(File, [ProtocolField | List]);
        Other ->
            Other
    end.

%%% @doc    读取接口out
read_action_out (File, List) ->
    case read_field(File, #protocol_field{}) of
        {ok, "out"} ->
            case erase(action_in_brace_end) of
                true -> noop;
                _    -> exit(action_in_brace_end)
            end,
            put(action_out_start, true),
            read_action_out(File, List);
        {ok, "out{"} ->
            put(action_out_brace_start, true),
            read_action_out(File, List);
        {ok, "out{}"} ->
            put(action_out_brace_end, true),
            List;
        {ok, "{}"} ->
            case erase(action_out_start) of
                true -> noop;
                _    -> exit(action_out_start)
            end,
            put(action_out_brace_end, true),
            List;
        {ok, "{"} ->
            case erase(action_out_start) of
                true -> noop;
                _    -> exit(action_in_start)
            end,
            put(action_out_brace_start, true),
            read_action_out(File, List);
        {ok, "}"} ->
            case erase(action_out_brace_start) of
                true -> noop;
                _    -> exit(action_out_brace_start)
            end,
            put(action_out_brace_end, true),
            List;
        {field, ProtocolField} ->
            read_action_out(File, [ProtocolField | List]);
        Other ->
            Other
    end.

%%% @doc    读取字段
read_field (File, ProtocolField) ->
    case update_then_read_line(File) of
        {ok, Data} ->
            RemoveData = remove_space_tabs_newline(Data),
            case string:split(RemoveData, "//") of
                ["", Note]    ->
                    NewProtocolField = ProtocolField #protocol_field{
                        note    = add_note(ProtocolField #protocol_field.note, Note)
                    },
                    read_field(File, NewProtocolField);
                [""]    ->
                    read_field(File, ProtocolField);
                ["{" | _Note]   ->
                    {ok, "{"};
                ["}" | _Note]   ->
                    {ok, "}"};
                ["{}"]  ->
                    {ok, "{}"};
                ["in"]  ->
                    {ok, "in"};
                ["in{"]  ->
                    {ok, "in{"};
                ["in{}"]  ->
                    {ok, "in{}"};
                ["out"] ->
                    {ok, "out"};
                ["out{"] ->
                    {ok, "out{"};
                ["out{}"] ->
                    {ok, "out{}"};
                [FieldNameType | Note] ->
                    [FieldName | FieldRest] = string:split(FieldNameType, ":"),
                    ProtocolFieldName       = ProtocolField #protocol_field{
                        line    = get(read_line),
                        name    = FieldName
                    },
                    {FieldType, FieldModule, FieldClass} = split_field_type_class(FieldRest),
                    NewNote = add_note(ProtocolFieldName #protocol_field.note, Note),
                    List    = if
                        FieldType  == "list" andalso
                        FieldClass == "undefined" ->
                            put(field_list_start, true),
                            read_field_list(File, []);
                        true ->
                            []
                    end,
                    Enum    = if
                        FieldType  == "enum" ->
                            put(field_enum_start, true),
                            read_field_enum(File, []);
                        true ->
                            []
                    end,
                    NewProtocolField    = ProtocolFieldName #protocol_field{
                        note    = NewNote,
                        type    = FieldType,
                        module  = FieldModule,
                        class   = FieldClass,
                        list    = List,
                        enum    = Enum
                    },
                    % put(field_end, true),
                    {field, NewProtocolField}
            end;
        'eof' ->
            case erase(module_brace_end) of
                true -> eof;
                _    -> exit(module_brace_end)
            end;
        Other ->
            Other
    end.

%%% @doc    读取字段列表
read_field_list (File, List) ->
    case read_field(File, #protocol_field{}) of
        {ok, "{"}   ->
            case erase(field_list_start) of
                true -> noop;
                _    -> exit(field_list_start)
            end,
            case get(field_list_brace_start) of
                undefined -> put(field_list_brace_start, 1);
                ListBrace -> put(field_list_brace_start, 1 + ListBrace)
            end,
            % put(field_list_brace_start, true),
            read_field_list(File, List);
        {ok, "}"}   ->
            % case get(field_list_brace_start) of
            %     true -> noop;
            %     _    -> exit(field_list_brace_start)
            % end,
            ListBraceStart  = get(field_list_brace_start),
            ListBraceEnd    = get(field_list_brace_end),
            if
                ListBraceStart =/= undefined andalso
                ListBraceEnd   ==  undefined ->
                    put(field_list_brace_end, 1);
                ListBraceStart =/= undefined andalso
                ListBraceEnd   =/= undefined andalso
                ListBraceStart ==  ListBraceEnd + 1 ->
                    erase(field_list_brace_start),
                    erase(field_list_brace_end);
                ListBraceStart =/= undefined andalso
                ListBraceEnd   =/= undefined andalso
                ListBraceStart >   ListBraceEnd ->
                    put(field_list_brace_end, 1 + ListBraceEnd);
                true ->
                    exit({list_brace, ListBraceStart, ListBraceEnd, get(read_line)})
            end,
            % case get(field_list_brace_end) of
            %     undefined -> put(field_list_brace_end, 1);
            %     ListBrace -> put(field_list_brace_end, 1 + ListBrace)
            % end,
            % put(field_list_brace_end, true),
            List;
        {field, ProtocolField} ->
            read_field_list(File, [ProtocolField | List]);
        Other ->
            Other
    end.

%%% @doc    读取字段枚举
read_field_enum (File, List) ->
    case update_then_read_line(File) of
        {ok, Data} ->
            RemoveData = remove_space_tabs_newline(Data),
            case string:split(RemoveData, "//") of
                ["{"]   ->
                    case erase(field_enum_start) of
                        true -> noop;
                        _    -> exit(field_enum_start)
                    end,
                    put(field_enum_brace_start, true),
                    read_field_enum(File, List);
                ["}" | _Note]   ->
                    case erase(field_enum_brace_start) of
                        true -> noop;
                        _    -> exit(field_enum_brace_start)
                    end,
                    put(field_enum_brace_end, true),
                    List;
                [""]    ->
                    read_field_enum(File, List);
                ["", _EnumNote]    ->
                    read_field_enum(File, List);
                [EnumUpper | EnumNote] ->
                    read_field_enum(File, [{EnumUpper, get(read_line), EnumNote} | List])
            end;
        'eof' ->
            case erase(module_brace_end) of
                true -> eof;
                _    -> exit(module_brace_end)
            end;
        Other ->
            Other
    end.

%%% @doc    分割字段的类型、类声明、注释
split_field_type_class (FieldRest) ->
    case FieldRest of 
        ["typeof<" ++ FieldClassRest] ->
            case string:split(FieldClassRest, ".") of
                [FieldModule, FieldClass] ->
                    {"typeof",  FieldModule,    FieldClass -- ">"};
                [FieldClass] ->
                    {"typeof",  "undefined",    FieldClass -- ">"}
            end;
        ["list<"   ++ FieldClassRest] ->
            case string:split(FieldClassRest, ".") of
                [FieldModule, FieldClass] ->
                    {"list",    FieldModule,    FieldClass -- ">"};
                [FieldClass] ->
                    {"list",    "undefined",    FieldClass -- ">"}
            end;
        ["list{"] ->
            case get(field_list_brace_start) of
                undefined -> put(field_list_brace_start, 1);
                ListBrace -> put(field_list_brace_start, 1 + ListBrace)
            end,
                    {"list",    "undefined",    "undefined"};
        ["enum{"] ->
            put(field_enum_brace_start, true),
                    {"enum",    "undefined",    "undefined"};
        ["enum{}"] ->
                    {"empty_enum",  "undefined",    "undefined"};
        [FieldType] ->
                    {FieldType, "undefined",    "undefined"}
    end.

%%% @doc    增加注释
add_note (OldNote, "") ->
    OldNote;
add_note (OldNote, [""]) ->
    OldNote;
add_note (OldNote, Note) ->
    OldNote ++ "%% " ++ Note.

%%% @doc    行数自增一然后读取下一行
update_then_read_line (File) ->
    update_line_number(),
    file:read_line(File).

%%% @doc    行数自增一
update_line_number () ->
    case get(read_line) of
        undefined -> put(read_line, 1);
        ReadLine  -> put(read_line, 1 + ReadLine)
    end,
    io:format("~p(~p) ~p : ~p~n", [?MODULE, ?LINE, get(file_name), get(read_line)]),
    ok.

%%% @doc    去除空格和换行
remove_space_tabs_newline ("\n") ->
    "";
remove_space_tabs_newline ("{\n") ->
    "{";
remove_space_tabs_newline ("}\n") ->
    "}";
remove_space_tabs_newline ("in\n") ->
    "in";
remove_space_tabs_newline ("in{\n") ->
    "in{";
remove_space_tabs_newline ("in{}\n") ->
    "in{}";
remove_space_tabs_newline ("out\n") ->
    "out";
remove_space_tabs_newline ("out{\n") ->
    "out{";
remove_space_tabs_newline ("out{}\n") ->
    "out{}";
remove_space_tabs_newline (Data) ->
    remove_space_tabs_newline(Data, [" ", "\t", "\n"]).
remove_space_tabs_newline (Data, [RemoveChar | List]) ->
    case Data -- RemoveChar of
        Data ->
            remove_space_tabs_newline(Data, List);
        RemoveData ->
            remove_space_tabs_newline(RemoveData, [RemoveChar | List])
    end;
remove_space_tabs_newline (Data, []) ->
    Data.
    % ((Data
    %  -- string:copies(" ", length(Data)))
    %  -- "\n")
    %  -- "\t".


%%% ========== ======================================== ====================
%%% @doc    写入文件server/include/api/*.hrl
write_api_hrl (ProtocolModule) ->
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
            Space       = string:copies(" ", max(1, 40 - length(RealEnumUpper))),
            ok = file:write(ApiHrlFile, 
"-define (" ++ RealEnumUpper ++ "," ++ Space ++ RealEnum ++ ").\n"),
            [{RealEnumUpper, RealEnum} | EnumList]
    end,
    write_api_hrl_enum(ApiHrlFile, List, NewEnumList);
write_api_hrl_enum   (_ApiHrlFile, [], EnumList) ->
    EnumList.


%%% ========== ======================================== ====================
%%% @doc    写入文件server/src/gen/api_out/*.erl
write_api_out (ProtocolModule) ->
    ModuleId            = ProtocolModule #protocol_module.id,
    ModuleName          = ProtocolModule #protocol_module.name,

    ApiOutFileName      = ?API_OUT_DIR ++ "api_" ++ ModuleName ++ "_out.erl",
    {ok, ApiOutFile}    = file:open(ApiOutFileName, [write]),
    {Year, Month, Day}  = date(),
    ok = file:write(ApiOutFile, 
"-module (api_" ++ ModuleName ++ "_out).

-copyright  (\"Copyright @" ++ integer_to_list(Year) ++ " YiSiXEr\").
-author     (\"CHEONGYI\").
-date       ({" ++ lib_time:ymd_tuple_to_cover0str({Year, Month, Day}, ", ") ++ "}).
-vsn        (\"1.0.0\").

-export ([\n"),
    write_api_out_export(ApiOutFile, ProtocolModule #protocol_module.action),
    ok = file:write(ApiOutFile, 
"    class_to_bin/2
]).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
"),
    write_api_out_function(ApiOutFile, ModuleId, ProtocolModule #protocol_module.action),
    write_api_out_class(ApiOutFile, ProtocolModule #protocol_module.class),
    write_api_out_class_field_list(ApiOutFile, ProtocolModule #protocol_module.class),
    write_api_out_action_field_list(ApiOutFile,  ProtocolModule #protocol_module.action),
    file:close(ApiOutFile).

%%% @doc    out文件写入函数导出
write_api_out_export (ApiOutFile, [ProtocolAction | List]) ->
    ActionName  = ProtocolAction #protocol_action.name,
    ok = file:write(ApiOutFile, 
"    " ++ ActionName ++ "/1,\n"),
    write_api_out_export(ApiOutFile, List);
write_api_out_export (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "\n").

%%% @doc    out文件写入函数
write_api_out_function (ApiOutFile, ModuleId, [ProtocolAction | List]) ->
    ActionId            = ProtocolAction #protocol_action.id,
    ActionName          = ProtocolAction #protocol_action.name,
    ProtocolActionOut   = ProtocolAction #protocol_action.out,
    ok = file:write(ApiOutFile, ActionName ++ " ({\n"),
    write_api_out_function_argument(ApiOutFile, ProtocolActionOut),
    ok = file:write(ApiOutFile, 
"}) ->"),
    write_api_out_function_body(ApiOutFile,     ProtocolActionOut),
    ok = file:write(ApiOutFile, 
"    <<
           " ++ ModuleId ++ ":16/unsigned,
        "    ++ ActionId ++ ":16/unsigned"),
    case ProtocolActionOut of
        [] -> noop;
        _  -> ok = file:write(ApiOutFile, ",\n")
    end,
    write_api_out_function_return(ApiOutFile,   ProtocolActionOut),
    ok = file:write(ApiOutFile, 
"    >>.\n\n"),
    write_api_out_function(ApiOutFile, ModuleId, List);
write_api_out_function (ApiOutFile, _ModuleId, []) ->
    ok = file:write(ApiOutFile, "
%%% ========== ======================================== ====================
%%% class_to_bin
%%% ========== ======================================== ====================
").

%%% @doc    out文件写入函数参数
write_api_out_function_argument (ApiOutFile, [ProtocolField | []]) ->
    FieldLine   = ProtocolField #protocol_field.line,
    FieldName   = ProtocolField #protocol_field.name,
    ok = file:write(ApiOutFile, 
"    _" ++ FieldName ++ "_" ++ integer_to_list(FieldLine) ++ "\n");
write_api_out_function_argument (ApiOutFile, [ProtocolField | List]) ->
    FieldLine   = ProtocolField #protocol_field.line,
    FieldName   = ProtocolField #protocol_field.name,
    ok = file:write(ApiOutFile, 
"    _" ++ FieldName ++ "_" ++ integer_to_list(FieldLine) ++ ",\n"),
    write_api_out_function_argument(ApiOutFile, List);
write_api_out_function_argument (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "\n").

%%% @doc    out文件写入函数主体
write_api_out_function_body (ApiOutFile, [ProtocolField | List]) ->
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
    write_api_out_function_body(ApiOutFile, List);
write_api_out_function_body (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "\n").

%%% @doc    out文件写入函数返回
write_api_out_function_return (ApiOutFile, [ProtocolField | List]) ->
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
    write_api_out_function_return(ApiOutFile, List);
write_api_out_function_return (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "\n").

%%% @doc    获取字段类型对应的字节后缀
get_field_type_bin_suffix ("empty_enum")     ->
    ":32/unsigned";
get_field_type_bin_suffix ("enum")     ->
    ":32/unsigned";
get_field_type_bin_suffix ("byte")     ->
    ":08/signed";
get_field_type_bin_suffix ("short")    ->
    ":16/signed";
get_field_type_bin_suffix ("int")      ->
    ":32/signed";
get_field_type_bin_suffix ("long")     ->
    ":64/signed";
get_field_type_bin_suffix ("list")     ->
    "_Bin/binary";
get_field_type_bin_suffix ("string")   ->
    "_Bin/binary".


%%% @doc    out文件写入类声明
write_api_out_class (ApiOutFile, [ProtocolClass | List]) ->
    ClassName   = ProtocolClass #protocol_class.name,
    ok = file:write(ApiOutFile, 
"class_to_bin (" ++ ClassName ++ ", {\n"),
    write_api_out_function_argument(ApiOutFile, ProtocolClass #protocol_class.field),
    ok = file:write(ApiOutFile, 
"}) ->"),
    write_api_out_function_body(ApiOutFile,     ProtocolClass #protocol_class.field),
    ok = file:write(ApiOutFile, 
"    <<\n"),
    write_api_out_function_return(ApiOutFile,   ProtocolClass #protocol_class.field),
    ok = file:write(ApiOutFile, 
"    >>;\n"),
    write_api_out_class(ApiOutFile, List);
write_api_out_class (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, 
"class_to_bin (_ClassName, _Class) ->
    <<>>.


%%% ========== ======================================== ====================
%%% element_to_bin_
%%% ========== ======================================== ====================
").


%%% @doc    out文件写入函数字段列表
write_api_out_class_field_list (ApiOutFile, [ProtocolClass | List]) ->
    write_api_out_field_list(ApiOutFile, ProtocolClass #protocol_class.field),
    write_api_out_class_field_list(ApiOutFile, List);
write_api_out_class_field_list (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "\n").

%%% @doc    out文件写入函数字段列表
write_api_out_action_field_list (ApiOutFile, [ProtocolAction | List]) ->
    write_api_out_field_list(ApiOutFile, ProtocolAction #protocol_action.out),
    write_api_out_action_field_list(ApiOutFile, List);
write_api_out_action_field_list (ApiOutFile, []) ->
    ok = file:write(ApiOutFile, "

%%% ========== ======================================== ====================
%%% end
%%% ========== ======================================== ====================
").

%%% @doc    out文件写入字段列表
write_api_out_field_list (ApiOutFile, [ProtocolField | List]) when 
    ProtocolField #protocol_field.type == "list" andalso
    ProtocolField #protocol_field.class == "undefined"
->
    ProtocolFieldLine   = ProtocolField #protocol_field.line,
    ProtocolFieldList   = lists:reverse(ProtocolField #protocol_field.list),
    ok = file:write(ApiOutFile, 
"element_to_bin_" ++ integer_to_list(ProtocolFieldLine) ++ " ({\n"),
    write_api_out_function_argument(ApiOutFile, ProtocolFieldList),
    ok = file:write(ApiOutFile, 
"}) ->"),
    write_api_out_function_body(ApiOutFile,     ProtocolFieldList),
    ok = file:write(ApiOutFile, 
"    <<\n"),
    write_api_out_function_return(ApiOutFile,   ProtocolFieldList),
    ok = file:write(ApiOutFile, 
"    >>.\n\n"),
    write_api_out_field_list(ApiOutFile, ProtocolFieldList),
    write_api_out_field_list(ApiOutFile, List);
write_api_out_field_list (ApiOutFile, [_ProtocolField | List]) ->
    write_api_out_field_list(ApiOutFile, List);
write_api_out_field_list (_ApiOutFile, []) ->
    ok.


