-module (server_protocol).

-copyright  ("Copyright © 2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 20}).
-vsn        ("1.0.0").

% -compile (export_all).
-export ([
    read/1              % 读取文件
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
                ["{" | _Note]   -> {ok, "{"};
                ["}" | _Note]   -> {ok, "}"};
                ["{}"]          -> {ok, "{}"};
                ["in"]          -> {ok, "in"};
                ["in{"]         -> {ok, "in{"};
                ["in{}"]        -> {ok, "in{}"};
                ["out"]         -> {ok, "out"};
                ["out{"]        -> {ok, "out{"};
                ["out{}"]       -> {ok, "out{}"};
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
                            read_list_of_field(File, []);
                        true ->
                            []
                    end,
                    Enum    = if
                        FieldType  == "enum" ->
                            put(field_enum_start, true),
                            read_enum_of_field(File, []);
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
read_list_of_field (File, List) ->
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
            read_list_of_field(File, List);
        {ok, "}"}   ->
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
            List;
        {field, ProtocolField} ->
            read_list_of_field(File, [ProtocolField | List]);
        Other ->
            Other
    end.

%%% @doc    读取字段枚举
read_enum_of_field (File, List) ->
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
                    read_enum_of_field(File, List);
                ["}" | _Note]   ->
                    case erase(field_enum_brace_start) of
                        true -> noop;
                        _    -> exit(field_enum_brace_start)
                    end,
                    put(field_enum_brace_end, true),
                    List;
                [""]    ->
                    read_enum_of_field(File, List);
                ["", _EnumNote]    ->
                    read_enum_of_field(File, List);
                [EnumUpper | EnumNote] ->
                    read_enum_of_field(File, [{EnumUpper, get(read_line), EnumNote} | List])
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
                [FieldModule, FieldClass] -> {"typeof",  FieldModule,    FieldClass -- ">"};
                [FieldClass]              -> {"typeof",  "undefined",    FieldClass -- ">"}
            end;
        ["list<"   ++ FieldClassRest] ->
            case string:split(FieldClassRest, ".") of
                [FieldModule, FieldClass] -> {"list",    FieldModule,    FieldClass -- ">"};
                [FieldClass]              -> {"list",    "undefined",    FieldClass -- ">"}
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
            {"empty_enum","undefined",  "undefined"};
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
remove_space_tabs_newline ("\n")        -> "";
remove_space_tabs_newline ("{\n")       -> "{";
remove_space_tabs_newline ("}\n")       -> "}";
remove_space_tabs_newline ("in\n")      -> "in";
remove_space_tabs_newline ("in{\n")     -> "in{";
remove_space_tabs_newline ("in{}\n")    -> "in{}";
remove_space_tabs_newline ("out\n")     -> "out";
remove_space_tabs_newline ("out{\n")    -> "out{";
remove_space_tabs_newline ("out{}\n")   -> "out{}";
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




