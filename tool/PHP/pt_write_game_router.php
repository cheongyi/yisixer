<?php
// =========== ======================================== ====================
// @todo   写入路由转发
function write_game_router () {
    global $protocol, $pt_file_num;

    show_schedule(PF_PTS_WRITE, GAME_ROUTER_FILE_NAME, $pt_file_num);
    $file   = fopen(GAME_ROUTER_FILE, 'w');

    // 写入模块相关属性
    fwrite($file, '-module ('.GAME_ROUTER.').');
    write_attributes($file);

    fwrite($file, '
-export ([
    route_request/2
]).

-include ("define.hrl").
-include ("record.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    路由请求
%%% route_request (_Pack = <<ModuleId:16/unsigned, ActionId:16/unsigned, Args/binary>>, State) ->
route_request (_Pack = <<ActionId'.BT_ACTION.', Args/binary>>, State) ->
    put(prev_request, ActionId),
    TimeRecord  = game_prof:statistics_start(),
    {Module, Fuction, ArgsNum, NewState, OutBin} = route_relay(ActionId, Args, State),
    case OutBin of
        <<>> ->
            noop;
        _ ->
            lib_misc:tcp_send(NewState #client_state.sock, OutBin)
    end,
    game_prof:statistics_end({Module, Fuction, ArgsNum}, TimeRecord),
    NewState.


%%% ========== ======================================== ====================
%%% @doc    路由转发');

    $protocol_module    = $protocol[C_MODULE];
    foreach ($protocol_module as $module) {
        // 变量声明、赋值、初始化
        $module_id      = $module['module_id'];
        $module_name    = $module['module_name'];
        $module_action  = $module['action'];
        if (count($module_action) == 0) {
            continue;
        }

        foreach ($module_action as $action) {
            $action_name    = $action['action_name'];
            $action_id      = $action['action_id'];
            $action_in      = $action['action_in'];
            $field_name_max = $action['field_name_max'];
            $args_num       = count($action_in) + 1;

            fwrite($file, "
route_relay ({$action_id}, _Args00, State) ->");
            if ($args_num > 1) {
                write_field_bin_to_term($file, $module_name, $action_in, $field_name_max, SPACE_04);
                $field_name_arr = implode(', ', get_field_name_arr($action_in));
                fwrite($file, "
    {NewState, OutBin} = api_{$module_name}:{$action_name}($field_name_arr, State),");
            }
            else {
                fwrite($file, "
    {NewState, OutBin} = api_{$module_name}:{$action_name}(State),");

            }
            fwrite($file, "
    {{$module_name}, {$action_name}, {$args_num}, NewState, OutBin};");
        }
    }

    // 写入route_relay通配函数
    fwrite($file, '
route_relay (_ActionId, _Args00, _State) ->
    ok.


%%% ========== ======================================== ====================
%%% @doc    元组剖析');


    // 写入tuple_parser函数
    foreach ($protocol_module as $module) {
        $module_id      = $module['module_id'];
        $module_name    = $module['module_name'];
        $module_class   = $module['class'];
        foreach ($module_class as $class_name => $class) {
            fwrite($file, "
tuple_parser ({$module_name}, {$class_name}, _Args00) ->");

            $class_field    = $class['class_field'];
            $field_name_max = $class['field_name_max'];
            write_field_bin_to_term($file, $module_name, $class_field, $field_name_max, SPACE_04);
            $field_name_arr = implode(', ', get_field_name_arr($class_field));
            $class_field_num= sprintf("%02d", count($class_field));
            fwrite($file, "
    {{{$class_name}, {$field_name_arr}}, _Args{$class_field_num}};");
        }
    }
    // 写入tuple_parser通配函数
    fwrite($file, '

tuple_parser (_Module, _Class, _Args) ->
    {null, _Args}.


%%% ========== ======================================== ====================
%%% @doc    列表剖析');


    // 写入list_parser函数
    foreach ($protocol_module as $module) {
        // 变量声明、赋值、初始化
        $module_id      = $module['module_id'];
        $module_name    = $module['module_name'];
        $module_action  = $module['action'];

        foreach ($module_action as $action) {
            $action_name    = $action['action_name'];
            $action_in      = $action['action_in'];
            $field_name_max = $action['field_name_max'];
            foreach ($action_in as $field) {
                $field_line         = $field['field_line'];
                $field_name         = $field['field_name'];
                $field_type         = $field['field_type'];
                $field_class        = $field['field_class'];
                $field_module       = $field['field_module'];
                if ($field_module == '') {
                    $field_module   = $module_name;
                }
                if ($field_type == C_LIST) {
                    if ($field_class) {
                        fwrite($file, "
list_parser ({$field_module}, {$field_class}, 0,       _Args00, Result) ->
    {Result, _Args00};
list_parser ({$field_module}, {$field_class}, ListLen, _Args00, Result) ->
    {ListElement, _Args01} = tuple_parser({$field_module}, {$field_class}, _Args00),
    list_parser({$field_module}, {$field_class}, ListLen - 1, _Args01, [ListElement | Result]);");
                    }
                    else {
                        fwrite($file, "
list_parser ({$field_module}, {$field_line}, 0,       _Args00, Result) ->
    {Result, _Args00};
list_parser ({$field_module}, {$field_line}, ListLen, _Args00, Result) ->");
                        $field_list     = $field['field_list'];
                        write_field_bin_to_term($file, $module_name, $field_list, $field_name_max, SPACE_04);
                        $field_name_arr = implode(', ', get_field_name_arr($field_list));
                        $field_list_num = sprintf("%02d", count($field_list));
                        fwrite($file, "
    ListElement = {{$field_name_arr}},
    list_parser({$field_module}, {$field_line}, ListLen - 1, _Args{$field_list_num}, [ListElement | Result]);");
                    }
                }
            }
        }
    }
    // 写入list_parser通配函数
    fwrite($file, '

list_parser (_Module, _Line, _ListLen, _Args, _Result) ->
    {_Result, _Args}.


%%% ========== ======================================== ====================
%%% @doc    字符串剖析
string_parser (Args) ->
    string_parser(Args, <<>>).

string_parser (<<         0, Rest/binary >>, Acc) -> {Rest, << Acc/binary         >>};
string_parser (<< Str:08, 0, Rest/binary >>, Acc) -> {Rest, << Acc/binary, Str:08 >>};
string_parser (<< Str:16, 0, Rest/binary >>, Acc) -> {Rest, << Acc/binary, Str:16 >>};
string_parser (<< Str:24, 0, Rest/binary >>, Acc) -> {Rest, << Acc/binary, Str:24 >>};
string_parser (<< Str:32, 0, Rest/binary >>, Acc) -> {Rest, << Acc/binary, Str:32 >>};
string_parser (<< Str:32,    Rest/binary >>, Acc) -> string_parser(Rest, << Acc/binary, Str:32 >>).


');

    fclose($file);
}


// @todo   写入字段
function write_field_bin_to_term ($file, $module_name, $field_arr, $field_name_max, $indentation) {
    $new_line   = "
{$indentation}<<";
    $i  = 0;
    foreach ($field_arr as $field) {
        $field_line         = $field['field_line'];
        $field_name         = $field['field_name'];
        $field_type         = $field['field_type'];
        $field_class        = $field['field_class'];
        $field_module       = $field['field_module'];
        if ($field_module == '') {
            $field_module   = $module_name;
        }
        $field_name         = UNDER_LINE.$field_name.UNDER_LINE.$field_line;
        if     ($field_type == C_STRING){
            $dots_SizeLen   = generate_char($field_name_max, strlen("BinSize_{$field_line}"), SPACE_ONE);
        }
        elseif ($field_type == C_LIST)  {
            $dots_SizeLen   = generate_char($field_name_max, strlen("ListLen_{$field_line}"), SPACE_ONE);
        }
        $dots  = generate_char($field_name_max, strlen($field_name), SPACE_ONE);

        $j      = $i + 1;
        $i_str  = sprintf("%02d", $i);
        $j_str  = sprintf("%02d", $j);
        $rest   = ", _Args{$j_str}/binary>> = _Args{$i_str},";
        if     ($field_type == C_ENUM)  {
            fwrite($file, $new_line.$dots.$field_name.BT_ENUM. '  '.$rest);
        }
        elseif ($field_type == C_BYTE)  {
            fwrite($file, $new_line.$dots.$field_name.BT_BYTE. '  '.$rest);
        }
        elseif ($field_type == C_SHORT) {
            fwrite($file, $new_line.$dots.$field_name.BT_SHORT.'  '.$rest);
        }
        elseif ($field_type == C_INT)   {
            fwrite($file, $new_line.$dots.$field_name.BT_INT . '  '.$rest);
        }
        elseif ($field_type == C_LONG)  {
            fwrite($file, $new_line.$dots.$field_name.BT_LONG. '  '.$rest);
        }
        elseif ($field_type == C_STRING){
            fwrite($file, "
{$indentation}{_Args{$j_str}, {$field_name}_Bin}{$dots} = string_parser(_Args{$i_str}),");
            fwrite($file, "
{$indentation}{$field_name}{$dots}                = binary_to_list({$field_name}_Bin),");
        }
        elseif ($field_type == C_TYPEOF) {
            fwrite($file, "
            {{$dots} {$field_name},             _Args{$j_str}}         = tuple_parser({$field_module}, {$field_class}, _Args{$i_str}),
");
        }
        elseif ($field_type == C_LIST) {
            $list_len       = get_list_len_field($field_line);
            fwrite($file, 
                $new_line.$dots_SizeLen.$list_len.', '.
                "{$field_name}_Bin/binary".
                ">> = _Args{$i_str},"
            );
            if ($field_class) {
                fwrite($file, "
            {{$dots} {$field_name},             _Args{$j_str}}         = list_parser({$field_module}, {$field_class}, ListLen_{$field_line}, {$field_name}_Bin, []),
");
            }
            else {
                fwrite($file, "
            {{$dots} {$field_name},             _Args{$j_str}}         = list_parser({$field_module}, {$field_line}, ListLen_{$field_line}, {$field_name}_Bin, []),
");
            }
        }

        $i ++;
    }
}
?>