<?php

// MySQL dump 10.13  Distrib 5.7.20, for osx10.13 (x86_64)

// Host: 127.0.0.1    Database: yisixer
// ------------------------------------------------------
// Server version   5.7.20


echo "\n\n";

execute("
    /*!40101 SET NAMES utf8 */;

    /*!40101 SET SQL_MODE=''*/;

    /*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
    /*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
    /*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
    /*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
");


if ($db_version == 0) {
    echo "    db_version .......... [ignore]\n";

}

if ($db_version == 0) {
    echo "    item ................ ";

    execute("
        CREATE TABLE `item` (
            `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '物品ID',
            `sign` varchar(64) NOT NULL DEFAULT '' COMMENT '标识',
            `name` int(11) NOT NULL DEFAULT '0' COMMENT '名称',
            `description` int(11) NOT NULL DEFAULT '0' COMMENT '描述',
            `type` int(11) NOT NULL DEFAULT '0' COMMENT '类型',
            `color` int(11) NOT NULL DEFAULT '0' COMMENT '颜色:4绿5青6蓝7紫1红2橙3黄',
            `level` int(11) NOT NULL DEFAULT '0' COMMENT '等级',
            `icon` int(11) NOT NULL DEFAULT '0' COMMENT '图标',
            `price` int(11) NOT NULL DEFAULT '0' COMMENT '价格',
            `stack` int(11) NOT NULL DEFAULT '0' COMMENT '堆叠',
            `sort` int(11) NOT NULL DEFAULT '0' COMMENT '排序',
            `expire_time` int(11) NOT NULL DEFAULT '0' COMMENT '过期时间',
            `day_get_limit` int(11) NOT NULL DEFAULT '0' COMMENT '每日获得上限',
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='物品';
    ");

    echo "[created]\n"; 
}

echo "    item ................ ";

execute("DELETE FROM `item`;");

echo "[loaded]\n"; 

if ($db_version == 0) {
    echo "    item_type ........... ";

    execute("
        CREATE TABLE `item_type` (
            `id` int(11) NOT NULL DEFAULT '0' COMMENT '物品类型ID',
            `sign` varchar(64) NOT NULL DEFAULT '' COMMENT '标识',
            `name` int(11) NOT NULL DEFAULT '0' COMMENT '名称',
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='物品类型';
    ");

    echo "[created]\n"; 
}

echo "    item_type ........... ";

execute("DELETE FROM `item_type`;");

execute("
    INSERT INTO `item_type` (`id`, `sign`, `name`) VALUES
        ('1000', 	'resource', 	'0'), 
        ('2000', 	'helmet', 	'0'), 
        ('3000', 	'armour', 	'0'), 
        ('4000', 	'caliga', 	'0'), 
        ('5000', 	'weapon', 	'0'), 
        ('6000', 	'shield', 	'0'), 
        ('7000', 	'amulet', 	'0'), 
        ('8000', 	'dress', 	'0'), 
        ('11000', 	'corps', 	'0'), 
        ('12000', 	'dragon', 	'0'), 
        ('13000', 	'building', 	'0'), 
        ('14000', 	'mount', 	'0'), 
        ('15000', 	'gift', 	'0'), 
        ('26000', 	'role', 	'0');
");

echo "[loaded]\n"; 

if ($db_version == 0) {
    echo "    log_type ............ ";

    execute("
        CREATE TABLE `log_type` (
            `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `sign` varchar(64) NOT NULL DEFAULT '' COMMENT '标识',
            `name` int(11) NOT NULL DEFAULT '0' COMMENT '名称',
            `type` int(11) NOT NULL DEFAULT '0' COMMENT '类型:0消耗|1获得',
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='日志类型';
    ");

    echo "[created]\n"; 
}

echo "    log_type ............ ";

execute("DELETE FROM `log_type`;");

echo "[loaded]\n"; 

if ($db_version == 0) {
    echo "    player .............. ";

    execute("
        CREATE TABLE `player` (
            `id` bigint(25) NOT NULL AUTO_INCREMENT COMMENT '玩家ID',
            `username` varchar(64) NOT NULL DEFAULT '' COMMENT '用户名',
            `nickname` varchar(64) NOT NULL DEFAULT '' COMMENT '昵称',
            `vip_level` int(11) NOT NULL DEFAULT '0' COMMENT 'vip等级',
            `disable_login` int(11) NOT NULL DEFAULT '0' COMMENT '屏蔽截止时间',
            `disable_talk` int(11) NOT NULL DEFAULT '0' COMMENT '禁言截止时间',
            `is_tester` int(11) NOT NULL DEFAULT '0' COMMENT '是否是测试号',
            `regdate` int(11) NOT NULL DEFAULT '0' COMMENT '注册时间',
            `test_disable` int(11) NOT NULL DEFAULT '0' COMMENT '是否因为测试号被封号 0否 1是',
            `disable_type` int(11) NOT NULL DEFAULT '0' COMMENT '封号类型',
            `server_id` int(11) NOT NULL DEFAULT '0' COMMENT '服务器ID',
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家物品';
    ");

    echo "[created]\n"; 
}

if ($db_version == 0) {
    echo "    player_item ......... ";

    execute("
        CREATE TABLE `player_item` (
            `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `player_id` bigint(25) NOT NULL COMMENT '玩家ID',
            `item_id` int(11) NOT NULL DEFAULT '0' COMMENT '物品ID',
            `number` int(11) NOT NULL DEFAULT '0' COMMENT '数量',
            `expire_time` int(11) NOT NULL DEFAULT '0' COMMENT '过期时间',
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家物品';
    ");

    echo "[created]\n"; 
}


execute("
    /*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
    /*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
    /*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
    /*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
");

echo "\n";
?>
