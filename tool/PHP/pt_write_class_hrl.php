<?php
// =========== ======================================== ====================
// @todo   写入类头文件
function write_class_hrl () {
    global $protocol, $pt_file_num;

    show_schedule(PF_PTS_WRITE, CLASS_FILE_NAME, $pt_file_num);
    $file           = fopen(CLASS_FILE, 'w');
    write_attributes_note($file);

    $class_len_max  = 30;
    $protocol_class = $protocol[C_CLASS];
    foreach ($protocol_class as $module => $module_class) {
        fwrite($file, '%%% '.$module."\n");
        foreach ($module_class as $class_name => $class) {
            fwrite($file, '-record ('.$class_name.', {');

            $old_note   = '';
            foreach ($class as $field) {
                $field_note = $field['field_note'];
                $field_name = $field['field_name'];

                $default    = get_field_default($field);
                $dots  = generate_char($class_len_max, strlen($field_name), ' ');
                fwrite($file, $old_note.'
    '.$field_name.$dots.' = '.$default);
                $old_note   = ',    % '.$field_note;
            }
            fwrite($file, '     % '.$field_note.'
}).

');
        }
        fwrite($file, "\n");
    }


    fclose($file);
}

// @todo    获取字段默认值
function get_field_default ($field) {
    $field_type         = $field['field_type'];
    $field_class        = $field['field_class'];
    $field_list         = $field['field_list'];

    $default        = '';
    if     ($field_type == C_ENUM)  {
        $default    = ' 0';
    }
    elseif ($field_type == C_BYTE)  {
        $default    = ' 0';
    }
    elseif ($field_type == C_SHORT) {
        $default    = ' 0';
    }
    elseif ($field_type == C_INT)   {
        $default    = ' 0';
    }
    elseif ($field_type == C_LONG)  {
        $default    = ' 0';
    }
    elseif ($field_type == C_STRING){
        $default    = '""';
    }
    elseif ($field_type == C_TYPEOF){
        $default    = '#'.$field_class.'{}';
    }
    elseif ($field_type == C_LIST)  {
        $default        = '[]';
    }
    else {
        $default      = 'undefined';
    }

    return $default;
}
?>