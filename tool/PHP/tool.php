<?php
    // 数据库配置
    $db_sign        = 'localhost';
    if ($argc > 1) {
        $db_sign = $argv[1];
    }

    // 目录路径
    $project_dir    = "../../";

    // 选项打印
    $option_format  = "
请选择一个操作：
  1 - 生成代码(服务端)
  2 - 编译项目(服务端)
  3 - 生成代码(客户端)
  4 - 更新数据库
  x - 退出
> ";

    while (true) {
        echo $option_format;

        $line = trim(fgets(STDIN));

        if ($line == "1") {
            // shell_exec('erl -noshell -pa ../server/ebin -s tool generate_server_protocol -s init stop');
            // shell_exec('php tool_db.php '.$db_sign);
            require 'tool_pt.php';
            require 'tool_db.php';
            break;
        }
        elseif ($line == "2") {

        }
        elseif ($line == "3") {

        }
        elseif ($line == "4") {

        }
        elseif ($line == "x") {
            break;
        }
    }
?>