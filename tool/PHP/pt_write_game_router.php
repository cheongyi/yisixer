<?php
// =========== ======================================== ====================
// @todo   写入路由转发
function write_game_router () {
    global $protocol, $game_router_dir, $game_router;


    $file           = fopen("{$game_router_dir}{$game_router}.erl", 'w');

    // 写入模块相关属性
    fwrite($file, "-module ({$game_router}).");
    write_attributes($file);

    fwrite($file, "
-export ([
    route_request/2
]).

% -include (\"game.hrl\").
% -include (\"gen/game_db.hrl\").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    路由请求
route_request (_Pack = <<ModuleId:16/unsigned, ActionId:16/unsigned, Args/binary>>, State) ->
    put(prev_request, {ModuleId, ActionId}),
    TimeRecord  = game_perf:statistics_start(),
    {Module, Fuction, ArgsNum, NewState} = route_relay(ModuleId, ActionId, Args, State),
    game_perf:statistics_end({Module, Fuction, ArgsNum}, TimeRecord),
    NewState.


%%% ========== ======================================== ====================
%%% @doc    路由转发");

    $protocol_module    = $protocol[C_MODULE];
    foreach ($protocol_module as $module_name => $module) {
        // 变量声明、赋值、初始化
        $module_id      = $module['module_id'];
        $module_action  = $module['action'];

    fwrite($file, "
route_relay ({$module_id}, _ActionId, _Args0, State) ->
    case _ActionId of
");

        $semicolon      = "";
        foreach ($module_action as $action_name => $action) {
            $action_id      = $action['action_id'];
            $action_in      = $action['action_in'];
            $args_num       = count($action_in) + 1;

            fwrite($file, $semicolon);
            fwrite($file, "
        {$action_id} ->");
            if ($args_num > 1) {
                write_field_bin_to_term($file, $action_in);
                $field_name_arr = implode(", ", get_field_name_arr($action_in));
                fwrite($file, "
            NewState = api_{$module_name}:{$action_name}($field_name_arr, State),");
            }
            else {
                fwrite($file, "
            NewState = api_{$module_name}:{$action_name}(State),");

            }
            fwrite($file, "
            {{$module_name}, {$action_name}, {$args_num}, NewState}");

            $semicolon  = ";";
        }

    fwrite($file, "
    end;
");
    }

    // 写入route_relay通配函数
    fwrite($file, "
route_relay (_ModuleId, _ActionId, _Args0, _State) ->
    ok.
");

    fclose($file);
}


function write_field_bin_to_term ($file, $field_arr) {
    $new_line   = "
            <<";
    $i  = 0;
    foreach ($field_arr as $field) {
        $field_line         = $field['field_line'];
        $field_name         = $field['field_name'];
        $field_type         = $field['field_type'];
        $field_name         = "_".$field_name."_".$field_line;

        $j  = $i + 1;
        $rest   = ", _Args{$j}/binary>> = _Args{$i},";
        if ($field_type == 'enum') {
            fwrite($file, $new_line.$field_name.BT_ENUM. $rest);
        }
        elseif ($field_type == 'byte') {
            fwrite($file, $new_line.$field_name.BT_BYTE. $rest);
        }
        elseif ($field_type == 'short') {
            fwrite($file, $new_line.$field_name.BT_SHORT.$rest);
        }
        elseif ($field_type == 'int') {
            fwrite($file, $new_line.$field_name.BT_INT . $rest);
        }
        elseif ($field_type == 'long') {
            fwrite($file, $new_line.$field_name.BT_LONG. $rest);
        }
        elseif ($field_type == 'string') {
            fwrite($file, 
                $new_line."_{$field_line}".BT_BIN_LEN.", ".
                "{$field_name}:_{$field_line}_BinLen/binary".
                $rest
            );
        }
        elseif ($field_type == 'typeof') {
            $field_bin      = $field_name.BT_TYPEOF;
        }
        elseif ($field_type == 'list') {
            $field_bin      = $field_name.BT_BIN_LEN.", ".$field_name.BT_LIST;
        }

        $i ++;
    }
}
?>