<?php
    // 设定用于所有日期时间函数的默认时区
    date_default_timezone_set("Asia/Shanghai");

    // 加载配置文件
    require_once 'lib_misc.php';
    require_once 'pt_read.php';
    require_once 'pt_write_api_hrl.php';
    require_once 'pt_write_api_out.php';
    // require_once 'conf.php';

    // 目录路径
    // $protocol_dir       = "{$project_dir}../cog/protocol/";
    $protocol_dir       = "{$project_dir}server/protocol/";
    $server_dir         = "{$project_dir}server/";
    $include_api_dir    = "{$server_dir}include/api/";
    $api_out_dir        = "{$server_dir}/src/api_out/";

    // 文件名称
    $api_enum_file      = "{$include_api_dir}api_enum.hrl";

    // 常量定义
    define("C_MODULE",      "module");
    define("C_ACTION",      "action");
    define("C_ACTION_IN",   "action_in");
    define("C_ACTION_OUT",  "action_out");
    define("C_CLASS",       "class");
    define("C_ENUM",        "enum");
    define("C_LIST",        "list");
    define("C_MODULE_LEN",  strlen(C_MODULE));
    define("C_ACTION_LEN",  strlen(C_ACTION));
    define("C_CLASS_LEN",   strlen(C_CLASS));

    // 变量初始化
    $protocol       = array();
    $module_enum    = array();
    $line           = 0;
    $brace          = "";
    $note           = "";

    // 读取协议
    $start_time = microtime(true);
    echo "协议文本读取 ........... ";
    $protocol   = read_protocol();
    $end_time   = microtime(true);
    $cost_time  = round($end_time - $start_time, 3);
    echo "done in {$cost_time}s\n";

    // 协议文本生成服务端代码
    $start_time = microtime(true);
    echo "协议文本生成代码(服务端) [";
    write_api_hrl();
    echo "api_hrl";
    write_api_out();
    echo "|api_out";
    // write_game_router();
    echo "|game_router";
    $end_time   = microtime(true);
    $cost_time  = round($end_time - $start_time, 3);
    echo "] done in {$cost_time}s\n";
?>