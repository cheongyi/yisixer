<?php
// =========== ======================================== ====================
// @todo   写入api_out文件
function write_api_out () {
    global $protocol, $api_out_dir, $pt_file_num;

    // show_schedule(PF_PT_WRITE, PF_PT_WRITE_SCH, count(PF_PT_WRITE_SCH), false);
    $protocol_module    = $protocol[C_MODULE];
    foreach ($protocol_module as $module) {
        // 变量声明、赋值、初始化
        $module_id      = $module['module_id'];
        $module_name    = $module['module_name'];
        $module_action  = $module['action'];
        $module_class   = $module['class'];

        $module_name    = 'api_'.$module_name.'_out';
        $filename       = $module_name.'.erl';
        $file           = fopen(DIR_API_OUT.$filename, 'w');
        show_schedule(PF_PT_WRITE, $filename, $pt_file_num);

        fwrite($file, "-module ({$module_name}).");
        write_attributes($file);

        // 写入函数导出
        fwrite($file, '
-export ([');
        foreach ($module_action as $action) {
            $action_name    = $action['action_name'];
            fwrite($file, "
    {$action_name}/1,");
        }
        fwrite($file, '

    class_to_bin/2
]).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================');


        // 写入api_out函数数据封装
        foreach ($module_action as $action) {
            $action_name    = $action['action_name'];
            $action_id      = $action['action_id'];
            $action_out     = $action['action_out'];
            $action_note    = $action['action_note'];

            // 判断参数是否为空
            if (empty($action_out)) {
                fwrite($file, "
%%% @doc    {$action_note}
{$action_name} ({}) ->
    <<
           {$module_id}:16/unsigned,
        {$action_id}:16/unsigned
    >>.

");
                continue;
            }

            // 写入参数变量
            $field_name_arr = implode(',
    ', get_field_name_arr($action_out));
            fwrite($file, "
%%% @doc    {$action_note}
{$action_name} ({
    {$field_name_arr}
}) ->");

            // 写入非数值变量ToBin
            write_non_num_field_to_binary($file, $action_out);

            // 写入变量ToBin封装
            $field_bin_arr  = array();
            foreach ($action_out as $field) {
                $field_bin_arr[]    = get_field_to_binary($field);
            }
            $field_bin_arr  = implode(',
        ', $field_bin_arr);
            fwrite($file, "
    %%% ---------- ---------------------------------------- --------------------
    <<
           {$module_id}:16/unsigned,
        {$action_id}:16/unsigned,
        {$field_bin_arr}
    >>.

");
        }


        // class_to_bin
        fwrite($file, '
%%% ========== ======================================== ====================
%%% class_to_bin
%%% ========== ======================================== ====================');
        foreach ($module_class as $class_name => $class) {
            $class_note     = $class['class_note'];
            $class_field    = $class['class_field'];

            // 写入参数变量
            $field_name_arr = implode(",
    ", get_field_name_arr($class_field));
            fwrite($file, "
%%% @doc    {$class_note}
class_to_bin ({$class_name}, {
    {$field_name_arr}
}) ->");

            // 写入非数值变量ToBin
            write_non_num_field_to_binary($file, $class_field);

            // 写入变量ToBin封装
            $field_bin_arr  = array();
            foreach ($class_field as $field) {
                $field_bin_arr[]    = get_field_to_binary($field);
            }
            $field_bin_arr  = implode(',
        ', $field_bin_arr);
            fwrite($file, "
    %%% ---------- ---------------------------------------- --------------------
    <<
        {$field_bin_arr}
    >>;");
        }


        // tuple_to_bin_
        fwrite($file, '
%%% @doc    其他类|空类|通配
class_to_bin (_ClassName, _Class) ->
    <<>>.


%%% ========== ======================================== ====================
%%% tuple_to_bin_
%%% ========== ======================================== ====================');
        foreach ($module_class as $class) {
            $class_field    = $class['class_field'];
            foreach ($class_field as $field) {
                write_tuple_to_bin($file, $field);
            }
        }
        foreach ($module_action as $action) {
            $action_out     = $action['action_out'];
            foreach ($action_out as $field) {
                write_tuple_to_bin($file, $field);
            }
        }

        // end
        fwrite($file, '
%%% ========== ======================================== ====================
%%% end
%%% ========== ======================================== ====================');

        fclose($file);
    }
}


// @todo    获取字段名数组
function get_field_name_arr ($field_arr) {
    $field_name_arr = array();
    foreach ($field_arr as $field) {
        $field_line         = $field['field_line'];
        $field_name         = $field['field_name'];
        $field_name         = UNDER_LINE.$field_name.UNDER_LINE.$field_line;
        $field_name_arr[]   = $field_name;
    }

    return $field_name_arr;
}


// @todo    写入非数值字段转成binary数据格式
function write_non_num_field_to_binary ($file, $field_arr) {
    foreach ($field_arr as $field) {
        // $field_note         = $field['field_note'];
        $field_line         = $field['field_line'];
        $field_name         = $field['field_name'];
        $field_type         = $field['field_type'];
        $field_module       = $field['field_module'];
        $field_class        = $field['field_class'];
        $field_name         = UNDER_LINE.$field_name.UNDER_LINE.$field_line;
        if ($field_module) {
            $module_colon   = $field_module.':';
        }
        else {
            $module_colon   = '';
        }

        // 非数值变量ToBin
        if     ($field_type == C_STRING){
            fwrite($file, "
    %%% ---------- ---------------------------------------- --------------------
    {$field_name}_Bin     = list_to_binary({$field_name}),
    {$field_name}_BinSize = size({$field_name}_Bin),");
        }
        elseif ($field_type == C_LIST)  {
            fwrite($file, "
    %%% ---------- ---------------------------------------- --------------------
    {$field_name}_ListLen = length({$field_name}),
    BinList{$field_name}  = [");

            if ($field_class) {
                fwrite($file, "
        {$module_colon}class_to_bin({$field_class}, {$field_name}_Element)");
            }
            else {
                fwrite($file, "
        tuple_to_bin_{$field_line}({$field_name}_Element)");
            }

            fwrite($file, "
        || 
        {$field_name}_Element <- {$field_name}
    ], 
    {$field_name}_Bin     = list_to_binary(BinList{$field_name}),");
        }
        elseif ($field_type == C_TYPEOF){
            fwrite($file, "
    %%% ---------- ---------------------------------------- --------------------
    {$field_name}_Bin = {$module_colon}class_to_bin({$field_class}, {$field_name}),");
    // %% {$field_note}
        }
    }

}


// @todo    写入字段列表转成binary
function write_tuple_to_bin ($file, $field) {
    $field_type         = $field['field_type'];
    $field_class        = $field['field_class'];
    if ($field_type == C_LIST && $field_class == '') {
        $field_note     = $field['field_note'];
        $field_line     = $field['field_line'];
        $field_list     = $field['field_list'];

        // 写入参数变量
        $field_name_arr = implode(',
    ', get_field_name_arr($field_list));
        fwrite($file, "
%%% @doc    {$field_note}
tuple_to_bin_{$field_line} ({
    {$field_name_arr}
}) ->");

        // 写入非数值变量ToBin
        write_non_num_field_to_binary($file, $field_list);

        // 写入变量ToBin封装
        $field_bin_arr  = array();
        foreach ($field_list as $field) {
            $field_bin_arr[]    = get_field_to_binary($field);
        }
        $field_bin_arr  = implode(',
        ', $field_bin_arr);
        fwrite($file, "
    %%% ---------- ---------------------------------------- --------------------
    <<
        {$field_bin_arr}
    >>.

");
    }

}
// @todo    字段转成binary数据格式
function get_field_to_binary ($field) {
    $field_bin          = "";

    $field_line         = $field['field_line'];
    $field_name         = $field['field_name'];
    $field_type         = $field['field_type'];
    $field_name         = UNDER_LINE.$field_name.UNDER_LINE.$field_line;

    if     ($field_type == C_ENUM)  {
        $field_bin      = $field_name.BT_ENUM;
    }
    elseif ($field_type == C_BYTE)  {
        $field_bin      = $field_name.BT_BYTE;
    }
    elseif ($field_type == C_SHORT) {
        $field_bin      = $field_name.BT_SHORT;
    }
    elseif ($field_type == C_INT)   {
        $field_bin      = $field_name.BT_INT;
    }
    elseif ($field_type == C_LONG)  {
        $field_bin      = $field_name.BT_LONG;
    }
    elseif ($field_type == C_STRING){
        $field_bin      = $field_name.BT_BIN_SIZE.', '.$field_name.BT_STRING;
    }
    elseif ($field_type == C_TYPEOF){
        $field_bin      = $field_name.BT_TYPEOF;
    }
    elseif ($field_type == C_LIST)  {
        $field_bin      = $field_name.BT_LIST_LEN.', '.$field_name.BT_LIST;
    }

    return $field_bin;
}

?>