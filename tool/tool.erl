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
            generate_protocol_for_server(),
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
-record (protocol_file, {
    module_id   = 0,    % 模块ID
    name        = "",   % 模块名字
    action      = [],   % 模块接口  [#protocol_action{}...],
    class       = [],   % 模块类名  [#protocol_field{}...]
    note        = ""    % 模块注释
}).
-record (protocol_action, {
    action_id   = 0,    % 接口ID
    name        = "",   % 接口名字
    in          = [],   % 客户端进来参数   [#protocol_field{}...]
    out         = [],   % 服务端出去参数   [#protocol_field{}...]
    note        = ""    % 接口注释
}).
-record (protocol_field, {
    name        = "",   % 字段名字
    type        = "",   % 字段类型
    note        = ""    % 字段注释
}).
%%% @doc    生成协议(服务端代码)
generate_protocol_for_server () ->
    {ok, FileNameList} = file:list_dir(?PROTOCOL_DIR),
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, FileNameList]),
    % generate_protocol_for_server (FileNameList).
    generate_protocol_for_server (["000_test.txt"]).
generate_protocol_for_server ([]) ->
    ok;
generate_protocol_for_server ([FileName | List]) ->
    ProtocolFile = read_server_protocol(FileName),
    write_server_src_gen_api_out(ProtocolFile),
    generate_protocol_for_server (List).

read_server_protocol (FileName) ->
    erase(read_line),
    {ok, File}          = file:open(?PROTOCOL_DIR ++ FileName, [read]),
    ProtocolFileIdName  = set_protocol_file_id_name(FileName),
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, ProtocolFileIdName]),
    ProtocolFile        = read_server_protocol_file_title(File, ProtocolFileIdName),
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, ProtocolFile]),
    file:close(File),
    ProtocolFile.

%%% @doc    设置协议文件ID和名字
set_protocol_file_id_name (FileName) ->
    IdIndex     = string:str(FileName, "_"),
    NameIndex   = string:str(FileName, "."),
    ModuleIdStr = string:sub_string(FileName,           1, IdIndex   - 1),
    ModuleName  = string:sub_string(FileName, IdIndex + 1, NameIndex - 1),
    #protocol_file{
        module_id   = ModuleIdStr,
        name        = ModuleName
    }.

%%% @doc    读取协议文件标题
read_server_protocol_file_title (File, ProtocolFile) ->
    update_line(),
    ModuleIdStr     = ProtocolFile #protocol_file.module_id,
    ModuleName      = ProtocolFile #protocol_file.name,
    NameEqualId     = ModuleName ++ "=" ++ ModuleIdStr,
    case file:read_line(File) of
        {ok, Data} ->
            case ((Data -- string:copies(" ", max(0, length(Data) - 2))) -- "\n") of
                NameEqualId     ->
                    put(name_equal_id, true),
                    read_server_protocol_file_title(File, ProtocolFile);
                "//" ++ Note    ->
                    NewNote = ProtocolFile #protocol_file.note ++ "\n%" ++ Note,
                    NewProtocolFile = ProtocolFile #protocol_file{
                        note    = NewNote
                    },
                    read_server_protocol_file_title(File, NewProtocolFile);
                "{"     ->
                    case get(name_equal_id) of
                        true -> ProtocolFile
                        _    -> error_title
                    end;
                ""      ->
                    read_server_protocol_file_title(File, ProtocolFile)
            end;
        'eof'      ->
            ProtocolFile;
        Other      ->
            Other
    end.

update_line () ->
    case get(read_line) of
        undefined -> put(read_line, 1);
        ReadLine  -> put(read_line, 1 + ReadLine)
    end.

write_server_src_gen_api_out (ProtocolFile) ->
    ModuleName          = ProtocolFile #protocol_file.name,

    ApiOutFileName      = ?API_OUT_DIR ++ "api_" ++ ModuleName ++ "_out.erl",
    {ok, ApiOutFile}    = file:open(ApiOutFileName, [write]),
    {Year, Month, Day}  = date(),
    ok = file:write(ApiOutFile, 
"-module (api_" ++ ModuleName ++ "_out).

-copyright  (\"Copyright © " ++ integer_to_list(Year) ++ " YiSiXEr\").
-author     (\"CHEONGYI\").
-date       ({" ++ lib_time:ymd_tuple_to_cover0str({Year, Month, Day}, ", ") ++ "}).
-vsn        (\"1.0.0\").

-export ([

]).


%%% ========== ======================================== ====================
"),
    file:close(ApiOutFile).





