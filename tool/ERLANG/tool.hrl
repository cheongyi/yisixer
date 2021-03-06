-define (PROJECT_DIR,   "../").                     % 项目根路径
-define (PROTOCOL_DIR, ?PROJECT_DIR ++ "server/protocol/").         % 协议路径
% -define (PROTOCOL_DIR,  ?PROJECT_DIR ++ "../COG/protocol/").         % 协议路径
% -define (PROTOCOL_DIR, ?PROJECT_DIR ++ "protocol/").         % 协议路径
-define (API_HRL_DIR,   ?PROJECT_DIR ++ "server/include/api/").  % api_hrl路径
-define (API_OUT_DIR,   ?PROJECT_DIR ++ "server/src/gen/api_out/").  % api_out路径
% -define (API_OUT_DIR,  ?PROJECT_DIR ++ "../cog/server-new/src/gen/").  % api_out路径
-define (GAME_ROUTER_DIR,  ?PROJECT_DIR ++ "server/src/gen/").  % game_router

-define (HRL_DEFINE_LEN, 50).

-record (protocol_module, {
    id      = 0,    % 模块ID
    name    = "",   % 模块名字
    class   = [],   % 模块类名  [#protocol_class{}...]
    action  = [],   % 模块接口  [#protocol_action{}...],
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
    line    = 0,    % 类ID
    name    = "",   % 类名字
    module  = "undefined",   % 类继承模块
    class   = "undefined",   % 类继承类
    field   = [],   % 类字段   [#protocol_field{}...]
    note    = ""    % 类注释
}).
-record (protocol_field, {
    line    = 0,    % 字段行数
    name    = "",   % 字段名字
    type    = "",   % 字段类型
    module  = "undefined",   % 字段引用模块
    class   = "undefined",   % 字段引用类
    list    = [],   % 字段列表  [#protocol_field{}...]
    enum    = [],   % 字段枚举  [{EnumUpper, Line, EnumNote}...]
    note    = ""    % 字段注释
}).
