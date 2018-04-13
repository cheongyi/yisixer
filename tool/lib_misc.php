<?php
// =========== ======================================== ====================
// @todo   生成填补字符
function generate_char ($max_length, $length, $char) {
    $space      = "";
    $fill_len   = $max_length - $length;
    for ($i = 0; $i < $fill_len; $i ++) {
        $space .= $char;
    }
     
    return $space;
}


// @todo    写入属性
function write_attributes($file) {
    $year   = date("Y");
    $ymd    = date("Y, m, d");
    fwrite($file, "

%%% @doc    

-copyright  (\"Copyright © 2017-$year YiSiXEr\").
-author     (\"CHEONGYI\").
-date       ({{$ymd}}).
-vsn        (\"1.0.0\").
");
}


// 写入 FieldValueBin = type_to_bin(FieldValue),
function write_type_to_bin ($file, $table_name, $field, $name_len_max) {
    $field_name     = $field['COLUMN_NAME'];
    $field_type     = $field['DATA_TYPE'];
    $field_name_up  = ucfirst($field_name);

    if ($field_type == "tinyint" || $field_type == "int" || $field_type == "bigint") {
        $type_to_bin    = "?INT_TO_BIN";
    }
    elseif ($field_type == "float") {
        $type_to_bin    = "?REL_TO_BIN";
    }
    else {
        $type_to_bin    = "?LST_TO_BIN";
    }

    $dots = generate_char($name_len_max, strlen($field_name), ' ');
    fwrite($file, "
    {$field_name_up}{$dots} = {$type_to_bin}(Record #{$table_name}.{$field_name}),");
}

?>