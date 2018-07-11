<?php
// =========== ======================================== ====================
// @todo   写入errorCode
function write_error_code () {
    global $protocol, $pt_file_num;

    show_schedule(PF_PTC_WRITE, CLIENT_ENUM_FILE_NAME, $pt_file_num);
    $file           = fopen(CLIENT_ENUM_FILE, 'w');

    fwrite($file, '
const ERROR_CODE =
{');

    $enum_len_max   = 50;
    $module_enum    = $protocol[C_ENUM];
    foreach ($module_enum as $key => $value) {
        fwrite($file, "\n");
        $enum_note  = $value['enum_note'];
        if (is_numeric($key)) {
            fwrite($file, SPACE_04.'// '.$enum_note);
            continue;
        }
        $enum_name  = $key;
        $enum_value = $value['enum_value'];

        $dots  = generate_char($enum_len_max, strlen($enum_name.$enum_value), ' ');
        fwrite($file, SPACE_04.$key.$dots.' : '.$enum_value.',  // '.$enum_note);
    }

    fwrite($file, '
};

module.exports = ERROR_CODE;');

    fclose($file);
}
?>