<?php
    execute("
        UPDATE `db_version` SET `release` = '';
        -- CREATE TABLE `db_version`
        -- (
        --     `version`               INTEGER     NOT NULL DEFAULT 0      COMMENT '版本号:YYYYMMDD',
        --     `release`               VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '发布号:RXXX',
        --     CONSTRAINT `pk_db_version` PRIMARY KEY (`version`)
        -- )
        -- COMMENT       = '数据库版本'
        -- ENGINE        = 'InnoDB'
        -- CHARACTER SET = 'utf8'
        -- COLLATE       = 'utf8_general_ci';

        -- 模版数据表
        DROP TABLE IF EXISTS `item`;
        CREATE TABLE `item`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT '物品ID',
            `sign`                  VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '标识',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            `description`           INTEGER     NOT NULL DEFAULT 0      COMMENT '描述',
            `type`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '类型',
            `color`                 INTEGER     NOT NULL DEFAULT 0      COMMENT '颜色:4绿5青6蓝7紫1红2橙3黄',
            `level`                 INTEGER     NOT NULL DEFAULT 0      COMMENT '等级',
            `icon`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '图标',
            `price`                 INTEGER     NOT NULL DEFAULT 0      COMMENT '价格',
            `stack`                 INTEGER     NOT NULL DEFAULT 0      COMMENT '堆叠',
            `sort`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '排序',
            `expire_time`           INTEGER     NOT NULL DEFAULT 0      COMMENT '过期时间',
            `day_get_limit`         INTEGER     NOT NULL DEFAULT 0      COMMENT '每日获得上限',
            CONSTRAINT `pk_item` PRIMARY KEY (`id`)
        )
        COMMENT       = '物品'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';

        DROP TABLE IF EXISTS `item_type`;
        CREATE TABLE `item_type`
        (
            `id`                    INTEGER     NOT NULL DEFAULT 0      COMMENT '物品类型ID',
            `sign`                  VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '标识',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            CONSTRAINT `pk_item_type` PRIMARY KEY (`id`)
        )
        COMMENT       = '物品类型'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';
        INSERT INTO `item_type` (`id`, `sign`) VALUES
            (1000, 'resource'),     -- 资源:经验体力木粮石铁币
            (2000, 'helmet'),        -- 头盔
            (3000, 'armour'),        -- 盔甲
            (4000, 'caliga'),        -- 战靴
            (5000, 'weapon'),        -- 武器
            (6000, 'shield'),        -- 护盾
            (7000, 'amulet'),        -- 护符
            (8000, 'dress'),        -- 时装
            (11000, 'corps'),        -- 士兵
            (12000, 'dragon'),       -- 龙宠
            (13000, 'building'),     -- 建筑
            (14000, 'mount'),        -- 坐骑
            (15000, 'gift'),         -- 礼包
            (26000, 'role');         -- 伙伴

        DROP TABLE IF EXISTS `log_type`;
        CREATE TABLE `log_type`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `sign`                  VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '标识',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            `type`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '类型:0消耗|1获得',
            CONSTRAINT `pk_log_type` PRIMARY KEY (`id`)
        )
        COMMENT       = '日志类型'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';

        -- 玩家表
        DROP TABLE IF EXISTS `player`;
        CREATE TABLE `player`
        (
            `id`                    BIGINT(25)  NOT NULL AUTO_INCREMENT COMMENT '玩家ID',
            `username`              VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '用户名',
            `nickname`              VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '昵称',
            `vip_level`             INTEGER     NOT NULL DEFAULT 0      COMMENT 'vip等级',
            `disable_login`         INTEGER     NOT NULL DEFAULT 0      COMMENT '屏蔽截止时间',
            `disable_talk`          INTEGER     NOT NULL DEFAULT 0      COMMENT '禁言截止时间',
            `is_tester`             INTEGER     NOT NULL DEFAULT 0      COMMENT '是否是测试号',
            `regdate`               INTEGER     NOT NULL DEFAULT 0      COMMENT '注册时间',
            `test_disable`          INTEGER     NOT NULL DEFAULT 0      COMMENT '是否因为测试号被封号 0否 1是',
            `disable_type`          INTEGER     NOT NULL DEFAULT 0      COMMENT '封号类型',
            `server_id`             INTEGER     NOT NULL DEFAULT 0      COMMENT '服务器ID',
            CONSTRAINT `pk_player` PRIMARY KEY (`id`)
        )
        COMMENT       = '玩家物品'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';

        -- 玩家数据表
        DROP TABLE IF EXISTS `player_item`;
        CREATE TABLE `player_item`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `player_id`             BIGINT(25)  NOT NULL                COMMENT '玩家ID',
            `item_id`               INTEGER     NOT NULL DEFAULT 0      COMMENT '物品ID',
            `number`                INTEGER     NOT NULL DEFAULT 0      COMMENT '数量',
            `expire_time`           INTEGER     NOT NULL DEFAULT 0      COMMENT '过期时间',
            CONSTRAINT `pk_player_item` PRIMARY KEY (`id`)
        )
        COMMENT       = '玩家物品'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';
    ");
?>
