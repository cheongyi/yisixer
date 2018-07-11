<?php
    // 加载配置文件
    require_once 'pt_read.php';

    // 变量初始化
    $protocol       = array();
    $module_enum    = array();
    $line           = 0;
    $brace          = '';
    $note           = '';
    $pt_file_num    = 0;
    $field_name_max = 0;
    $filename_max   = 0;
    $schedule_i     = 0;

    // ========== ======================================== ====================
    // 读取协议
    show_schedule(PF_PT_READ, 'start');
    $protocol   = read_protocol();
    show_schedule(PF_PT_READ, 'end');

?>