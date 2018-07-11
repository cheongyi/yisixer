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
        -- ----------------------------------------------------------------------------------------
        DROP TABLE IF EXISTS `award`;
        CREATE TABLE `award`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `sign`                  VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '标识',
            `cname`                 VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '中文名称',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            CONSTRAINT `pk_award` PRIMARY KEY (`id`)
        )
        COMMENT       = '奖励'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';

        DROP TABLE IF EXISTS `award_info`;
        CREATE TABLE `award_info`
        (
            `award_id`              INTEGER     NOT NULL                COMMENT '奖励ID',
            `item_id`               INTEGER     NOT NULL                COMMENT '物品ID',
            `number`                INTEGER     NOT NULL DEFAULT 0      COMMENT '物品数量',
            `log_type`              INTEGER     NOT NULL DEFAULT 0      COMMENT '日志类型',
            `random_prob`           INTEGER     NOT NULL DEFAULT 0      COMMENT '随机概率',
            `sort`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '排序',
            CONSTRAINT `pk_award_info` PRIMARY KEY (`award_id`, `item_id`)
        )
        COMMENT       = '奖励信息'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';


        -- ----------------------------------------------------------------------------------------
        DROP TABLE IF EXISTS `constant`;
        CREATE TABLE `constant`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `cname`                 VARCHAR(32) NOT NULL DEFAULT ''     COMMENT '中文名称',
            `sign`                  VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '标识',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            `data`                  FLOAT       NOT NULL DEFAULT 0      COMMENT '数值',
            CONSTRAINT `pk_constant` PRIMARY KEY (`id`)
        )
        COMMENT       = '常量'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';


        -- ----------------------------------------------------------------------------------------
        DROP TABLE IF EXISTS `game_function`;
        CREATE TABLE `game_function`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `sign`                  VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '标识',
            `cname`                 VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '中文名称',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            `unlock_lv`             INTEGER     NOT NULL DEFAULT 0      COMMENT '解锁等级',
            `description`           INTEGER     NOT NULL DEFAULT 0      COMMENT '提示文本',
            CONSTRAINT `pk_game_function` PRIMARY KEY (`id`)
        )
        COMMENT       = '游戏功能'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';


        -- ----------------------------------------------------------------------------------------
        DROP TABLE IF EXISTS `item`;
        CREATE TABLE `item`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `sign`                  VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '标识',
            `cname`                 VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '中文名称',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            `type`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '类型',
            `level`                 INTEGER     NOT NULL DEFAULT 0      COMMENT '等级',
            `quality`               INTEGER     NOT NULL DEFAULT 0      COMMENT '品质',
            `description`           INTEGER     NOT NULL DEFAULT 0      COMMENT '描述',
            `sort`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '排序',
            `expire_time`           INTEGER     NOT NULL DEFAULT 0      COMMENT '过期时间(秒)',
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
            `id`                    INTEGER     NOT NULL                COMMENT 'ID',
            `sign`                  VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '标识',
            `cname`                 VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '中文名称',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            CONSTRAINT `pk_item_type` PRIMARY KEY (`id`)
        )
        COMMENT       = '物品类型'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';


        -- ----------------------------------------------------------------------------------------
        DROP TABLE IF EXISTS `log_type`;
        CREATE TABLE `log_type`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `cname`                 VARCHAR(32) NOT NULL DEFAULT ''     COMMENT '中文名称',
            `sign`                  VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '标识',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            `type`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '类型:0消耗|1获得',
            CONSTRAINT `pk_log_type` PRIMARY KEY (`id`)
        )
        COMMENT       = '日志类型'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';


        -- ----------------------------------------------------------------------------------------
        DROP TABLE IF EXISTS `platform`;
        CREATE TABLE `platform`
        (
            `id`                    INTEGER     NOT NULL                COMMENT 'ID',
            `sign`                  VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '标识',
            `cname`                 VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '中文名称',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            `private_key`           TEXT                                COMMENT '私钥',
            CONSTRAINT `pk_platform` PRIMARY KEY (`id`)
        )
        COMMENT       = '平台'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';


        -- ----------------------------------------------------------------------------------------
        DROP TABLE IF EXISTS `words_log`;
        CREATE TABLE `words_log`
        (
            `id`                    INTEGER     NOT NULL                COMMENT 'ID',
            `information`           TEXT                                COMMENT '信息',
            `language`              INTEGER     NOT NULL DEFAULT 0      COMMENT '语言',
            CONSTRAINT `pk_words_log` PRIMARY KEY (`id`)
        )
        COMMENT       = '文字表'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';

    ");
?>
