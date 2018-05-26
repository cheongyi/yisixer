<?php
    // 设定用于所有日期时间函数的默认时区
    date_default_timezone_set('Asia/Shanghai');

    // 数据库配置
    $db_sign        = 'localhost';
    if ($argc > 1) {
        $db_sign = $argv[1];
    }

    /*
     *  常量定义
     */
    // 目录路径
    define(DIR_PROJECT,     '../../');
    define(DIR_SERVER,      DIR_PROJECT.'server/');
    define(DIR_PROTOCOL,    DIR_SERVER.'protocol/');
    define(DIR_INCLUDE_API, DIR_SERVER.'include/api/');
    define(DIR_INCLUDE_GEN, DIR_SERVER.'include/gen/');
    define(DIR_API_OUT,     DIR_SERVER.'src/api_out/');
    define(DIR_SRC_GEN,     DIR_SERVER.'src/gen/');
    is_dir(DIR_INCLUDE_API) OR mkdir(DIR_INCLUDE_API);
    is_dir(DIR_INCLUDE_GEN) OR mkdir(DIR_INCLUDE_GEN);
    is_dir(DIR_API_OUT)     OR mkdir(DIR_API_OUT);
    is_dir(DIR_SRC_GEN)     OR mkdir(DIR_SRC_GEN);
    // 进度条显示
    // define(PF_SHOW_LEN_MAX, 30);

    // 选项打印
    $option_format  = '
请选择一个操作：
  1 - 生成代码(服务端)
  2 - 编译项目(服务端)
  3 - 生成代码(客户端)
  4 - 更新数据库
  x - 退出
> ';

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

    while (true) {
        echo $option_format;

        $line = trim(fgets(STDIN));

        if ($line == '1') {
            // shell_exec('erl -noshell -pa ../server/ebin -s tool generate_server_protocol -s init stop');
            // shell_exec('php tool_db.php '.$db_sign);
            require 'tool_pt.php';
            require 'tool_db.php';
            echo "\n>>> 1 - 生成代码(服务端) Done <<<\n";
            break;
        }
        elseif ($line == '2') {
            system('cd ../../server && ./build.sh');
            echo "\n>>2 - 编译项目(服务端) Done <<\n";
        }
        elseif ($line == '3') {

        }
        elseif ($line == '4') {

        }
        elseif ($line == 'x') {
            break;
        }
    }
?>