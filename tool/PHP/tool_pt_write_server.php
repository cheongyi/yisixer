<?php
    // 加载配置文件
    require_once 'pt_write_api_hrl.php';
    require_once 'pt_write_class_hrl.php';
    require_once 'pt_write_api_out.php';
    require_once 'pt_write_game_router.php';

    is_dir(DIR_INCLUDE_GEN) OR mkdir(DIR_INCLUDE_GEN);
    is_dir(DIR_API_OUT)     OR mkdir(DIR_API_OUT);
    is_dir(DIR_SRC_GEN)     OR mkdir(DIR_SRC_GEN);

    // ========== ======================================== ====================
    // 协议文本生成服务端代码
    show_schedule(PF_PTS_WRITE, 'start');
    $pt_file_num    += 2;
    write_api_hrl();
    write_class_hrl();
    write_game_router();
    write_api_out();
    show_schedule(PF_PTS_WRITE, 'end');

?>