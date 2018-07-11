// 协议文本说明
// 模块注释
module = 999        // 模块名 = 模块ID
{
    // 类注释
    // class   item_info :: item.item_info  // class类定义 类名 ::类继承 [模块.]类名称
    class   item_info
    {
        player_item_id      : int       // 玩家物品ID
        item_id             : int       // 物品ID
        number              : int       // 物品数量
    }

    // 接口注释
    action = 99901  // 接口名 = 接口ID(999 ++ 01)
    {
        in          // 客户端请求服务端(C => S 参数可空)
        {
            hash_code           : string    // string   字符串型 - 以0结尾
        }

        out         // 服务端返回客户端(S => C 参数可空)
        {
            result              : enum      // enum     (4个字节)枚举
            vip_level           : byte      // byte     (1个字节)字节型
            level               : short     // byte     (2个字节)短整型
            player_id           : int       // int      (4个字节)基本整型
            player_id           : long      // byte     (8个字节)长整型
            info                : typeof<item_info> // typeof   类型  - 单个类的组合
            infos               : list<item_info>   // list     列表  - 多个类或字段的集合
            infos_2             : list
            {
                item_id             : int       // 物品ID
                number              : int       // 物品数量
            }
        }
    }
}