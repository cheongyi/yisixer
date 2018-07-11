<?php
    // 加载配置文件
    require_once '../../database/conf.php';
    require_once 'enum_table.php';
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

    // 生成新的数据库连接对象
    show_schedule(PF_DB_READ, 'start');
    $mysqli = new mysqli($db_host, $db_user, $db_pass, $db_name, $db_port);
    if ($mysqli->connect_error) {
        die("Open '$db_name' failed (".$mysqli->connect_errno.".) ".$mysqli->connect_error.".\n");
    }
    $mysqli->query('SET NAMES utf8;');

    $schema = new mysqli($db_host, $db_user, $db_pass, 'information_schema', $db_port);
    if ($schema->connect_error) {
        die("Open 'information_schema' failed (".$schema->connect_errno.".) ".$schema->connect_error.".\n");
    }
    $schema->query('SET NAMES utf8;');
    show_schedule(PF_DB_READ, $PF_DB_READ_SCH, count($PF_DB_READ_SCH), false);
    $tables_info        = get_tables_info();
    show_schedule(PF_DB_READ, $PF_DB_READ_SCH, count($PF_DB_READ_SCH), false);
    $tables_fields_info = get_tables_fields_info();
    $table_name_len_max = $tables_info['NAME_LEN_MAX'];
    show_schedule(PF_DB_READ, 'end');

    // print_r($tables_info);
    // print_r($tables_fields_info['item']);

    // ========== ======================================== ====================
    // 数据库表生成服务端代码
    show_schedule(PF_DB_WRITE, 'start');
    db_enum();
    db_record();
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