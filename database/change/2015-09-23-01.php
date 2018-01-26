<?php
    execute("
        CREATE TABLE `db_version`
        (
            `version`               INTEGER     NOT NULL DEFAULT 0      COMMENT '版本号:YYYYMMDD',
            `release`               VARCHAR(50) NOT NULL DEFAULT ''     COMMENT '发布号:RXXX',
            CONSTRAINT `pk_db_version` PRIMARY KEY (`version`)
        )
        COMMENT       = '数据库版本'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';

        -- 模版数据表
        DROP TABLE IF EXISTS `item`;
        CREATE TABLE `item`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT '物品ID',
            `sign`                  VARCHAR(50) NOT NULL DEFAULT ''     COMMENT '标识',
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
            `sign`                  VARCHAR(50) NOT NULL DEFAULT ''     COMMENT '标识',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            CONSTRAINT `pk_item_type` PRIMARY KEY (`id`)
        )
        COMMENT       = '物品类型'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';
        INSERT INTO `item_type` (`id`, `sign`) VALUES
            (1000, 'resource'),     -- 资源:经验体力木粮石铁币
            (1000, 'helmet'),        -- 头盔
            (1000, 'armour'),        -- 盔甲
            (1000, 'caliga'),        -- 战靴
            (1000, 'weapon'),        -- 武器
            (1000, 'shield'),        -- 护盾
            (1000, 'amulet'),        -- 护符
            (1000, 'dress'),        -- 时装
            (1000, 'corps'),        -- 士兵
            (1000, 'dragon'),       -- 龙宠
            (1000, 'building'),     -- 建筑
            (1000, 'mount'),        -- 坐骑
            (1000, 'gift'),         -- 礼包
            (2000, 'role');         -- 伙伴

        DROP TABLE IF EXISTS `log_type`;
        CREATE TABLE `log_type`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `sign`                  VARCHAR(50) NOT NULL DEFAULT ''     COMMENT '标识',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            `type`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '类型:0消耗|1获得',
            CONSTRAINT `pk_log_type` PRIMARY KEY (`id`)
        )
        COMMENT       = '日志类型'
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

        DROP TABLE IF EXISTS `player_`;
        CREATE TABLE `player_`
        (
            `player_id`             BIGINT(25)  NOT NULL                COMMENT '玩家ID',
            `union_id`              INTEGER     NOT NULL DEFAULT 0      COMMENT '联盟ID',
            `fail_number`           INTEGER     NOT NULL DEFAULT 0      COMMENT '失败次数',
            `fail_time`             INTEGER     NOT NULL DEFAULT 0      COMMENT '失败时间',
            `player_score`          INTEGER     NOT NULL DEFAULT 0      COMMENT '玩家积分',
            `cur_wave`              INTEGER     NOT NULL DEFAULT 0      COMMENT '当前波数',
            `fight_time`            INTEGER     NOT NULL DEFAULT 0      COMMENT '战斗时间',
            `wave_award_time`       INTEGER     NOT NULL DEFAULT 0      COMMENT '波数奖励时间',
            `score_award_time`      INTEGER     NOT NULL DEFAULT 0      COMMENT '积分奖励时间',
            `rank_award_time`       INTEGER     NOT NULL DEFAULT 0      COMMENT '排名奖励时间',
            `extra_award_time`      INTEGER     NOT NULL DEFAULT 0      COMMENT '额外奖励时间',
            CONSTRAINT `pk_player_` PRIMARY KEY (`player_id`)
        )
        COMMENT       = '玩家巨龙挑衅'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';
    ");
?>
