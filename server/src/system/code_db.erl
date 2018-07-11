-module (code_db).

%%% @doc    

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("WhoAreYou").
-date       ({2018, 06, 26}).
-vsn        ("1.0.0").

-export ([
    create/0,                       %
    create_table/1,                 % 生成表映射数据
    create_logic/1,                 % 生成逻辑映射数据
    create_logic_include_when/1,    % 生成逻辑映射数据，数据量大，使用when减少数据量

    get/2,                          % 
    get_logic/2                     % 
]).

-include ("define.hrl").

-define (FORMAT_DOT_NUMBER, 43).
-define (CODE_DB_FILE_DIR,  "src/gen/code_db/").    % 代码源文件路径
-define (CODE_DB_BEAM_DIR,  "ebin/").               % 代码beam文件路径
-define (TABLE_FILE_PRE,    "db_").     % 数据文件前缀
-define (LOGIC_FILE_PRE,    "logic_").  % 逻辑文件前缀


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
create () ->
    filelib:ensure_dir(?CODE_DB_FILE_DIR),
    create(code_db_data:get_table_list(), code_db_data:get_logic_list(), code_db_data:get_logic_include_when_list()),
    ok.


%%% @doc    生成表映射数据
create_table (TableName) ->
    Table       = ?ETS_TAB(TableName),
    RecordList  = [
        {element(2, Record), Record}
        ||
        Record <- lists:keysort(2, lib_ets:tab2list(Table))
    ],
    if
        is_list(RecordList) ->
            ModuleName    = ?TABLE_FILE_PRE ++ atom_to_list(TableName),
            Head        = get_head_code(ModuleName),
            Body        = get_body_code(RecordList, normal),
            build_code(ModuleName, Head ++ Body);
        true ->
            exit({invalid_table, TableName})
    end.

%%% @doc    生成逻辑映射数据
create_logic (Logic) ->
    ModuleName  = ?LOGIC_FILE_PRE ++ atom_to_list(Logic),
    Head        = get_head_code(ModuleName),
    Body        = get_body_code(code_db_data:Logic(), normal),
    build_code(ModuleName, Head ++ Body).

%%% @doc    生成逻辑映射数据,数据量大,使用when减少数据量,格式为[{{Id, Key}, Value}, ...],需要注意排序
create_logic_include_when (LogicIW) ->
    ModuleName  = ?LOGIC_FILE_PRE ++ atom_to_list(LogicIW),
    Head        = get_head_code(ModuleName),
    Body        = get_body_code(code_db_data:LogicIW(), include_when),
    build_code(ModuleName, Head ++ Body).


%%% @doc    生成逻辑映射数据
get (TableName, Key) when is_atom(TableName) ->
    get(atom_to_list(TableName), Key);
get (TableName, Key) ->
    apply(list_to_atom(?TABLE_FILE_PRE ++ TableName), get, Key).

%%% @doc    生成逻辑映射数据
get_logic (TableName, Key) when is_atom(TableName) ->
    get_logic(atom_to_list(TableName), Key);
get_logic (TableName, Key) ->
    apply(list_to_atom(?LOGIC_FILE_PRE ++ TableName), get, Key).


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
create (TableList, LogicList, LogicIncludeWhenList) ->
    [
        try create_table(TableName) of
            Result  -> ?INFO("building ~p ~s ~p",    [TableName, string:copies(".", ?FORMAT_DOT_NUMBER - length(atom_to_list(TableName))),  Result])
        catch
            _ : _   -> ?INFO("building ~p ~s error", [TableName, string:copies(".", ?FORMAT_DOT_NUMBER - length(atom_to_list(TableName)))])
        end
        ||
        TableName <- TableList
    ],

    [
        try create_logic(Logic) of
            Result  -> ?INFO("building ~p ~s ~p",    [Logic,     string:copies(".", ?FORMAT_DOT_NUMBER - length(atom_to_list(Logic))),      Result])
        catch
            _ : _   -> ?INFO("building ~p ~s error", [Logic,     string:copies(".", ?FORMAT_DOT_NUMBER - length(atom_to_list(Logic)))])
        end
        ||
        Logic <- LogicList
    ],

    [
        try create_logic_include_when(LogicIW) of
            Result  -> ?INFO("building ~p ~s ~p",    [LogicIW,   string:copies(".", ?FORMAT_DOT_NUMBER - length(atom_to_list(LogicIW))),    Result])
        catch
            _ : _   -> ?INFO("building ~p ~s error", [LogicIW,   string:copies(".", ?FORMAT_DOT_NUMBER - length(atom_to_list(LogicIW)))])
        end
        ||
        LogicIW <- LogicIncludeWhenList
    ],

    ?INFO("building code db finished =================================~n", []).


%%% @doc    获取头部代码
get_head_code (ModuleName) ->
    "-module (" ++ ModuleName ++ ").

-compile (export_all).

".

%%% @doc    获取主体代码
get_body_code (RecordList, Type) ->
    get_body_code(RecordList, ".", Type).

get_body_code ([{Key, Value}],              Body, Type) ->
    get_body_fun_code(Key, Value, Type) ++ Body;
get_body_code ([{Key, Value} | RecordList], Body, Type) ->
    get_body_code(RecordList, ";
" ++ get_body_fun_code(Key, Value, Type) ++ Body, Type).


%%% @doc    获取主体函数代码
get_body_fun_code (Key, Value, normal)       ->
    StrKey = get_key_str(Key, true),
    "
get (" ++ StrKey ++ ") ->
    " ++ lists:flatten(io_lib:write(Value));
get_body_fun_code (Key, Value, include_when) ->
    {StrKey, KeyValue, Operate} = get_key_str(Key, false),
    "
get (" ++ StrKey ++ ") when KeyValue " ++ Operate ++ KeyValue ++ " ->
    " ++ lists:flatten(io_lib:write(Value)).

%%% @doc    获取Key组成的字符串
get_key_str (Key, IsNormal) ->
    if
        IsNormal ->
            lib_misc:list_to_string(tuple_to_list(Key), ", ");
        true ->
            lists:foldl(
                fun(Element, {AllStrKey, _, _}) ->
                    {StrKey, KeyValue, Operate} = if
                        is_integer(Element) -> {integer_to_list(Element),  "", ""};
                        is_float(Element)   -> {float_to_list(Element),    "", ""};
                        is_tuple(Element)   -> {"KeyValue",                element(1, Element), element(2, Element)};
                        is_list(Element)    -> {"\"" ++ Element ++ "\"",   "", ""};
                        true                -> {Element,                   "", ""}
                    end,
                    {
                        if
                            AllStrKey =:= "" ->
                                StrKey;
                            true ->
                                AllStrKey ++ ", " ++ StrKey
                        end,
                        KeyValue,
                        Operate
                    }
                end,
                {"", "", ""},
                tuple_to_list(Key)
            )
    end.



%%% @doc    生成代码
build_code (ModuleName, Data) ->
    FileName    = ?CODE_DB_FILE_DIR ++ ModuleName ++ ".erl",
    case check_build_code(FileName, Data) of
        false ->
            {ok, File} = file:open(FileName, [write]),
            file:write(File, Data),
            compile:file(FileName, [{outdir, ?CODE_DB_BEAM_DIR}]),
            file:close(File);
        _ ->
            noop
    end.

%%% @doc    判断是否生成代码
check_build_code (FileName, Data) ->
    DataBin = list_to_binary(Data),
    {ok, DataBin} == file:read_file(FileName).



