<?php
// =========== ======================================== ====================
// @todo   数据库枚举
function db_enum() {
    global $mysqli, $enum_table;

    show_schedule(PF_DB_WRITE, PF_DB_WRITE_SCH, count(PF_DB_WRITE_SCH), true);
    $main_stime = microtime(true);

    $file       = fopen(GAME_DB_HRL_FILE, 'w');

    write_attributes_note($file);
    fwrite($file, '
%%% ========== ======================================== ====================
%%% database table rows to define
%%% ========== ======================================== ====================
-define (FRAG_ID_LIST, [
    00, 01, 02, 03, 04, 05, 06, 07, 08, 09,
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
    30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
    40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
    50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
    60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
    70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
    80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
    90, 91, 92, 93, 94, 95, 96, 97, 98, 99
]).
');
    foreach ($enum_table as $table_name => $table) {
        $fields     = array(
            'id', 'sign', 'cname'
        );
        $enum_note  = $table['note'];
        $enum_prefix= $table['prefix'];
        fwrite($file, "%%% {$table_name}\n");
        $table_data = get_table_data($mysqli, $table_name, $fields);
        foreach ($table_data as $row) {
            $id     = $row['id'];
            $sign   = $row['sign'];
            $cname  = $row['cname'];
            $dots   = generate_char(50, strlen($sign.$id), ' ');
            fwrite($file, "-define ({$enum_prefix}"
                .strtoupper($sign)
                .",{$dots}{$id}).    %% {$enum_note} - {$cname}\n");
        }
        fwrite($file, "\n");
    }

    fclose($file);
}


// @todo   数据库记录
function db_record () {
    global $tables_info, $tables_fields_info;

    show_schedule(PF_DB_WRITE, PF_DB_WRITE_SCH, count(PF_DB_WRITE_SCH), true);
    $file       = fopen(GAME_DB_HRL_FILE, 'a');

    fwrite($file, '
%%% ========== ======================================== ====================
%%% database table create to record
%%% ========== ======================================== ====================
');
    $tables = $tables_info['TABLES'];
    foreach ($tables as $table_name) {
        $fields_info    = $tables_fields_info[$table_name];
        $fields         = $fields_info['FIELDS'];
        $primary        = $fields_info['PRIMARY'];
        $primary_arr    = implode(', ', $primary);
        fwrite($file, "-record (pk_{$table_name}, {{$primary_arr}}).
-record ({$table_name}, {
    row_key,");
        foreach ($fields as $field) {
            $field_name     = $field['COLUMN_NAME'];
            $field_key      = $field['COLUMN_KEY'];
            $field_type     = $field['DATA_TYPE'];
            $field_default  = $field['COLUMN_DEFAULT'];
            $field_comment  = $field['COLUMN_COMMENT'];
            $dots = generate_char(20, strlen($field_name), ' ');
            fwrite($file, '
    '.$field_name.$dots);
            $field_default_len = strlen($field_default);
            if ($field_key == 'PRI') {
                fwrite($file, '= null');
                $field_default_len = 4;
            }
            elseif ($field_default == '') {
                fwrite($file, "= \"\"");
                $field_default_len = 2;
            }
            elseif ($field_type == 'tinyint' || $field_type == 'int' || $field_type == 'bigint') {
                fwrite($file, "= {$field_default}");
            }
            elseif ($field_type == 'float') {
                fwrite($file, "= {$field_default}");
            }
            else {
                fwrite($file, '= null');
                $field_default_len = 4;
            }
            $dots = generate_char(10, $field_default_len, ' ');
            fwrite($file, ",{$dots}%% {$field_comment}");
        }
        fwrite($file, "
    row_ver             = 0
}).\n\n");
    }

    fclose($file);
}

?>