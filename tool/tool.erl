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
-define (PROTOCOL_DIR, "server/protocol/").     % 协议路径
-record (protocol_file, {
    module_id   = 0,    % 模块ID
    name        = "",   % 模块名字
    action      = [],   % 模块接口  [#protocol_action{}...],
    class       = []    % 模块类名  [#protocol_field{}...]
}).
-record (protocol_action, {
    action_id   = 0,    % 接口ID
    name        = "",   % 接口名字
    in          = [],   % 客户端进来参数   [#protocol_field{}...]
    out         = []    % 服务端出去参数   [#protocol_field{}...]
}).
-record (protocol_field, {
    name        = "",   % 字段名字
    type        = "",   % 字段类型
    note        = ""    % 字段注释
}).
%%% @doc    生成协议(服务端代码)
generate_protocol_for_server () ->
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, file:get_cwd()]),
    {ok, FileNameList} = file:list_dir(?PROTOCOL_DIR),
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, FileNameList]),
    % generate_protocol_for_server (FileNameList).
    generate_protocol_for_server (["000_test.txt"]).
generate_protocol_for_server ([]) ->
    ok;
generate_protocol_for_server ([FileName | List]) ->
    {ok, File}  = file:open(?PROTOCOL_DIR ++ FileName, [read]),
    IdIndex     = string:str(FileName, "_"),
    NameIndex   = string:str(FileName, "."),
    ModuleIdStr = string:substr(FileName,           1, IdIndex - 1),
    ModuleName  = string:substr(FileName, IdIndex + 1, NameIndex - 1),
    ProtocolFile= #protocol_file{
        module_id   = list_to_integer(IdIndex),
        name        = ModuleName
    },
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, ProtocolFile]),
    read_one_protocol_for_server(File, ProtocolFile),
    file:close(File),
    generate_protocol_for_server (List).

read_one_protocol_for_server (File, ProtocolFile) ->
    case file:read_line(File) of
        {ok, Data} ->
            io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, Data]),
            read_one_protocol_for_server(File, ProtocolFile);
        Other      ->
            Other
    end.






