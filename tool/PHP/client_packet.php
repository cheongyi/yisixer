<?php
    /*
     *  生成客户端协议包
     */

// 写入客户端协议包
function write_client_packet () {
    global $protocol, $pt_file_num;

    $file   = fopen(CLIENT_PACKET_FILE, 'w');

    fwrite($file, '
/*
 *  消息协议，数据构造
 */
\'use strict\';
const PacketGen     = require(\'../util/packetGen\');
const DataBuffer    = require(\'../util/dataBuffer\');
const ERROR_CODE    = require(\'./errorCode\');
const PakoInflate   = require(\'pako/lib/inflate\');
require(\'core-js\');

// type alias|类型别名
const u8 = \'uint8\', u16 = \'uint16\', u32 = \'uint32\', str = \'string\', f64 = \'float64\';

// 协议接口ID常量
export const PACKET_ID = {');

    // 写入协议接口ID常量
    $protocol_module    = $protocol[C_MODULE];
    foreach ($protocol_module as $module) {
        $module_name    = $module['module_name'];
        $module_action  = $module['action'];
        $cuts           = generate_char(20, strlen($module_name), SYMBOL_ASSIGN);
        fwrite($file, "
    // ====== {$module_name} {$cuts}");
        foreach ($module_action as $action) {
            $action_name    = $action['action_name'];
            $action_note    = $action['action_note'];
            $action_id      = $action['action_id'];
            $dots           = generate_char(40, strlen($action_name), SPACE_ONE);
            $action_name_up = strtoupper($action_name);
            show_schedule(PF_PTC_WRITE, 'ActionId : '.$action_id, $pt_file_num);
            fwrite($file, "
    CMSG_{$action_name_up}{$dots} : {$action_id},  // {$action_note}");
        }
    }
    fwrite($file, '
};


// 客户端 to  服务端 -- 协议体
export const CLIENT_PACKET_LAYOUTS = {');


    foreach ($protocol_module as $module) {
        $module_name    = $module['module_name'];
        $module_action  = $module['action'];
        $cuts           = generate_char(20, strlen($module_name), SYMBOL_ASSIGN);
        fwrite($file, "
    // ====== {$module_name} {$cuts}");
        foreach ($module_action as $action) {
            $action_name    = $action['action_name'];
            $action_note    = $action['action_note'];
            $action_in      = $action['action_in'];
            $field_name_max = $action['field_name_max'];
            $action_name_up = strtoupper($action_name);
            $action_name_fi = str_replace('_', '', ucwords($action_name, '_'));
            // object
            show_schedule(PF_PTC_WRITE, 'C=>S Object : '.$action_name_fi, $pt_file_num);
            $layout         = get_field_layout($module_name, $action_in, $field_name_max, SPACE_08);
            fwrite($file, "
    // {$action_note}
    {$action_name_fi} : {
        id      : PACKET_ID.CMSG_{$action_name_up},{$layout}
    },
");
        }
    }



    fwrite($file, '
};

// 服务端 to 客户端 -- 协议体
export const RESP_PACKET_LAYOUTS = {');


    foreach ($protocol_module as $module) {
        $module_name    = $module['module_name'];
        $module_action  = $module['action'];
        $cuts           = generate_char(20, strlen($module_name), SYMBOL_ASSIGN);
        fwrite($file, "
    // ====== {$module_name} {$cuts}");
        foreach ($module_action as $action) {
            $action_name    = $action['action_name'];
            $action_note    = $action['action_note'];
            $action_out     = $action['action_out'];
            $field_name_max = $action['field_name_max'];
            $action_name_up = strtoupper($action_name);
            $action_name_fi = str_replace('_', '', ucwords($action_name, '_'));
            // actionResult
            show_schedule(PF_PTC_WRITE, 'S=>C Object : '.$action_name_fi, $pt_file_num);
            $layout         = get_field_layout($module_name, $action_out, $field_name_max, SPACE_08);
            fwrite($file, "
    // {$action_note}
    {$action_name_fi}Result : {
        id      : PACKET_ID.CMSG_{$action_name_up},{$layout}
    },
");
        }
    }



    // 以下为固定内容
    fwrite($file, '
};



//-----------------------------------------------------------------------
Object.keys(RESP_PACKET_LAYOUTS).forEach((pktName, index) => {
    let spec = RESP_PACKET_LAYOUTS[pktName];
    RESP_PACKET_LAYOUTS[spec.id] = spec;
});


function builtin_type_reader(type) {  
    let fn = \'read_\' + type;
    return function built_in_type_reader_inst(obj, fieldName, bytes) {
        return bytes[fn]();
    };
}

function zip_reader(content_reader) {
        return function zip_reader_inst(obj, fieldName, bytes) {
        let outLen = bytes.read_uint32();
        if (outLen === 0) return null; //如果解压后大小为0

        let input = new Uint8Array(bytes.buffer, bytes.rPos);
        let output = PakoInflate.inflate(input);

        return content_reader(obj, fieldName, new DataBuffer(output));
    };
}

function array_reader(count_type, content_reader) {
    return function array_reader_inst(obj, fieldName, bytes) {
        let count = bytes[\'read_\' + count_type]();
        let result = new Array(count);
        for (let i = 0; i < count; i++)
            result[i] = content_reader(obj, fieldName, bytes);
        return result;
    };
}

function fixed_count_array_reader(count, content_reader) {
    return function array_reader_inst(obj, fieldName, bytes) {
        let result = new Array(count);
        for (let i = 0; i < count; i++)
            result[i] = content_reader(obj, fieldName, bytes);
        return result;
    };
}

function conditional_reader(predicate, content_reader) {
    return function conditional_reader_inst(object, fieldName, bytes) {
        if (predicate(object, fieldName, bytes)) {
            return content_reader(object, fieldName, bytes);
        }
    }
}

function layout_reader(spec) {
    let layout_reader_inst = (obj, fieldName, bytes) => {
        return PacketGen.parse_packet(spec, bytes);
    };
    return layout_reader_inst;
}

function hack_read_time(obj, fieldName, bytes) {
    bytes.read_uint16();
    return bytes.read_uint16();
}

function _game_packet_layout(childLayout) {
    childLayout.unshift([\'serverId\', u16]);
    return childLayout;
}

export function parse(msg, bytes) {
    let spec = RESP_PACKET_LAYOUTS[msg];
    if (spec === undefined) {
        cc.log("Unrecognized packet: " + msg);
        return null;
    }

    let obj = PacketGen.parse_packet(spec, bytes);
    obj.packet_msg_id = msg;

    return obj;
}
//-----------------------------------------------------------------------

');



    // 写入协议接口
    foreach ($protocol_module as $module) {
        $module_action  = $module['action'];
        foreach ($module_action as $action) {
            $action_name    = $action['action_name'];
            $action_note    = $action['action_note'];
            $action_in      = $action['action_in'];
            $action_name_fi = str_replace('_', '', ucwords($action_name, '_'));
            $function_name  = lcfirst(str_replace('_', '', ucwords($action_name, '_')));
            $field_name_arr = array();
            foreach ($action_in as $field) {
                $field_name         = $field['field_name'];
                $field_name         = lcfirst(str_replace('_', '', ucwords($field_name, '_')));
                $field_name_arr[]   = $field_name;
            }
            $field_arr  = implode(', ', $field_name_arr);
            show_schedule(PF_PTC_WRITE, 'Function : '.$function_name, $pt_file_num);
            fwrite($file, "
// {$action_note}
export function {$function_name}({$field_arr}) {
    return PacketGen.make_packet(CLIENT_PACKET_LAYOUTS.{$action_name_fi}, [{$field_arr}]);
}
");
        }
    }

    fclose($file);
}


// @todo    获取参数布局
function get_field_layout ($module_name, $field_arr, $field_name_max, $indentation) {
    $layout     = "
{$indentation}layout  : [";
    foreach ($field_arr as $field) {
        $field_name     = $field['field_name'];
        $field_name     = lcfirst(str_replace('_', '', ucwords($field_name, '_')));
        $dots           = generate_char($field_name_max, strlen($field_name), SPACE_ONE);
        $alias_layout   = get_field_type_alias_or_layout($module_name, $field, $field_name_max);
        $layout         = $layout."
    {$indentation}['{$field_name}',{$dots} {$alias_layout}],";
    }
    $layout     = $layout."
{$indentation}]";

    return $layout;
}

// @todo    获取字段类型的别名
function get_field_type_alias_or_layout ($module_name, $field, $field_name_max) {
    global $protocol;

    $field_type     = $field['field_type'];
    $field_module   = $field['field_module'];
    $field_class    = $field['field_class'];
    $alias_layout   = '';
    if     ($field_type == C_ENUM)  {
        $alias_layout   = CT_ENUM;
    }
    elseif ($field_type == C_BYTE)  {
        $alias_layout   = CT_BYTE;
    }
    elseif ($field_type == C_SHORT) {
        $alias_layout   = CT_SHORT;
    }
    elseif ($field_type == C_INT)   {
        $alias_layout   = CT_INT;
    }
    elseif ($field_type == C_LONG)  {
        $alias_layout   = CT_LONG;
    }
    elseif ($field_type == C_STRING){
        $alias_layout   = CT_STRING;
    }
    elseif ($field_type == C_TYPEOF){
        if (!$field_module) {
            $field_module   = $module_name;
        }
        $protocol_class = $protocol[C_CLASS];
        $class_field    = $protocol_class[$field_module][$field_class];
        $alias_layout   = 'layout_reader({'.get_field_layout($field_module, $class_field, $field_name_max, SPACE_16).'
            })';
    }
    elseif ($field_type == C_LIST && $field_class){
        if (!$field_module) {
            $field_module   = $module_name;
        }
        $protocol_class = $protocol[C_CLASS];
        $class_field    = $protocol_class[$field_module][$field_class];
        $alias_layout   = 'array_reader(u16, layout_reader({'.get_field_layout($field_module, $class_field, $field_name_max, SPACE_16).'
            }))';
    }
    elseif ($field_type == C_LIST){
        $field_list     = $field['field_list'];
        $alias_layout   = 'array_reader(u16, layout_reader({'.get_field_layout($module_name, $field_list, $field_name_max, SPACE_16).'
            }))';
    }

    return $alias_layout;
}
?>