<?php
    /*
     *  常量定义
     */
    error_reporting(E_ALL ^ E_NOTICE);

    define(SIGN_WINDOW, 'window');
    if ($db_sign == SIGN_WINDOW) {
        define(SCHEDULE,    "\r%s [%-30s][%3d%%][%s]");
    }
    else {
        define(SCHEDULE,    "\r%s\033[42m %-30s[\033[1m%3d%%\033[0m\033[42m][%s]\033[0m");
    }
    // 选项打印
    define(OPTION_FORMAT,   '
请选择一个操作：
  1 - 生成代码(服务端)
  2 - 编译项目(服务端)
  3 - 生成代码(客户端)
  4 - 更新数据库
  x - 退出
> ');

    define(PF_PT_READ,        '  协议文本读取 ....... ');
    define(PF_PTS_WRITE,      '  协议生成代码(服务端) ');
    define(PF_PTC_WRITE,      '  协议生成代码(客户端) ');

    define(PF_DB_READ,        '  数据库表读取 ....... ');
    define(PF_DB_WRITE,       '  数据生成代码(服务端) ');

    define(DONE_1,          "\n  1 - 生成代码(服务端) Done !\n\n");
    define(DONE_2,          "\n  2 - 编译项目(服务端) Done !\n\n");
    define(DONE_3,          "\n  3 - 生成代码(客户端) Done !\n\n");
    define(DONE_4,          "\n  4 - 更新数据库 Done !\n\n");

    // 目录路径
    define(DIR_PROJECT,     '../../');
    define(DIR_PROTOCOL,    DIR_PROJECT.'protocol/');
    define(DIR_SERVER,      DIR_PROJECT.'server/');
    define(DIR_INCLUDE_API, DIR_SERVER .'include/api/');
    define(DIR_INCLUDE_GEN, DIR_SERVER .'include/gen/');
    define(DIR_API_OUT,     DIR_SERVER .'src/api_out/');
    define(DIR_SRC_GEN,     DIR_SERVER .'src/gen/');

    define(DIR_CLIENT_PACKET,   DIR_PROJECT.'client/Farm/assets/Script/net/');  // 客户端协议包
    define(DIR_CLIENT_ACTION,   DIR_PROJECT.'client/Farm/assets/Script/');      // 客户端接口包

    // ==================== 数据库 ====================
    // 文件名称
    define(GAME_DB_DATA,            'game_db_data');
    define(GAME_DB_DUMP,            'game_db_dump');
    define(GAME_DB_INIT,            'game_db_init');
    define(GAME_DB_SYNC,            'game_db_sync');
    define(GAME_DB_TABLE,           'game_db_table');
    define(GAME_DB_DATA_FILE_NAME,  GAME_DB_DATA .'.erl');
    define(GAME_DB_DUMP_FILE_NAME,  GAME_DB_DUMP .'.erl');
    define(GAME_DB_INIT_FILE_NAME,  GAME_DB_INIT .'.erl');
    define(GAME_DB_SYNC_FILE_NAME,  GAME_DB_SYNC .'.erl');
    define(GAME_DB_TABLE_FILE_NAME, GAME_DB_TABLE.'.erl');
    define(GAME_DB_HRL_FILE_NAME,   'game_db.hrl');
    define(GAME_DB_HRL_FILE,        DIR_INCLUDE_GEN.GAME_DB_HRL_FILE_NAME);
    define(GAME_DB_DATA_FILE,       DIR_SRC_GEN.GAME_DB_DATA_FILE_NAME);
    define(GAME_DB_DUMP_FILE,       DIR_SRC_GEN.GAME_DB_DUMP_FILE_NAME);
    define(GAME_DB_INIT_FILE,       DIR_SRC_GEN.GAME_DB_INIT_FILE_NAME);
    define(GAME_DB_SYNC_FILE,       DIR_SRC_GEN.GAME_DB_SYNC_FILE_NAME);
    define(GAME_DB_TABLE_FILE,      DIR_SRC_GEN.GAME_DB_TABLE_FILE_NAME);

    define(CLIENT_ENUM_FILE_NAME,   'errorCode.js');    // 客户端错误码文件名
    define(CLIENT_ENUM_FILE,        DIR_CLIENT_PACKET.CLIENT_ENUM_FILE_NAME);
    define(CLIENT_PACKET_FILE_NAME, 'packets.js');      // 客户端协议包文件名
    define(CLIENT_PACKET_FILE,      DIR_CLIENT_PACKET.CLIENT_PACKET_FILE_NAME);
    define(CLIENT_ACTION_FILE_NAME, 'actions.js');      // 客户端接口文件名
    define(CLIENT_ACTION_FILE,      DIR_CLIENT_ACTION.CLIENT_ACTION_FILE_NAME);

    // 打印格式printf
    define(PF_DB_READ_SCH,  serialize(array('table ', ' field')));
    $PF_DB_READ_SCH     = unserialize(PF_DB_READ_SCH);
    define(PF_DB_WRITE_SCH, serialize(array(
        GAME_DB_HRL_FILE_NAME.'::define', 
        GAME_DB_HRL_FILE_NAME.'::record', 
        GAME_DB_DATA_FILE_NAME, 
        GAME_DB_DUMP_FILE_NAME, 
        GAME_DB_INIT_FILE_NAME, 
        GAME_DB_SYNC_FILE_NAME, 
        GAME_DB_TABLE_FILE_NAME
    )));
    $PF_DB_WRITE_SCH    = unserialize(PF_DB_WRITE_SCH);

    // ==================== 协议 ====================
    // 文件名称
    define(API_ENUM_FILE_NAME,      'api_enum.hrl');
    define(API_ENUM_FILE,           DIR_INCLUDE_GEN.API_ENUM_FILE_NAME);
    define(CLASS_FILE_NAME,         'class.hrl');
    define(CLASS_FILE,              DIR_INCLUDE_GEN.CLASS_FILE_NAME);
    define(GAME_ROUTER,             'game_router');
    define(GAME_ROUTER_FILE_NAME,   GAME_ROUTER.'.erl');
    define(GAME_ROUTER_FILE,        DIR_SRC_GEN.GAME_ROUTER_FILE_NAME);

    define(NAME_LEN_MAX,            50);


    // 协议符号定义
    define(SYMBOL_NOTE,             '//');  // 符号 - 注释
    define(SYMBOL_ASSIGN,           '=');   // 符号 - 赋值
    define(SYMBOL_ANGLE_LEFT,       '<');   // 符号 - 左尖括号
    define(SYMBOL_ANGLE_RIGHT,      '>');   // 符号 - 左尖括号
    define(SYMBOL_BRACE_LEFT,       '{');   // 符号 - 左大括号
    define(SYMBOL_BRACE_RIGHT,      '}');   // 符号 - 右大括号
    define(SYMBOL_ACTION_IN,        'in');  // 符号 - IN
    define(SYMBOL_ACTION_OUT,       'out'); // 符号 - OUT
    define(SYMBOL_PACKAGE,          '.');   // 符号 - 包引用
    define(SYMBOL_CLASEE_EXTEND,    '::');  // 符号 - 类继承
    define(SYMBOL_TYPE_DEF,         ':');   // 符号 - 类型定义
    define(UNDER_LINE,              '_');   // 符号 - 下划线
    // 
    define(C_MODULE,        'module');      // 模块
    define(C_ACTION,        'action');      // 接口
    define(C_ACTION_IN,     'action_in');   // 接口IN
    define(C_ACTION_OUT,    'action_out');  // 接口OUT
    define(C_CLASS,         'class');       // 类
    define(C_ENUM,          'enum');        // 枚举
    define(C_BYTE,          'byte');        // 字节
    define(C_SHORT,         'short');       // 短整型
    define(C_INT,           'int');         // 基本整型
    define(C_LONG,          'long');        // 长整型
    define(C_STRING,        'string');      // 字符串
    define(C_TYPEOF,        'typeof');      // 单一类元组
    define(C_LIST,          'list');        // 列表
    define(C_MODULE_LEN,    strlen(C_MODULE));
    define(C_ACTION_LEN,    strlen(C_ACTION));
    define(C_CLASS_LEN,     strlen(C_CLASS));
    // binary类型后缀
    define(BT_MODULE,       ':16/unsigned');        // 模块ID(2018-06-27弃用)
    define(BT_ACTION,       ':16/little-unsigned'); // 接口ID
    define(BT_ENUM,         ':32/little-unsigned'); // 枚举
    define(BT_BYTE,         ':08/little-unsigned'); // 字节
    define(BT_SHORT,        ':16/little-unsigned'); // 短整型
    define(BT_INT,          ':32/little-unsigned'); // 基本整型
    define(BT_LONG,         ':64/little-unsigned'); // 长整型
    define(BT_O_DATA_LEN,   ':16/little-unsigned'); // 数据长度(包括自己)
    define(BT_O_ACTION,     ':16/little-unsigned'); // OUT - 接口ID
    define(BT_O_ENUM,       ':32/little-unsigned'); // OUT - 枚举
    define(BT_O_BYTE,       ':08/little-unsigned'); // OUT - 字节
    define(BT_O_SHORT,      ':16/little-unsigned'); // OUT - 短整型
    define(BT_O_INT,        ':32/little-unsigned'); // OUT - 基本整型
    define(BT_O_LONG,       ':64/little-unsigned'); // OUT - 长整型
    define(BT_O_BIN_SIZE,   ':16/little-unsigned'); // OUT - BIN大小(2018-06-27弃用)
    define(BT_O_STRING,     '_Bin/binary, 0');      // OUT - 字符串
    define(BT_O_LIST_LEN,   ':16/little-unsigned'); // 列表长度
    define(BT_LIST_LEN,     ':16/unsigned');        // 列表长度
    define(BT_STRING,       '_Bin/binary');         // 字符串
    define(BT_TYPEOF,       '_Bin/binary');         // 单一类元组
    define(BT_LIST,         '_Bin/binary');         // 列表
    // 客户端字段别名
    define(CT_ENUM,         'u32');                 // 枚举
    define(CT_BYTE,         'u8');                  // 字节
    define(CT_SHORT,        'u16');                 // 短整型
    define(CT_INT,          'u32');                 // 基本整型
    define(CT_LONG,         'u64');                 // 长整型
    define(CT_STRING,       'str');                 // 字符串
    // 协议打印格式printf
    define(SPACE_OR_TAB,    serialize(array(' ', "\t")));
    $SPACE_OR_TAB          = unserialize(SPACE_OR_TAB);
    define(SPACE_ONE,       ' ');
    define(SPACE_04,        '    ');
    define(SPACE_08,        '        ');
    define(SPACE_12,        '            ');
    define(SPACE_16,        '                ');
    define(PF_ROTATE,       serialize(array('/', '-', '\\', '|')));
    // define(PF_ROTATE,       serialize(array('*', '-', '+', 'x')));
    $PF_ROTATE          = unserialize(PF_ROTATE);
?>