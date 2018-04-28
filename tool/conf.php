<?php
$db_argv = array(
    'localhost' => array(
        'host'  => '127.0.0.1',
        'user'  => 'root',
        'pass'  => 'ybybyb',
        'name'  => 'yisixer',
        'port'  => 3306
    ),
    'mini' => array(
        'host'  => '127.0.0.1',
        'user'  => 'root',
        'pass'  => 'wlwlwl',
        'name'  => 'yisixer',
        'port'  => 3306
    )
);

$enum_table = array(
    'item' => array(
        'id'    => 'id',
        'sign'  => 'sign',
        'cname' => 'cname',
        'prefix'=> 'II_',
        'note'  => '物品'
    ),
    'item_type' => array(
        'id'    => 'id',
        'sign'  => 'sign',
        'cname' => 'cname',
        'prefix'=> 'IT_',
        'note'  => '物品类型'
    )
);

$protocol   = array(
    'test'  => array(
        'module_note'   => "测  试",
        'module_name'   => "test",
        'module_id'     => "100",
        'class'         => array(
            'info'  => array(
                'extend_module' => "",
                'extend_class'  => "",
                'class_note'    => "信息",
                'class_field'   => array(
                    0   => array(
                        'field_name'    => "player_id",
                        'field_type'    => "long",
                        'field_module'  => "",
                        'field_class'   => "",
                        'field_note'    => "玩家ID",
                        'field_enum'    => array(
                            0   =>  "PROGRAM"
                        )
                    )
                )
            )
        )
    )
);
?>