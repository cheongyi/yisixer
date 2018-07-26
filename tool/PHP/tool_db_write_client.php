<?php
    // 加载配置文件
    require 'table.php';
    require_once 'client_table.php';
    require_once 'client_const.php';

    is_dir(DIR_CLIENT_TABLES)   OR mkdir(DIR_CLIENT_TABLES);

    // ========== ======================================== ====================
    // 数据库表生成客户端代码
    show_schedule(PF_DBC_WRITE, 'start');
    $db_file_num    = count($sql_list);
    $db_file_num    += 1;
    write_client_table();
    write_client_const();
    show_schedule(PF_DBC_WRITE, 'end');
?>