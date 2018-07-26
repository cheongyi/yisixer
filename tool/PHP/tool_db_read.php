<?php
    // 加载配置文件
    require 'tool_db_conn.php';

    show_schedule(PF_DB_READ, $PF_DB_READ_SCH, count($PF_DB_READ_SCH), false);
    $tables_info        = get_tables_info();
    show_schedule(PF_DB_READ, $PF_DB_READ_SCH, count($PF_DB_READ_SCH), false);
    $tables_fields_info = get_tables_fields_info();
    $table_name_len_max = $tables_info['NAME_LEN_MAX'];
    show_schedule(PF_DB_READ, 'end');

    // print_r($tables_info);
    // print_r($tables_fields_info['item']);
?>