<?php
    // header("Content-type: text/html; charset=utf-8");
    
    // 设定用于所有日期时间函数的默认时区
    date_default_timezone_set('Asia/Shanghai');

    // echo iconv("GB2312", "UTF-8", '中文');

    // 数据库配置
    $db_sign        = 'localhost';
    if ($argc > 1) {
        $db_sign = $argv[1];
    }

    // 加载配置文件
    require_once 'constants.php';
    require_once 'lib_misc.php';

// 请选择一个操作：
//   1 - 生成代码
//   2 - 编译项目
//   3 - 启动服务器
//   4 - 更新数据库
//   5 - 导出数据库
//   6 - 只编译客户端
//   7 - 只编译客户端(内网台版)
//   x - 退出
// > 

// 服务端代码生成完毕
// 服务端数据库映射代码生成完毕
// 关键字未改变，不需要生成
// 区域代码未改变，不需要生成

// 客户端代码生产完毕
// 客户端数据库映射代码生成完毕

    // 变量初始化
    $id_read_pt = false;
    $id_read_db = false;

    while (true) {
        echo OPTION_FORMAT;

        $line = trim(fgets(STDIN));

        if ($line == '1') {
            require 'tool_db_read.php';
            require 'tool_db_write_server.php';
            require 'tool_db_close.php';
            require 'tool_pt_read.php';
            require 'tool_pt_write_server.php';
            echo DONE_1;
            // break;
        }
        elseif ($line == '2') {
            if ($db_sign == SIGN_WINDOW) {
                system('cd ../../server && call build.bat');
            }
            else {
                system('cd ../../server && ./build.sh');
            }
            echo DONE_2;
        }
        elseif ($line == '3') {
            require 'tool_pt_read.php';
            require 'tool_pt_write_client.php';
            echo DONE_3;
        }
        elseif ($line == '4') {
            system('cd ../../database && php main.php update '.$db_sign.' && ./get_template_data.sh');
            echo DONE_4;
        }
        elseif ($line == 'x') {
            break;
        }
    }
?>