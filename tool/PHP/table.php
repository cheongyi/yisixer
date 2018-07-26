<?php
/*
 * @desc 配置要生成的模版数据
*/

// 要生成的模版数据 文件名 => 生成模版数据的sql
$sql_list = array(
    'crop_item' => 'SELECT 
        a.`item_id`         AS `item_id`,
        c.`sign`            AS `sign`,
        c.`name`            AS `name`,
        (SELECT e.`sign` FROM crop d, item e WHERE d.`cost_item_id` = e.`id` AND d.`item_id` = a.`item_id`) AS `cost_sign`,
        a.`cost_number`     AS `cost_number`,
        b.`unlock_lv`       AS `unlock_lv`
    FROM crop a, crop_type b, item c
    WHERE a.`item_id` = c.`id` AND a.`type` = b.`id`',

    'crop'                      => 'SELECT a.* FROM crop        a',
    'crop_type'                 => 'SELECT a.* FROM crop_type   a',
    'game_function'             => 'SELECT a.* FROM game_function   a',
    'item'                      => 'SELECT a.* FROM item        a',
    'item_type'                 => 'SELECT a.* FROM item_type   a',
    'item_sale'                 => 'SELECT a.* FROM item_sale   a',
    'land'                      => 'SELECT a.* FROM land        a',
    'level'                     => 'SELECT a.* FROM level       a',
    'shop'                      => 'SELECT a.* FROM shop        a',
    'warehouse_expand'          => 'SELECT a.* FROM warehouse_expand    a'
);
?>