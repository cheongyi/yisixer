<?php
// =========== ======================================== ====================
// 数据库枚举
function db_enum() {
    global $mysqli, $enum_table, $game_db_hrl_file;

    $main_stime = microtime(true);

    $file       = fopen($game_db_hrl_file, 'w');

// -date       ({".date("Y, m, d")."}).
// -copyright  (\"Copyright © ".date("Y")." YiSiXEr\").
// -copyright  (\"Copyright © 2018 YiSiXEr\").
// -date       ({2018, 04, 08}).
    $year   = date("Y");
    $ymd    = date("Y, m, d");
    fwrite($file, "
-copyright  (\"Copyright © 2017-$year YiSiXEr\").
-author     (\"CHEONGYI\").
-date       ({{$ymd}}).

%%% ========== ======================================== ====================
%%% database table rows to define
%%% ========== ======================================== ====================
");
    foreach ($enum_table as $table) {
        $fields     = array();
        $fields[]   = $table['id'];
        $fields[]   = $table['sign'];
        $fields[]   = $table['cname'];
        $table_name = $table['tname'];
        $table_note = $table['note'];
        fwrite($file, "%%% $table_name\n");
        $table_data = get_table_data($mysqli, $table_name, $fields);
        foreach ($table_data as $row) {
            $dots = generate_char(50, strlen($row[$table['sign']].$row[$table['id']]), ' ');
            fwrite($file, "-define("
                .$table['prefix'].strtoupper($row[$table['sign']])
                .",$dots"
                .$row[$table['id']]
                .").    %% $table_note - ".$row[$table['cname']]
                ."\n");
        }
        fwrite($file, "\n");
    }

    fclose($file);
}


// 数据库记录
function db_record () {
    global $tables, $tables_fields, $game_db_hrl_file;

    $file       = fopen($game_db_hrl_file, 'a');

    fwrite($file, "
%%% ========== ======================================== ====================
%%% database table create to record
%%% ========== ======================================== ====================
");

    foreach ($tables as $table_name) {
        $fields = $tables_fields[$table_name];
        fwrite($file, "-record($table_name, {
    row_key,");
        foreach ($fields as $field) {
            $field_name     = $field['COLUMN_NAME'];
            $field_type     = $field['DATA_TYPE'];
            $field_default  = $field['COLUMN_DEFAULT'];
            $field_comment  = $field['COLUMN_COMMENT'];
            $dots = generate_char(20, strlen($field_name), ' ');
            fwrite($file, "
    ".$field_name.$dots);
            $field_default_len = strlen($field_default);
            if ($field_default == "NULL" || $field_default == "") {
                $field_default_len = 4;
                fwrite($file, "= null");
            }
            elseif ($field_type == "tinyint" || $field_type == "int" || $field_type == "bigint" || $field_type == "float") {
                fwrite($file, "= $field_default");
            }
            elseif ($field_type == "float") {
                fwrite($file, "= $field_default");
            }
            else {
                fwrite($file, "= \"$field_default\"");
            }
            $dots = generate_char(10, $field_default_len, ' ');
            fwrite($file, ",$dots%% $field_comment");
        }
        fwrite($file, "
    row_ver             = 0
}).\n\n");
    }

    fclose($file);
}

?>