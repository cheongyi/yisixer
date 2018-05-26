<?php
    // 加载配置文件
    require_once 'lib_misc.php';
    require_once 'pt_read.php';
    require_once 'pt_write_api_hrl.php';
    require_once 'pt_write_api_out.php';
    require_once 'pt_write_game_router.php';

    // 文件名称
    define(API_ENUM_FILE_NAME,      'api_enum.hrl');
    define(API_ENUM_FILE,           DIR_INCLUDE_API.API_ENUM_FILE_NAME);
    define(GAME_ROUTER,             'game_router');
    define(GAME_ROUTER_FILE_NAME,   GAME_ROUTER.'.erl');
    define(GAME_ROUTER_FILE,        DIR_SRC_GEN.GAME_ROUTER_FILE_NAME);

    /*
     *  常量定义
     */
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
    define(C_MODULE,        'module');
    define(C_ACTION,        'action');
    define(C_ACTION_IN,     'action_in');
    define(C_ACTION_OUT,    'action_out');
    define(C_CLASS,         'class');
    define(C_ENUM,          'enum');
    define(C_BYTE,          'byte');
    define(C_SHORT,         'short');
    define(C_INT,           'int');
    define(C_LONG,          'long');
    define(C_STRING,        'string');
    define(C_TYPEOF,        'typeof');
    define(C_LIST,          'list');
    define(C_MODULE_LEN,    strlen(C_MODULE));
    define(C_ACTION_LEN,    strlen(C_ACTION));
    define(C_CLASS_LEN,     strlen(C_CLASS));
    // binary类型后缀
    define(BT_ENUM,         ':32/unsigned');
    define(BT_BYTE,         ':08/unsigned');
    define(BT_SHORT,        ':16/unsigned');
    define(BT_INT,          ':32/unsigned');
    define(BT_LONG,         ':64/unsigned');
    define(BT_BIN_SIZE,     '_BinSize:16/unsigned');
    define(BT_LIST_LEN,     '_ListLen:16/unsigned');
    define(BT_STRING,       '_Bin/binary');
    define(BT_TYPEOF,       '_Bin/binary');
    define(BT_LIST,         '_Bin/binary');
    // 协议打印格式printf
    define(SPACE_ONE,       ' ');
    define(SPACE_04,        '    ');
    define(SPACE_08,        '        ');
    define(PF_ROTATE,       array('|', '/', '-', '\\'));
    define(PF_PT_WRITE_SCH, array('api_hrl ', 'api_out', 'game_router'));
    define(PF_PT_READ,      '协议文本读取 ....... ');
    define(PF_PT_WRITE,     '协议生成代码(服务端) ');

    // 变量初始化
    $protocol       = array();
    $module_enum    = array();
    $line           = 0;
    $brace          = '';
    $note           = '';
    $pt_file_num    = 0;
    $field_name_max = 0;
    $filename_max   = 0;
    $schedule_i     = 0;
// [ a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z].
// [01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26].

    // ========== ======================================== ====================
    // 读取协议
    show_schedule(PF_PT_READ, 'start');
    $protocol   = read_protocol();
    show_schedule(PF_PT_READ, 'end');

    // ========== ======================================== ====================
    // 协议文本生成服务端代码
    show_schedule(PF_PT_WRITE, 'start');
    $pt_file_num    = $pt_file_num + 1;
    write_api_hrl();
    write_game_router();
    write_api_out();
    show_schedule(PF_PT_WRITE, 'end');
?>