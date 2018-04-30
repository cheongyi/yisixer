<?php
// =========== ======================================== ====================
// @todo   写入api_out文件
function write_api_out () {
    global $protocol, $api_out_dir;

    foreach ($protocol as $module_name => $protocol_module) {
        if ($module_name == "enum") {
            continue;
        }

        $module_name    = "api_".$module_name."_out.erl";
        $file           = fopen($api_out_dir.$module_name, 'w');

        fwrite($file, "-module ({$module_name}).");
        write_attributes($file);

        fclose($file);
    }
}
?>