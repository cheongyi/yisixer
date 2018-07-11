<?php
    /*
     *  生成客户端接口
     */

// 写入客户端协议包
function write_client_action () {
    global $protocol, $pt_file_num;

    $file   = fopen(CLIENT_ACTION_FILE, 'w');

    fwrite($file, '
/*
*  消息统一
*/

class Actions 
{
    constructor() 
    {
        this.dispatchers = new Map();
    }

    register(dispat)
    {
        this.dispatchers.set("action"+this.dispatchers.size,dispat);
    }

    clearDispatcher()
    {
        this.dispatchers.length = 0;    
    }

    dispatch(act)
    {
        for(let [actopnName, funct] of this.dispatchers){
            funct(act);
        }
    }
//-----------------------------------------------万恶的分割线---------------------------------------------------------------------------//
');

    // 写入协议接口
    $protocol_module    = $protocol[C_MODULE];
    foreach ($protocol_module as $module) {
        $module_name    = $module['module_name'];
        $module_action  = $module['action'];
        $cuts           = generate_char(20, strlen($module_name), SYMBOL_ASSIGN);
        fwrite($file, "
    // ====== {$module_name} {$cuts}");
        foreach ($module_action as $action) {
            $action_id      = $action['action_id'];
            $action_name    = $action['action_name'];
            $action_note    = $action['action_note'];
            $action_in      = $action['action_in'];
            $field_name_max = $action['field_name_max'];
            $action_name_fi = str_replace('_', '', ucwords($action_name, '_'));
            $action_name    = lcfirst(str_replace('_', '', ucwords($action_name, '_')));
            $field_name_arr = array();
            foreach ($action_in as $field) {
                $field_name         = $field['field_name'];
                $field_name         = lcfirst(str_replace('_', '', ucwords($field_name, '_')));
                $field_name_arr[]   = '_'.$field_name;
            }
            $field_arr  = implode(', ', $field_name_arr);
            show_schedule(PF_PTC_WRITE, 'Action : '.$action_name, $pt_file_num);
            fwrite($file, "
    // {$action_note}
    {$action_name}({$field_arr}) {
        this.dispatch({
            actionType : {$action_id},");
            // 
            foreach ($action_in as $field) {
                $field_name     = $field['field_name'];
                $field_name     = lcfirst(str_replace('_', '', ucwords($field_name, '_')));
                $dots           = generate_char($field_name_max, strlen($field_name), SPACE_ONE);
                fwrite($file, "
            {$field_name}{$dots} : _{$field_name},");
            }
            fwrite($file, "
        });
    }
");
        }
    }



    // 以下为固定内容
    fwrite($file, '
};

module.exports = new Actions();
');

    fclose($file);
}
?>