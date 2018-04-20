<?php
    // 加载配置文件
    // require_once 'format.php';

    $db_sign        = 'localhost';
    if ($argc > 1) {
        $db_sign = $argv[1];
    }
    $run            = true;
    $option_format  = "
请选择一个操作：
  1 - 生成代码(服务端)
  2 - 编译项目(服务端)
  3 - 生成代码(客户端)
  4 - 更新数据库
  x - 退出
> ";

    while ($run) {
        echo $option_format;

        $line = trim(fgets(STDIN));

        if ($line == "1") {
            shell_exec('erl -noshell -pa ../server/ebin -s tool generate_server_protocol -s init stop');
            shell_exec('php tool_db.php '.$db_sign);
            // require 'tool_db.php';
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