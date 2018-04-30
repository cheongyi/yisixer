<?php
// =========== ======================================== ====================
// @todo   获取表数据
function get_table_data ($mysqli, $table_name, $fields) {
    $fields_arr = implode("`, `", $fields);
    $select_sql = "SELECT `{$fields_arr}` FROM `{$table_name}`;";
    // echo $select_sql;
    $result     = $mysqli->query($select_sql, MYSQLI_USE_RESULT);
    
    $table_data = array();
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $values = array();
    
        foreach ($fields as $field) {
            $values[$field] = $mysqli->real_escape_string($row[$field]);
        }
        
        $table_data[] = $values;
    }

    $result->close();
    return $table_data;
}


// @todo   获取对应数据库的所有表
function get_tables_info () {
    global $schema, $db_name;
    
    $sql            = "SELECT `TABLE_NAME` FROM `TABLES` WHERE `TABLE_SCHEMA` = '{$db_name}';";
    $result         = $schema->query($sql);
    $tables_info    = array();
    $name_len       = 0;
    
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $table_name              = $row['TABLE_NAME'];
        // 过滤掉不需要的表
        if ($table_name == "db_version") {
            // continue;
        }
        $tables_info['TABLES'][] = $table_name;
        $name_len                = max($name_len, strlen($table_name));
    }
    $tables_info['NAME_LEN_MAX'] = $name_len;
    
    $result->close();
    
    return $tables_info;
}

// @todo   获取所有表字段信息
function get_tables_fields_info () {
    global $tables_info;
    $tables_fields_info = array();
    foreach ($tables_info['TABLES'] as $table_name) {
        $fields = get_table_fields_info($table_name);
        $tables_fields_info[$table_name] = $fields;
    }
    return $tables_fields_info;
}

// @todo   获取表字段信息
function get_table_fields_info ($table_name) {
    global $schema, $db_name;
    
    $sql        = "SELECT 
            `COLUMN_NAME`, `COLUMN_KEY`, `DATA_TYPE`, `EXTRA`, `COLUMN_DEFAULT`, `IS_NULLABLE`, `COLUMN_COMMENT`
        FROM  `COLUMNS`
        WHERE `TABLE_SCHEMA` = '$db_name' AND `TABLE_NAME` = '$table_name'";
    $result     = $schema->query($sql);
    $fields_info= array();
    $name_len   = 0;
    $primary    = array();
    $auto_increment     = "";
    $frag_field    = "";
    
    while($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $field_name             = $row['COLUMN_NAME'];
        $field_key              = $row['COLUMN_KEY'];
        $field_extra            = $row['EXTRA'];
        $name_len               = max($name_len, strlen($field_name));
        if ($field_key == "PRI") {
            $primary[]  = $field_name;
        }
        if ($field_extra == "auto_increment") {
            $auto_increment     = $field_name;
        }
        if ($field_name == "player_id") {
            $frag_field = $field_name;
        }
        $fields_info['FIELDS'][$field_name] = $row;
    }
    $player_start   = "player";
    if (substr_compare($table_name, $player_start, 0, strlen($player_start)) === 0) {
        $is_temp_table  = false;
        $log_end        = "_log";
        if (substr_compare($table_name, $log_end, -strlen($log_end)) === 0) {
            $is_log_table   = true;
        } 
        else {
            $is_log_table   = false;
        }
    }
    else {
        $is_temp_table  = true;
        $is_log_table   = false;
    }
    $fields_info['NAME_LEN_MAX']    = $name_len;
    $fields_info['PRIMARY']         = $primary;
    $fields_info['AUTO_INCREMENT']  = $auto_increment;
    $fields_info['FRAG_FIELD']      = $frag_field;
    $fields_info['IS_TEMP_TABLE']   = $is_temp_table;
    $fields_info['IS_LOG_TABLE']    = $is_log_table;
    
    $result->close();
    return $fields_info;
}


// @todo   生成填补字符
function generate_char ($max_length, $length, $char) {
    $space      = "";
    $fill_len   = $max_length - $length;
    for ($i = 0; $i < $fill_len; $i ++) {
        $space .= $char;
    }
     
    return $space;
}


// @todo    写入属性注释
function write_attributes_note($file) {
    $year   = date("Y");
    $ymd    = date("Y, m, d");
    fwrite($file, "
%%% ========== ======================================== ====================
%%% -copyright  (\"Copyright © 2017-$year YiSiXEr\").
%%% -author     (\"CHEONGYI\").
%%% -date       ({{$ymd}}).
%%% -vsn        (\"1.0.0\").
%%% ========== ======================================== ====================
");
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


// @todo   写入 FieldValueBin = type_to_bin(FieldValue),
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