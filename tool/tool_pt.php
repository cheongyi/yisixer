<?php
    /*
     *  protocol txt
     */

    // 设定用于所有日期时间函数的默认时区
    date_default_timezone_set("Asia/Shanghai");

    // 加载配置文件
    // require_once 'conf.php';

    // 目录路径
    // $protocol_dir       = "../../cog/protocol/";
    $protocol_dir       = "../server/protocol/";

    // 常量定义
    define("C_MODULE",      "module");
    define("C_CLASS",       "class");
    define("C_ACTION",      "action");
    define("C_MODULE_LEN",  strlen(C_MODULE));
    define("C_CLASS_LEN",   strlen(C_CLASS));
    define("C_ACTION_LEN",  strlen(C_ACTION));

    // 变量初始化
    $protocol   = array();
    $brace      = C_MODULE;
    $note       = "";
    if ($dir = opendir($protocol_dir)) {
        while (false !== ($filename = readdir($dir))) {
            if ($filename == "." || $filename == ".." || $filename == "Readme.txt") {
                continue;
            }
            elseif ($filename != "100_test.txt") {
                continue;
            }
            echo $filename."\n";

            $protocol_module        = read_protocol_txt($filename);
            $module_name            = $protocol_module['module_name'];
            $protocol[$module_name] = $protocol_module;
        }
        closedir($dir);
    }

    print_r($protocol);


// 读取协议文本
function read_protocol_txt ($filename) {
    global $protocol_dir;

    $file   = fopen($protocol_dir.$filename, 'r');

    // 读取模块头部
    $protocol_module    = read_module_head($file);
    $module_name        = $protocol_module['module_name'];
    $module_id          = $protocol_module['module_id'];
    // 判断文件ID名称和模块名称ID是否一致
    if ("{$module_id}_{$module_name}.txt" != $filename) {
        $id_name    = explode("_", str_replace(".txt", "", $filename), 2);
        $id         = $id_name[0];
        $name       = $id_name[1];
        die("
Error module name({$module_name}) \tid({$module_id}) in {$filename}
Maybe is was name({$name}) \tid({$id})
");
    }

    // 读取模块主体
    $protocol_module    = read_module_body($file, $protocol_module);

    fclose($file);

    return $protocol_module;
}


// 读取模块头部
function read_module_head ($file) {
    $protocol_module    = array();
    while (!feof($file)) {
        $line   = fgets($file);
        $line   = explode("//", $line);

        if (count($line) > 1) {
            $protocol_module['module_note'] = $protocol_module['module_note'].trim($line[1]);
        }

        $name_id    = str_replace(" ", "", trim($line[0]));
        if ($name_id == "") {
            continue;
        }
        elseif ($name_id == "{") {
            break;
        }
        else {
            $name_id    = explode("=", $name_id);
            $protocol_module['module_name'] = $name_id[0];
            $protocol_module['module_id']   = $name_id[1];
        }
    }

    return $protocol_module;
}


// 读取模块主体
function read_module_body ($file, $protocol_module) {
    global $brace, $note;

    while (!feof($file)) {
        $line   = fgets($file);
        $line   = explode("//", $line);

        if (count($line) > 1) {
            $note = $note.trim($line[1]);
        }

        $class_action    = str_replace(" ", "", trim($line[0]));
        if ($class_action == "") {
            continue;
        }
        elseif ($class_action == "{" && $brace = C_CLASS) {
            $class_field   = read_class_field($file);
            $protocol_module[C_CLASS][$class_name]['class_field']       = $class_field;
        }
        elseif ($class_action == "}" && $brace = C_CLASS) {
            $brace  = C_MODULE;
            continue;
        }
        elseif ($class_action == "}" && $brace = C_ACTION) {
            $brace  = C_MODULE;
            continue;
        }
        elseif ($class_action == "{" && $brace = C_ACTION) {
            $action_field   = read_class_field($file);
            $protocol_module[C_ACTION][$action_name]['action_field']    = $action_field;
        }
        elseif ($class_action == "}" && $brace = C_MODULE) {
            break;
        }
        else {
            $class_action       = explode("=", $class_action);
            if (count($class_action) == 1) {
                if (substr_compare($class_action[0], C_CLASS, 0, C_CLASS_LEN) === 0) {
                    $brace  = C_CLASS;
                    $module_class   = array();
                    $class_head     = explode(":", substr($class_action[0], C_CLASS_LEN));
                    $class_name     = $class_head[0];
                    $extend_module  = "";
                    $extend_class   = "";
                    if (count($class_head) > 1) {
                        $extend     = explode(".", $class_head[1]);
                        if (count($extend) > 1) {
                            $extend_module  = $extend[0];
                            $extend_class   = $extend[1];
                        }
                        else {
                            $extend_class   = $extend[0];
                        }
                    }
                    $module_class['extend_module']  = $extend_module;
                    $module_class['extend_class']   = $extend_class;
                    $module_class['class_note']     = get_note();
                    $protocol_module[C_CLASS][$class_name]   = $module_class;
                }
            }
            // elseif (count($class_action) == 2) {
            //     $brace = C_ACTION;
            //     read_action();
            // }
        }
    }

    return $protocol_module;
}


// 读取模块类声明
function read_class_field ($file) {
    global $brace, $note;
    $class_field    = array();
    $field          = array();
    while (!feof($file)) {
        $line       = fgets($file);
        $line       = explode("//", $line);

        if (count($line) > 1) {
            $note   = $note.trim($line[1]);
        }

        $field_def  = str_replace(" ", "", trim($line[0]));
        if ($field_def == "") {
            continue;
        }
        elseif ($field_def == "}" && $brace = C_CLASS) {
            $brace  = C_MODULE;
            break;
        }
        else {
            $field  = analysis_field_def($file, $field_def);
            $field['field_note']    = get_note();
            $class_field[]          = $field;

        }
    }

    return $class_field;
}

// 解析字段定义
function analysis_field_def ($file, $field_def) {
    $field_def      = explode(":", $field_def);
    $field_name     = $field_def[0];
    $field_rest     = explode("<", $field_def[1]);
    $field_type     = $field_rest[0];
    $field_module   = "";
    $field_class    = "";
    if (count($field_rest) > 1) {
        $field_extend   = explode(".", $field_rest[1]);
        if (count($field_extend) > 1) {
            $field_module   = $field_extend[0];
            $field_class    = str_replace(">", "", $field_extend[1]);
        }
        else {
            $field_class    = str_replace(">", "", $field_rest[1]);
        }
    }

    // 判断字段类型是否枚举
    if ($field_type == "enum") {
        # code...
    }

    $field['field_name']    = $field_name;
    $field['field_type']    = $field_type;
    $field['field_module']  = $field_module;
    $field['field_class']   = $field_class;

    return $field;
}

// 获取注释
function get_note () {
    global $note;

    $note_tmp   = $note;
    $note       = "";

    return $note_tmp;
}
?>