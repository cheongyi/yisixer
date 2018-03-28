-module (tool).

-copyright  ("Copyright © 2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 20}).
-vsn        ("1.0.0").

% -compile (export_all).
-export ([start/0, stop/0, restart/0]).
-export ([
]).

-include ("tool.hrl").


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
    % io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, Operation]),
    case string:sub_string(Operation, 1, 1) of
        "1" ->
            % 服务端代码生成完毕
            % 服务端数据库映射代码生成完毕
            % 关键字未改变，不需要生成
            % 区域代码未改变，不需要生成
    {Time1, _} = statistics(runtime),
            generate_server_protocol(),
    {Time3, _} = statistics(runtime),
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, Time3 - Time1]),
            erlang:halt();
            % start();
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
%%% @doc    生成协议(服务端代码)
generate_server_protocol () ->
    {ok, FileNameList}  = file:list_dir(?PROTOCOL_DIR),
    generate_server_protocol(lists:sort(FileNameList -- ["Readme.txt"])).
    % generate_server_protocol (["50_dream_section.txt"]).
    % generate_server_protocol(["100_test.txt"]).
generate_server_protocol ([FileName | List]) ->
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, FileName]),
    ProtocolModule      = server_protocol:read(FileName),
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, ProtocolModule]),
    ProtocolActionList  = ProtocolModule #protocol_module.action,
    ProtocolClassList   = ProtocolModule #protocol_module.class,
    NewProtocolModule   = ProtocolModule #protocol_module{
        action  = lists:reverse([
            ProtocolAction #protocol_action{
                in      = lists:reverse(ProtocolAction #protocol_action.in),
                out     = lists:reverse(ProtocolAction #protocol_action.out)
            }
            ||
            ProtocolAction <- ProtocolActionList
        ]),
        class   = lists:reverse([
            ProtocolClass #protocol_class{
                field   = lists:reverse(ProtocolClass #protocol_class.field)
            }
            ||
            ProtocolClass <- ProtocolClassList
        ])
    },
    io:format("~p(~p) : ~p~n", [?MODULE, ?LINE, NewProtocolModule]),
    api_hrl:write(NewProtocolModule),
    api_out:write(NewProtocolModule),
    generate_server_protocol(List);
generate_server_protocol ([]) ->
    ok.












