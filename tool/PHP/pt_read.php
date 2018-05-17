<?php
    /*
     *  protocol txt read
     */
// ========== ======================================== ====================
// @todo   读取协议文本
function read_protocol () {
    global $protocol_dir, $protocol, $module_enum;
    // 打开文件目录句柄
    if ($dir = opendir($protocol_dir)) {
        // 读取目录下文件名
        while (false !== ($filename = readdir($dir))) {
            // 过滤不要的文件
            if ($filename == "." || $filename == ".." || $filename == "Readme.txt") {
                continue;
            }
            elseif ($filename == "100_code.txt") {
                $protocol_module    = read_protocol_txt($filename);
                $protocol[C_ENUM]   = $module_enum;
                continue;
            }
            // elseif ($filename != "100_code.txt" && $filename != "999_test.txt") {
            //     continue;
            // }
            // echo $filename."\n";

            // 读取协议文本
            $protocol_module                = read_protocol_txt($filename);
            $module_id                      = $protocol_module['module_id'];
            $protocol[C_MODULE][$module_id] = $protocol_module;
        }
        closedir($dir);
    }
    ksort($protocol[C_MODULE]);

    $log_file       = fopen("./protocol_txt.log", w);
    fwrite($log_file, var_export($protocol, true));
    fclose($log_file);

    return $protocol;
}


// @todo   读取协议文本
function read_protocol_txt ($filename) {
    global $protocol_dir, $line;

    // 打开文件
    $file   = fopen($protocol_dir.$filename, 'r');
    $line   = 0;

    // 读取模块头部
    $protocol_module    = read_module_head($file);

    // 判断文件ID名称和模块名称ID是否一致
    $module_name        = $protocol_module['module_name'];
    $module_id          = $protocol_module['module_id'];
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


// ========== ======================================== ====================
// @todo   读取模块头部
function read_module_head ($file) {
    global $line, $brace;

    $protocol_module    = array();
    $brace  = "";
    while (!feof($file)) {
        $content    = fgets($file);
        $content    = explode("//", $content);
        $line ++;

        // 读取正文注释
        if (count($content) > 1) {
            $protocol_module['module_note'] = $protocol_module['module_note'].trim($content[1]);
        }

        // 读取正文定义
        $name_id    = str_replace(" ", "", trim($content[0]));
        // 空行
        if ($name_id == "") {
            continue;
        }
        elseif ($brace == "") {
            $name_id    = explode("=", $name_id);
            $protocol_module['module_name'] = $name_id[0];
            $protocol_module['module_id']   = $name_id[1];
            break;
        }
        else {
            die("Error '{$name_id}' on ".__FUNCTION__." at {$line}\n");
        }
    }

    return $protocol_module;
}

// @todo   读取模块主体
function read_module_body ($file, $protocol_module) {
    global $line, $brace, $note, $field_name_max;

    $protocol_module[C_CLASS]   = array();
    $protocol_module[C_ACTION]  = array();
    $brace  = C_MODULE;
    while (!feof($file)) {
        $content        = fgets($file);
        $content        = explode("//", $content);
        $line ++;

        // 读取正文注释
        if (count($content) > 1) {
            $note   = $note.trim($content[1]);
        }

        // 读取正文定义
        $class_action   = str_replace(" ", "", trim($content[0]));
        // 空行
        if ($class_action == "") {
            continue;
        }
        // 主体大括号
        elseif ($class_action == "{" && $brace == C_MODULE) {
            continue;
        }
        elseif ($class_action == "}" && $brace == C_MODULE) {
            break;
        }
        // 类声明或函数定义头部
        elseif ($brace == C_MODULE) {
            $class_action   = explode("=", $class_action);
            if (count($class_action) == 1) {
                if (substr_compare($class_action[0], C_CLASS, 0, C_CLASS_LEN) === 0) {
                    $module_class   = array();
                    $field_name_max = 0;
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
                    $class_field                    = read_class($file);
                    $module_class['class_field']    = $class_field;
                    $module_class['field_name_max'] = $field_name_max;
                    $protocol_module[C_CLASS][$class_name]  = $module_class;
                }
            }
            elseif (count($class_action) == 2) {
                $module_action      = array();
                $field_name_max     = 0;
                $action_name        = $class_action[0];
                $action_id          = $class_action[1];
                $module_action['action_id']         = $action_id;
                $module_action['action_note']       = get_note();
                $module_action                      = read_action($file, $module_action);
                $module_action['field_name_max']    = $field_name_max;
                $protocol_module[C_ACTION][$action_name]    = $module_action;
            }
        }
        else {
            die("Error '{$class_action}' on ".__FUNCTION__." at {$line}\n");
        }
    }

    return $protocol_module;
}


// ========== ======================================== ====================
// @todo   读取模块类声明
function read_class ($file) {
    global $line, $brace, $note;
    $class_field    = array();
    $field          = array();
    $brace          = C_CLASS;
    while (!feof($file)) {
        $content    = fgets($file);
        $content    = explode("//", $content);
        $line ++;

        // 读取正文注释
        if (count($content) > 1) {
            $note   = $note.trim($content[1]);
        }

        // 读取正文定义
        $field_def  = str_replace(" ", "", trim($content[0]));
        // 空行
        if ($field_def == "") {
            continue;
        }
        // 类声明大括号
        elseif ($field_def == "{" && $brace == C_CLASS) {
            continue;
        }
        elseif ($field_def == "}" && $brace == C_CLASS) {
            $brace  = C_MODULE;
            break;
        }
        // 类声明字段
        elseif ($brace == C_CLASS) {
            $field          = analysis_field_def($file, $field_def);
            $class_field[]  = $field;
        }
        else {
            die("Error '{$field_def}' on ".__FUNCTION__." at {$line}\n");
        }
    }

    return $class_field;
}

// @todo   读取模块函数定义
function read_action ($file, $module_action) {
    global $line, $brace, $note;

    $brace  = C_ACTION;
    while (!feof($file)) {
        $content    = fgets($file);
        $content    = explode("//", $content);
        $line ++;

        // 读取正文注释
        if (count($content) > 1) {
            $note   = $note.trim($content[1]);
        }

        // 读取正文定义
        $field_def  = str_replace(" ", "", trim($content[0]));
        // 空行
        if ($field_def == "") {
            continue;
        }
        // 函数定义大括号
        elseif ($field_def == "{"    && $brace == C_ACTION) {
            $brace  = C_ACTION_IN;
            continue;
        }
        elseif ($field_def == "}"    && $brace == C_ACTION) {
            $brace  = C_MODULE;
            break;
        }
        elseif ($field_def == "in"   && $brace == C_ACTION_IN) {
            $action_field   = read_action_in_out($file);
            $module_action[C_ACTION_IN]     = $action_field;
        }
        elseif ($field_def == "out"  && $brace == C_ACTION_OUT) {
            $action_field   = read_action_in_out($file);
            $module_action[C_ACTION_OUT]    = $action_field;
        }
        else {
            die("Error '{$field_def}' on ".__FUNCTION__." at {$line}\n");
        }
    }

    return $module_action;
}

// @todo   读取模块函数in/out定义
function read_action_in_out ($file) {
    global $line, $brace, $note;
    $action_field   = array();
    $field          = array();
    while (!feof($file)) {
        $content    = fgets($file);
        $content    = explode("//", $content);
        $line ++;

        // 读取正文注释
        if (count($content) > 1) {
            $note   = $note.trim($content[1]);
        }

        // 读取正文定义
        $field_def  = str_replace(" ", "", trim($content[0]));
        // 空行
        if ($field_def == "") {
            continue;
        }
        // 函数in定义大括号
        elseif ($field_def == "{" && $brace == C_ACTION_IN) {
            continue;
        }
        elseif ($field_def == "}" && $brace == C_ACTION_IN) {
            $brace  = C_ACTION_OUT;
            break;
        }
        // 函数out定义大括号
        elseif ($field_def == "{" && $brace == C_ACTION_OUT) {
            continue;
        }
        elseif ($field_def == "}" && $brace == C_ACTION_OUT) {
            $brace  = C_ACTION;
            break;
        }
        // 函数in/out内字段定义
        elseif ($brace == C_ACTION_IN || $brace == C_ACTION_OUT) {
            $field          = analysis_field_def($file, $field_def);
            $action_field[] = $field;
        }
        else {
            die("Error '{$field_def}' on ".__FUNCTION__." at {$line}\n");
        }
    }

    return $action_field;
}


// @todo   读取枚举
function read_enum ($file, $old_brace) {
    global $line, $brace, $note, $module_enum;
    $brace  = C_ENUM;
    while (!feof($file)) {
        $content    = fgets($file);
        $content    = explode("//", $content);
        $line ++;

        // 读取正文注释
        if (count($content) > 1) {
            $note   = $note.trim($content[1]);
        }

        // 读取正文定义
        $enum_def   = str_replace(" ", "", trim($content[0]));
        // 空行
        if ($enum_def == "") {
            if (count($content) > 1) {
                $enum               = array();
                $enum['enum_note']  = get_note();
                $module_enum[$line] = $enum;
            }
            continue;
        }
        // 枚举定义大括号
        elseif ($enum_def == "{" && $brace == C_ENUM) {
            continue;
        }
        elseif ($enum_def == "}" && $brace == C_ENUM) {
            $brace  = $old_brace;
            break;
        }
        elseif ($brace == C_ENUM) {
            $enum       = array();
            $enum_def   = explode("=", $enum_def);
            $enum_value = 0;
            $enum_name  = $enum_def[0];
            if (count($enum_def) > 1) {
                $enum_value     = $enum_def[1];
            }

            // 判断是否重复定义枚举值
            if ($module_enum[$enum_name]['enum_value']) {
                $old_enum_value = $module_enum[$enum_name]['enum_value'];
                if ($enum_value == 0) {
                    $enum_value = $old_enum_value;
                }
                elseif ($old_enum_value > 0 && $old_enum_value != $enum_value) {
                    die("
Error module enum({$enum_name}) \t({$enum_value}) already exist {$old_enum_value}
");
                }
            }

            $enum['enum_note']  = get_note();
            $enum['enum_line']  = $line;
            $enum['enum_value'] = $enum_value;
            $module_enum[$enum_name]    = $enum;
        }
        else {
            die("Error '{$enum_def}' on ".__FUNCTION__." at {$line}\n");
        }
    }
}

// @todo   读取列表
function read_list ($file, $old_brace) {
    global $line, $brace, $note;

    $list_field     = array();
    while (!feof($file)) {
        $content    = fgets($file);
        $content    = explode("//", $content);
        $line ++;

        // 读取正文注释
        if (count($content) > 1) {
            $note   = $note.trim($content[1]);
        }

        // 读取正文定义
        $list_def   = str_replace(" ", "", trim($content[0]));
        // 空行
        if ($list_def == "") {
            continue;
        }
        // 列表大括号
        elseif ($list_def == "{" && $brace == $old_brace) {
            $brace  = C_LIST;
        }
        elseif ($list_def == "}" && $brace == C_LIST) {
            $brace  = $old_brace;
            break;
        }
        // 列表内字段定义
        elseif ($brace == C_LIST) {
            $field          = analysis_field_def($file, $list_def);
            $list_field[]   = $field;
        }
        // 空行
        else {
            die("Error '{$list_def}' on ".__FUNCTION__." at {$line}\n");
        }
    }

    return $list_field;
}


// ========== ======================================== ====================
// @todo   解析字段定义
function analysis_field_def ($file, $field_def) {
    global $line, $brace, $note, $field_name_max;

    $field_def      = explode(":", $field_def);
    $field_name     = $field_def[0];
    $field_rest     = explode("<", $field_def[1]);
    $field_type     = $field_rest[0];
    $field_module   = "";
    $field_class    = "";
    // 判断是否引用类
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

    $field['field_note']    = get_note();
    $field['field_line']    = $line;
    $field['field_name']    = $field_name;
    $field['field_type']    = $field_type;
    $field['field_module']  = $field_module;
    $field['field_class']   = $field_class;
    $field_name_len         = strlen($field_name.$line) + 2;
    if ($field_name_len > $field_name_max) {
        $field_name_max     = $field_name_len;
    }
    // 判断字段类型是否枚举
    $field_list = array();
    if ($field_type == "enum") {
        read_enum($file, $brace);
    }
    elseif ($field_type == "list" && $field_class == "") {
        $field_list     = read_list($file, $brace);
    }

    $field['field_list']    = $field_list;

    return $field;
}

// @todo   获取注释
function get_note () {
    global $note;

    $note_tmp   = $note;
    $note       = "";

    return $note_tmp;
}
?>