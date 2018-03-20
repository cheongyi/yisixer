#!/usr/bin/python3
# coding: UTF-8
import pymysql


# 打开数据库连接
db = pymysql.connect(host='127.0.0.1', port=3306, user='root', passwd='wlwlwl', db='gamedb', charset='utf8')

file = open("./game_db.hrl", 'w', encoding='utf-8')
# 使用 cursor() 方法创建一个游标对象 cursor
length = 80

def create_def(tabname, info, char):
    cursor = db.cursor()
    tabselect = "select * from " + tabname
    cursor.execute(tabselect)
    for row in cursor.fetchall():
        id = row[0]
        sign = row[1]
        name = row[2]
        all_length = len(sign.upper()) + 2 * len(str(id)) + len(info)
        file.write("-defined(?%s_%s_%d, %d)." % (info, sign.upper(), id, id))
        newlength = max([0, length - all_length])
        for j in range(newlength):
            file.write(" ")
        file.write("% {:^2} - {:} \n".format(char, name))
    file.write("\n")

def create_def_sort(tabname, info, char):
    cursor = db.cursor()
    tabselect = "select * from " + tabname + " ORDER BY `data` asc"
    cursor.execute(tabselect)
    for row in cursor.fetchall():
        sign = row[1]
        name = row[2]
        data = row[3]
        newdata = 0
        if int(data) == data:
            newdata = int(data)
        else:
            newdata = data
        all_length = len(sign.upper()) + len(str(newdata)) + len(info)
        file.write("-defined(?%s_%s, %s)." % (info, sign.upper(), newdata))
        newlength = max([0, length - all_length])
        for j in range(newlength):
            file.write(" ")
        file.write("% {:^2} - {:} \n".format(char, name))
    file.write("\n")

def create_def_building(tabname, info, char):
    cursor = db.cursor()
    tabselect = "select id, sign, name from " + tabname
    cursor.execute(tabselect)
    for row in cursor.fetchall():
        id = row[0]
        sign = row[1]
        name = row[2]
        all_length = len(sign.upper()) + 2 * len(str(id)) + len(info)
        file.write("-defined(?%s_%s_%d, %d)." % (info, sign.upper(), id, id))
        newlength = max([0, length - all_length])
        for j in range(newlength):
            file.write(" ")
        file.write("% {:^2} - {:} \n".format(char, name))
    file.write("\n")

def create_def_union(tabname, info, char):
    cursor = db.cursor()
    tabselect = "select id, sign, type_comment from " + tabname
    cursor.execute(tabselect)
    for row in cursor.fetchall():
        id = row[0]
        sign = row[1]
        name = row[2]
        all_length = len(sign.upper()) + 2 * len(str(id)) + len(info)
        file.write("-defined(?%s_%s_%d, %d)." % (info, sign.upper(), id, id))
        newlength = max([0, length - all_length])
        for j in range(newlength):
            file.write(" ")
        file.write("% {:^2} - {:} \n".format(char, name))
    file.write("\n")

def create_def_lord_skill(tabname, info, char):
    cursor = db.cursor()
    tabselect = "select * from " + tabname
    cursor.execute(tabselect)
    for row in cursor.fetchall():
        id = row[0]
        sign = row[-1]
        name = row[3]
        all_length = len(sign.upper()) + 2 * len(str(id)) + len(info)
        file.write("-defined(?%s_%s_%d, %d)." % (info, sign.upper(), id, id))
        newlength = max([0, length - all_length])
        for j in range(newlength):
            file.write(" ")
        file.write("% {:^2} - {:} \n".format(char, name))
    file.write("\n")

def create_def_activity_center(tabname, info, char):
    cursor = db.cursor()
    tabselect = "select * from " + tabname
    cursor.execute(tabselect)
    for row in cursor.fetchall():
        id = row[0]
        sign = row[-1]
        name = row[3]
        all_length = len(sign.upper()) + 2 * len(str(id)) + len(info)
        file.write("-defined(?%s_%s_%d, %d)." % (info, sign.upper(), id, id))
        newlength = max([0, length - all_length])
        for j in range(newlength):
            file.write(" ")
        file.write("% {:^2} - {:} \n".format(char, name))
    file.write("\n")

# 生成各种枚举
create_def("abnormal_record_type", "ART", "异常枚举字段")
create_def("delay_notify_message_template", "DNMT", "延迟通知信息")
create_def("server_data_type", "SDT", "公共数据")
create_def("ingot_change_type", "INGOTCT", "元宝变动类型")
create_def("coin_change_type", "CCT", "铜币变动类型")
create_def("st_ranking_type", "SRT", "排行榜类型")
create_def("power_log_type", "PLT", "体力变动类型")
create_def_sort("constant", "CONSTANT", "常量")
create_def("wood_change_type", "WOODCT", "木材变动类型")
create_def("meat_change_type", "MEATCT", "肉变动类型")
create_def("stone_change_type", "STONECT", "石头变动类型")
create_def("iron_change_type", "IRONCT", "铁变动类型")
create_def("steel_change_type", "STEELCT", "钢变动类型")
create_def_building("building_type", "BUILDING_TYPE", "建筑类型")
create_def_building("item", "I", "物品")
create_def_building("item_type", "IT", "物品类型")
create_def_building("item_change_type", "ICT", "物品变动类型")
create_def_building("science_type", "ST", "科技类型")
create_def("dragon_coin_change_type", "DCCT", "龙币变动类型")
create_def_building("quest_event", "QET", "任务事件类型")
create_def_building("mail_type", "MT", "邮件类型")
create_def_building("effect_type", "ET", "效果类型")
create_def_union("union_event_type", "UET", "联盟事件类型")
create_def_lord_skill("lord_skill_type", "LST", "领主技能类型")
create_def_activity_center("activity_center", "A", "活动中心类型")


def create_record():
    cursor = db.cursor()
    # 写所有值的record
    cursor.execute("SELECT table_name FROM information_schema.tables where TABLE_TYPE = 'BASE TABLE' and "
                   "TABLE_SCHEMA = 'gamedb' and TABLE_NAME != \"db_version\"")
    all_tb = cursor.fetchall()
    for row in all_tb:
        tbname = row[0]
        cursor.execute("select COLUMN_NAME, COLUMN_DEFAULT, COLUMN_COMMENT, COLUMN_TYPE from INFORMATION_SCHEMA.Columns "
                       "where table_schema='gamedb' and table_name = " + "\"%s\""%tbname)
        all_column = cursor.fetchall()
        file.write("-record(%s, {\n" % tbname)
        file.write("\trow_key,\n")
        for j in all_column:
            filed = j[0]
            default = j[1]
            comment = j[2]
            column_type = j[3]
            string = 0
            length = 30
            already = 0
            # 无缺省值 null 有缺省显示缺省
            if str(default) == "None":
                string = "\t%s = %s," % (filed, "null")
            elif len(str(default)) == 0:
                string = "\t%s = \"\"," % (filed)
            else:
                newtype = "\"%s\""%(column_type)
                if (newtype == "\"int(11)\"") or (newtype == "\"float\""):
                    string = "\t%s = %s," % (filed, default)
                else:
                    string = "\t%s = %s," % (filed, "\"%s\""%(default))
            file.write(string)
            already = len(string)
            rest = max([0, length - already])
            for k in range(rest):
                file.write(" ")
            file.write("%%\t%s\n" % comment)

        file.write("\trow_ver = 0\n")
        file.write("}).\n")

        # 写主键的record
        cursor.execute("SELECT b.COLUMN_NAME FROM information_schema.tables as a, information_schema.KEY_COLUMN_USAGE as b "
                       "where a.TABLE_TYPE = 'BASE TABLE' and a.TABLE_SCHEMA = 'gamedb' and b.TABLE_NAME = a.TABLE_NAME "
                       "and a.TABLE_NAME = " + "\"%s\"" % tbname)
        primarykey = cursor.fetchall()
        length = len(primarykey)
        curlength = 0
        string = 0
        file.write("-record(pk_%s, {\n" % tbname)
        for l in primarykey:
            filed = l[0]
            if length - 1 > curlength:
                string = "\t%s," % (filed)
                curlength = curlength + 1
            else:
                string = "\t%s" % (filed)
            file.write("%s\n" % string)
        already = len(string)
        rest = max([0, length - already])
        for k in range(rest):
            file.write(" ")
        file.write("}).\n\n")


create_record()

print("record生成完毕\n")

file.close()

# 关闭数据库连接
db.close()