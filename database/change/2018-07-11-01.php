<?php
    execute("
        INSERT INTO `item_type` (`id`, `sign`, `cname`) VALUES
            (1000,  'resource', '资源'),  -- 资源:经验体力木粮石铁币
            (2000,  'helmet',   '头盔'),  -- 头盔
            (3000,  'armour',   '盔甲'),  -- 盔甲
            (4000,  'caliga',   '战靴'),  -- 战靴
            (5000,  'weapon',   '武器'),  -- 武器
            (6000,  'shield',   '护盾'),  -- 护盾
            (7000,  'amulet',   '护符'),  -- 护符
            (8000,  'dress',    '时装'),  -- 时装
            (11000, 'corps',    '士兵'),  -- 士兵
            (12000, 'dragon',   '龙宠'),  -- 龙宠
            (13000, 'building', '建筑'),  -- 建筑
            (14000, 'mount',    '坐骑'),  -- 坐骑
            (15000, 'gift',     '礼包'),  -- 礼包
            (26000, 'role',     '伙伴');  -- 伙伴


        INSERT INTO `platform` VALUES
            (1, 'YiSiXer', '在观音山', 0, '14X2');


        INSERT INTO `log_type` (`id`, `sign`, `cname`, `name`, `type`) VALUES
            ('1', 'system_get', '后台给予', '0', '1'), 
            ('2', 'system_cost', '后台扣除', '0', '0'), 
            ('3', 'charge', '充值', '0', '1');
    ");
?>