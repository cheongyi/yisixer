<?php
$db_argv = array(
    'localhost' => array(
        'host' => '127.0.0.1',
        'user' => 'root',
        'pass' => 'wlwlwl',
        'name' => 'yisixer',
        'port' => 3306
    )
);

$enum_table = array(
    'item' => array(
        'tname' => 'item',
        'id'    => 'id',
        'sign'  => 'sign',
        'cname' => 'cname',
        'prefix'=> 'II_',
        'note'  => '物品'
    ),
    'item_type' => array(
        'tname' => 'item_type',
        'id'    => 'id',
        'sign'  => 'sign',
        'cname' => 'cname',
        'prefix'=> 'IT_',
        'note'  => '物品类型'
    )
);
?>