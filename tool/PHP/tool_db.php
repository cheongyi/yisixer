<?php
    // 设定用于所有日期时间函数的默认时区
    date_default_timezone_set("Asia/Shanghai");

    // 加载配置文件
    require_once 'conf.php';
    require_once 'lib_misc.php';
    require_once 'game_db_hrl.php';
    require_once 'game_db_data.php';
    require_once 'game_db_dump.php';
    require_once 'game_db_init.php';
    require_once 'game_db_sync.php';
    require_once 'game_db_table.php';

    // 数据库配置
    if ($argc > 1) {
        $db_sign = $argv[1];
    }
    elseif (! $db_sign) {
        $db_sign = 'localhost';
    }
    $db_host = $db_argv[$db_sign]['host'];
    $db_user = $db_argv[$db_sign]['user'];
    $db_pass = $db_argv[$db_sign]['pass'];
    $db_name = $db_argv[$db_sign]['name'];
    $db_port = $db_argv[$db_sign]['port'];

    // 目录路径
    $server_dir         = "{$project_dir}server/";
    $include_gen_dir    = "{$server_dir}include/gen/";
    $src_gen_dir        = "{$server_dir}src/gen/";
    is_dir($include_gen_dir) OR mkdir($include_gen_dir);
    is_dir($src_gen_dir)     OR mkdir($src_gen_dir);

    // 文件名称
    $game_db_hrl_file   = "{$include_gen_dir}game_db.hrl";
    $game_db_data       = "game_db_data";
    $game_db_data_file  = "{$src_gen_dir}{$game_db_data}.erl";
    $game_db_init       = "game_db_init";
    $game_db_init_file  = "{$src_gen_dir}{$game_db_init}.erl";
    $game_db_sync       = "game_db_sync";
    $game_db_sync_file  = "{$src_gen_dir}{$game_db_sync}.erl";
    $game_db_table      = "game_db_table";
    $game_db_table_file = "{$src_gen_dir}{$game_db_table}.erl";
    $game_db_dump       = "game_db_dump";
    $game_db_dump_file  = "{$src_gen_dir}{$game_db_dump}.erl";

    // 常量定义
    define(PF_DB_READ_SCH,  array("table   ", "field"));
    define(PF_DB_WRITE_SCH, array("define", "record", "hrl", "data", "dump", "init", "sync", "table"));
    define(PF_DB_READ,      "数据库表读取 ....... ");
    define(PF_DB_WRITE,     "数据生成代码(服务端) ");

    // 生成新的数据库连接对象
    show_schedule(PF_DB_READ, 'start');
    $mysqli = new mysqli($db_host, $db_user, $db_pass, $db_name, $db_port);
    if ($mysqli->connect_error) {
        die("Open '$db_name' failed (".$mysqli->connect_errno.".) ".$mysqli->connect_error.".\n");
    }
    $mysqli->query("SET NAMES utf8;");

    $schema = new mysqli($db_host, $db_user, $db_pass, 'information_schema', $db_port);
    if ($schema->connect_error) {
        die("Open 'information_schema' failed (".$schema->connect_errno.".) ".$schema->connect_error.".\n");
    }
    $schema->query("SET NAMES utf8;");
    show_schedule(PF_DB_READ, PF_DB_READ_SCH, count(PF_DB_READ_SCH), false);
    $tables_info        = get_tables_info();
    show_schedule(PF_DB_READ, PF_DB_READ_SCH, count(PF_DB_READ_SCH), false);
    $tables_fields_info = get_tables_fields_info();
    $table_name_len_max = $tables_info['NAME_LEN_MAX'];
    show_schedule(PF_DB_READ, 'end');

    // print_r($tables_info);
    // print_r($tables_fields_info);

    // ========== ======================================== ====================
    // 数据库表生成服务端代码
    show_schedule(PF_DB_WRITE, 'start');
    db_enum();
    db_record();
    show_schedule(PF_DB_WRITE, PF_DB_WRITE_SCH, count(PF_DB_WRITE_SCH));
    game_db_data();
    game_db_dump();
    game_db_init();
    game_db_sync();
    game_db_table();
    show_schedule(PF_PT_READ, 'end');

    // 关闭数据库连接
    $mysqli->close();
    $schema->close();
?>