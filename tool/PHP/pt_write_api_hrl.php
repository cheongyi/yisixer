<?php
// =========== ======================================== ====================
// @todo   写入api头文件
function write_api_hrl () {
    global $protocol, $pt_file_num;

    show_schedule(PF_PTS_WRITE, API_ENUM_FILE_NAME, $pt_file_num);
    $file           = fopen(API_ENUM_FILE, 'w');
    write_attributes_note($file);

    $enum_len_max   = 50;
    $module_enum    = $protocol[C_ENUM];
    foreach ($module_enum as $key => $value) {
        $enum_note  = $value['enum_note'];
        if (is_numeric($key)) {
            fwrite($file, "%%% ");
            fwrite($file, $enum_note);
            fwrite($file, "\n");
            continue;
        }
        $enum_name  = $key;
        $enum_value = $value['enum_value'];

        $dots  = generate_char($enum_len_max, strlen($enum_name.$enum_value), ' ');
        fwrite($file, "-define (");
        fwrite($file, $key);
        fwrite($file, ",");
        fwrite($file, $dots);
        fwrite($file, $enum_value);
        fwrite($file, ").  %% ");
        fwrite($file, $enum_note);
        fwrite($file, "\n");
    }


    fclose($file);
}
?>