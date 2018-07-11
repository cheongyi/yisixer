<?php
    // 加载配置文件
    require_once 'client_packet.php';
    require_once 'client_action.php';
    require_once 'client_enum.php';

    // ========== ======================================== ====================
    // 协议文本生成客户端代码
    $pt_file_num        = 0;
    $protocol_module    = $protocol[C_MODULE];
    foreach ($protocol_module as $module) {
        $module_action  = $module['action'];
        $pt_file_num    += count($module_action);
    }
    // ActionId、C=>S、S=>C、Function、Action、errorCode.js
    $pt_file_num       *= 5;
    $pt_file_num       += 1;
    show_schedule(PF_PTC_WRITE, 'start');
    write_client_packet();
    write_client_action();
    write_error_code();
    show_schedule(PF_PTC_WRITE, 'end');

?>