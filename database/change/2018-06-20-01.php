<?php
    execute("
        UPDATE `db_version` SET `release` = `release`;

        -- 玩家表
        -- ----------------------------------------------------------------------------------------
        DROP TABLE IF EXISTS `player`;
        CREATE TABLE `player`
        (
            `id`                    BIGINT(25)  NOT NULL AUTO_INCREMENT COMMENT '玩家ID',
            `username`              VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '用户名',
            `nickname`              VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '昵称',
            `device_id`             VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '设备ID',
            `source`                VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '推广来源',
            `platform_id`           INTEGER     NOT NULL DEFAULT 0      COMMENT '平台ID',
            `regdate`               INTEGER     NOT NULL DEFAULT 0      COMMENT '注册时间',
            `disable_login`         INTEGER     NOT NULL DEFAULT 0      COMMENT '封号截止时间',
            `disable_talk`          INTEGER     NOT NULL DEFAULT 0      COMMENT '禁言截止时间',
            `is_tester`             INTEGER     NOT NULL DEFAULT 0      COMMENT '是否测试号:0否;1是',
            `test_disable`          INTEGER     NOT NULL DEFAULT 0      COMMENT '测试号是否被封号:0否;1是',
            `disable_type`          INTEGER     NOT NULL DEFAULT 0      COMMENT '封号类型',
            `server_id`             INTEGER     NOT NULL DEFAULT 0      COMMENT '服务器ID',
            CONSTRAINT `pk_player` PRIMARY KEY (`id`)
        )
        COMMENT       = '玩家'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';


        -- 玩家数据表
        DROP TABLE IF EXISTS `player_key`;
        CREATE TABLE `player_key`
        (
            `player_id`             BIGINT(25)  NOT NULL                COMMENT '玩家ID',
            CONSTRAINT `pk_player_key` PRIMARY KEY (`player_id`)
        )
        COMMENT       = '玩家权值'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';

        DROP TABLE IF EXISTS `player_data`;
        CREATE TABLE `player_data`
        (
            `player_id`             BIGINT(25)  NOT NULL                COMMENT '玩家ID',
            `ingot`                 INTEGER     NOT NULL DEFAULT 0      COMMENT '金币',
            `charge_ingot`          INTEGER     NOT NULL DEFAULT 0      COMMENT '充值金币',
            `level`                 INTEGER     NOT NULL DEFAULT 0      COMMENT '等级',
            `experience`            INTEGER     NOT NULL DEFAULT 0      COMMENT '经验',
            `vip_level`             INTEGER     NOT NULL DEFAULT 0      COMMENT 'VIP等级',
            `vip_point`             INTEGER     NOT NULL DEFAULT 0      COMMENT 'VIP点数',
            CONSTRAINT `pk_player_data` PRIMARY KEY (`player_id`)
        )
        COMMENT       = '玩家数据'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';


        -- ----------------------------------------------------------------------------------------
        DROP TABLE IF EXISTS `player_trace`;
        CREATE TABLE `player_trace`
        (
            `player_id`             BIGINT(25)  NOT NULL                COMMENT '玩家ID',
            `hash_code`             VARCHAR(64) NOT NULL DEFAULT ''     COMMENT '哈希码',
            `first_login_ip`        CHAR(15)    NOT NULL DEFAULT 0      COMMENT '首次登录IP',
            `first_login_time`      INTEGER     NOT NULL DEFAULT 0      COMMENT '首次登录时间',
            `last_login_ip`         CHAR(15)    NOT NULL DEFAULT 0      COMMENT '最后登录IP',
            `last_login_time`       INTEGER     NOT NULL DEFAULT 0      COMMENT '最后登录时间',
            `last_offline_time`     INTEGER     NOT NULL DEFAULT 0      COMMENT '最后下线时间',
            CONSTRAINT `pk_player_trace` PRIMARY KEY (`player_id`)
        )
        COMMENT       = '玩家追踪'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';


        -- ----------------------------------------------------------------------------------------
        DROP TABLE IF EXISTS `player_item`;
        CREATE TABLE `player_item`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `player_id`             BIGINT(25)  NOT NULL                COMMENT '玩家ID',
            `item_id`               INTEGER     NOT NULL DEFAULT 0      COMMENT '物品ID',
            `number`                INTEGER     NOT NULL DEFAULT 0      COMMENT '数量',
            `expire_timestamp`      INTEGER     NOT NULL DEFAULT 0      COMMENT '过期时间戳',
            CONSTRAINT `pk_player_item` PRIMARY KEY (`id`)
        )
        COMMENT       = '玩家物品'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';


        -- ----------------------------------------------------------------------------------------
        DROP TABLE IF EXISTS `player_item_log`;
        CREATE TABLE `player_item_log`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `player_id`             BIGINT(25)  NOT NULL                COMMENT '玩家ID',
            `player_item_id`        INTEGER     NOT NULL DEFAULT 0      COMMENT '玩家物品ID',
            `item_id`               INTEGER     NOT NULL DEFAULT 0      COMMENT '物品ID',
            `value`                 INTEGER     NOT NULL DEFAULT 0      COMMENT '操作值',
            `after_value`           INTEGER     NOT NULL DEFAULT 0      COMMENT '操作后的值',
            `op_type`               INTEGER     NOT NULL DEFAULT 0      COMMENT '操作类型',
            `op_time`               INTEGER     NOT NULL DEFAULT 0      COMMENT '操作时间',
            CONSTRAINT `pk_player_item_log` PRIMARY KEY (`id`)
        )
        COMMENT       = '玩家物品日志'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';

        DROP TABLE IF EXISTS `player_ingot_log`;
        CREATE TABLE `player_ingot_log`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `player_id`             BIGINT(25)  NOT NULL                COMMENT '玩家ID',
            `value`                 INTEGER     NOT NULL DEFAULT 0      COMMENT '操作值',
            `after_value`           INTEGER     NOT NULL DEFAULT 0      COMMENT '操作后的值',
            `charge_value`          INTEGER     NOT NULL DEFAULT 0      COMMENT '操作的充值',
            `after_charge_value`    INTEGER     NOT NULL DEFAULT 0      COMMENT '操作后的充值',
            `op_type`               INTEGER     NOT NULL DEFAULT 0      COMMENT '操作类型',
            `op_time`               INTEGER     NOT NULL DEFAULT 0      COMMENT '操作时间',
            CONSTRAINT `pk_player_ingot_log` PRIMARY KEY (`id`)
        )
        COMMENT       = '玩家金币日志'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';

        DROP TABLE IF EXISTS `player_level_log`;
        CREATE TABLE `player_level_log`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `player_id`             BIGINT(25)  NOT NULL                COMMENT '玩家ID',
            `value`                 INTEGER     NOT NULL DEFAULT 0      COMMENT '操作值',
            `after_value`           INTEGER     NOT NULL DEFAULT 0      COMMENT '操作后的值',
            `op_type`               INTEGER     NOT NULL DEFAULT 0      COMMENT '操作类型',
            `op_time`               INTEGER     NOT NULL DEFAULT 0      COMMENT '操作时间',
            CONSTRAINT `pk_player_level_log` PRIMARY KEY (`id`)
        )
        COMMENT       = '玩家等级日志'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';

        DROP TABLE IF EXISTS `player_experience_log`;
        CREATE TABLE `player_experience_log`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `player_id`             BIGINT(25)  NOT NULL                COMMENT '玩家ID',
            `value`                 INTEGER     NOT NULL DEFAULT 0      COMMENT '操作值',
            `after_value`           INTEGER     NOT NULL DEFAULT 0      COMMENT '操作后的值',
            `op_type`               INTEGER     NOT NULL DEFAULT 0      COMMENT '操作类型',
            `op_time`               INTEGER     NOT NULL DEFAULT 0      COMMENT '操作时间',
            CONSTRAINT `pk_player_experience_log` PRIMARY KEY (`id`)
        )
        COMMENT       = '玩家经验日志'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';
    ");
?>