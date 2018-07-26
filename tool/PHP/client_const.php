<?php
// =========== ======================================== ====================
// @todo   写入客户端模版数据
function write_client_const () {
    global $mysqli, $db_file_num;

    $const_len_max  = 40;
    $data_len_max   = 10;
    $table_name = 'constant';
    $sql        = "SELECT * FROM {$table_name}";

    show_schedule(PF_DBC_WRITE, 'Table : '.$table_name, $db_file_num);
    $file       = fopen(DIR_CLIENT_TABLES.$table_name.'.js', 'w');
    fwrite($file, "
const CONST = {");

    $result             = $mysqli->query($sql, MYSQLI_USE_RESULT);
    while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
        $sign   = $row['sign'];
        $data   = $row['data'];
        $cname  = $row['cname'];
        $sign_up    = strtoupper($sign);

        $sign_dots  = generate_char($const_len_max, strlen($sign_up), ' ');
        $data_dots  = generate_char($data_len_max,  strlen($data), ' ');
        fwrite($file, "
    {$sign_up}{$sign_dots}: {$data},{$data_dots}// {$cname}");

    }

    fwrite($file, "
};

module.exports = CONST;");

    fclose($file);
}
?>