<?php
    // 加载配置文件
    require_once 'enum_table.php';
    require_once 'game_db_hrl.php';
    require_once 'game_db_data.php';
    require_once 'game_db_dump.php';
    require_once 'game_db_init.php';
    require_once 'game_db_sync.php';
    require_once 'game_db_table.php';

    is_dir(DIR_INCLUDE_GEN) OR mkdir(DIR_INCLUDE_GEN);
    is_dir(DIR_SRC_GEN)     OR mkdir(DIR_SRC_GEN);

    // ========== ======================================== ====================
    // 数据库表生成服务端代码
    show_schedule(PF_DBC_WRITE, 'start');
    db_enum();
    db_record();
    game_db_data();
    game_db_dump();
    game_db_init();
    game_db_sync();
    game_db_table();
    show_schedule(PF_DBC_WRITE, 'end');
?>