<?php
    // 设定用于所有日期时间函数的默认时区
    date_default_timezone_set('Asia/Shanghai');


    // 数据库配置
    $db_sign        = 'localhost';
    if ($argc > 1) {
        $db_sign = $argv[1];
    }

    // 加载配置文件
    require_once 'constants.php';
    require_once 'lib_misc.php';

    require 'tool_db_read.php';
    require 'tool_db_write_client.php';
    require 'tool_db_close.php';
    require 'tool_pt_read.php';
    require 'tool_pt_write_client.php';
?>