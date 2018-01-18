<?php
    execute("
        CREATE TABLE `db_version`
        (
            `version`               INTEGER     NOT NULL DEFAULT 0      COMMENT '版本号',
            CONSTRAINT `pk_db_version` PRIMARY KEY (`version`)
        )
        COMMENT       = '数据库版本'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';

        DROP TABLE IF EXISTS `item`;
        CREATE TABLE `item`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `sign`                  VARCHAR(50) NOT NULL DEFAULT ''     COMMENT '标识',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            `type`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '类型:0玩家|1联盟',
            CONSTRAINT `pk_item` PRIMARY KEY (`id`)
        )
        COMMENT       = '物品'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';

        DROP TABLE IF EXISTS `log_type`;
        CREATE TABLE `log_type`
        (
            `id`                    INTEGER     NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `sign`                  VARCHAR(50) NOT NULL DEFAULT ''     COMMENT '标识',
            `name`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '名称',
            `type`                  INTEGER     NOT NULL DEFAULT 0      COMMENT '类型:0玩家|1联盟',
            CONSTRAINT `pk_log_type` PRIMARY KEY (`id`)
        )
        COMMENT       = '日志类型'
        ENGINE        = 'InnoDB'
        CHARACTER SET = 'utf8'
        COLLATE       = 'utf8_general_ci';


        DROP TABLE IF EXISTS `player_dragon_provocation`;
        CREATE TABLE `player_dragon_provocation`
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
            CONSTRAINT `pk_player_dragon_provocation` PRIMARY KEY (`player_id`)
        )
        COMMENT       = '玩家'
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
?>