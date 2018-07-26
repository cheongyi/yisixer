<?php
// =========== ======================================== ====================
// @todo   写入客户端模版数据
function write_client_table () {
    global $mysqli, $tables_fields_info, $sql_list, $db_file_num;

    $new_line   = 4;

    foreach ($sql_list as $table_name => $sql) {
        show_schedule(PF_DBC_WRITE, 'Table : '.$table_name, $db_file_num);
        $file       = fopen(DIR_CLIENT_TABLES.$table_name.'.js', 'w');
        fwrite($file, "
export const {$table_name} = {");

        $fields_info        = $tables_fields_info[$table_name];
        $fields             = $fields_info['FIELDS'];
        $field_name_len_max = $fields_info['NAME_LEN_MAX'];
        $field_num          = count($fields);
        $result             = $mysqli->query($sql, MYSQLI_USE_RESULT);
        while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
            if ($row['id']) {
                $key    = $row['id'];
            }
            elseif ($row['key_id']) {
                $key    = $row['key_id'];
            }
            else {
                $key    = current($row);
            }

            fwrite($file, "
    {$key}\t: {");

            foreach ($row as $field_name => $field_value) {
                $field_type = $fields[$field_name]['DATA_TYPE'];
                if ($field_type == 'tinyint' || $field_type == 'int' || $field_type == 'bigint' || $field_type == 'float') {
                    $field_value    = $field_value;
                }
                else {
                    $field_value    = '\''.$field_value.'\'';
                }

                if ($field_num > $new_line) {
                    $dots   = generate_char($field_name_len_max, strlen($field_name), ' ');
                    fwrite($file, "
        '{$field_name}'{$dots} : {$field_value},");
                }
                else {
                    fwrite($file, "'{$field_name}' : {$field_value},\t");
                }
            }

            if ($field_num > $new_line) {
            fwrite($file, "
    },");
            }
            else {
            fwrite($file, "},");
            }

        }
        fwrite($file, "
};");

        fclose($file);
    }
}
?>