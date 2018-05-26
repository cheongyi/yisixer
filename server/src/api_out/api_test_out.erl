-module (api_test_out).

%%% @doc    

-copyright  ("Copyright © 2017-2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 05, 26}).
-vsn        ("1.0.0").

-export ([
    get_player_info/1,
    get_other_player_info/1,
    get_all_player_info/1,
    sign_play_player_function/1,
    jiekou_test/1,

    class_to_bin/2
]).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    获取玩家信息
get_player_info ({
    _player_id_43,
    _age_44,
    _nickname_45,
    _seat_number_46,
    _job_number_47,
    _department_48,
    _player_info_list_53,
    _player_rank_list_54
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _nickname_45_Bin     = list_to_binary(_nickname_45),
    _nickname_45_BinSize = size(_nickname_45_Bin),
    %%% ---------- ---------------------------------------- --------------------
    _player_info_list_53_ListLen = length(_player_info_list_53),
    BinList_player_info_list_53  = [
        class_to_bin(info, _player_info_list_53_Element)
        || 
        _player_info_list_53_Element <- _player_info_list_53
    ], 
    _player_info_list_53_Bin     = list_to_binary(BinList_player_info_list_53),
    %%% ---------- ---------------------------------------- --------------------
    _player_rank_list_54_ListLen = length(_player_rank_list_54),
    BinList_player_rank_list_54  = [
        test:class_to_bin(info, _player_rank_list_54_Element)
        || 
        _player_rank_list_54_Element <- _player_rank_list_54
    ], 
    _player_rank_list_54_Bin     = list_to_binary(BinList_player_rank_list_54),
    %%% ---------- ---------------------------------------- --------------------
    <<
           999:16/unsigned,
        999001:16/unsigned,
        _player_id_43:64/unsigned,
        _age_44:08/unsigned,
        _nickname_45_BinSize:16/unsigned, _nickname_45_Bin/binary,
        _seat_number_46:16/unsigned,
        _job_number_47:32/unsigned,
        _department_48:32/unsigned,
        _player_info_list_53_ListLen:16/unsigned, _player_info_list_53_Bin/binary,
        _player_rank_list_54_ListLen:16/unsigned, _player_rank_list_54_Bin/binary
    >>.


%%% @doc    获取玩家信息
get_other_player_info ({
    _player_info_79
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _player_info_79_Bin = class_to_bin(info, _player_info_79),
    %%% ---------- ---------------------------------------- --------------------
    <<
           999:16/unsigned,
        999002:16/unsigned,
        _player_info_79_Bin/binary
    >>.


%%% @doc    获取玩家信息
get_all_player_info ({
    _player_id_list_98,
    _all_player_info1_102,
    _all_player_info2_103
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _player_id_list_98_ListLen = length(_player_id_list_98),
    BinList_player_id_list_98  = [
        tuple_to_bin_98(_player_id_list_98_Element)
        || 
        _player_id_list_98_Element <- _player_id_list_98
    ], 
    _player_id_list_98_Bin     = list_to_binary(BinList_player_id_list_98),
    %%% ---------- ---------------------------------------- --------------------
    _all_player_info1_102_ListLen = length(_all_player_info1_102),
    BinList_all_player_info1_102  = [
        class_to_bin(new_info1, _all_player_info1_102_Element)
        || 
        _all_player_info1_102_Element <- _all_player_info1_102
    ], 
    _all_player_info1_102_Bin     = list_to_binary(BinList_all_player_info1_102),
    %%% ---------- ---------------------------------------- --------------------
    _all_player_info2_103_ListLen = length(_all_player_info2_103),
    BinList_all_player_info2_103  = [
        class_to_bin(new_info2, _all_player_info2_103_Element)
        || 
        _all_player_info2_103_Element <- _all_player_info2_103
    ], 
    _all_player_info2_103_Bin     = list_to_binary(BinList_all_player_info2_103),
    %%% ---------- ---------------------------------------- --------------------
    <<
           999:16/unsigned,
        999003:16/unsigned,
        _player_id_list_98_ListLen:16/unsigned, _player_id_list_98_Bin/binary,
        _all_player_info1_102_ListLen:16/unsigned, _all_player_info1_102_Bin/binary,
        _all_player_info2_103_ListLen:16/unsigned, _all_player_info2_103_Bin/binary
    >>.


%%% @doc    标识功能开放提示已播放
sign_play_player_function ({}) ->
    <<
           999:16/unsigned,
        999004:16/unsigned
    >>.


%%% @doc    jiekou_test
jiekou_test ({}) ->
    <<
           999:16/unsigned,
        999099:16/unsigned
    >>.


%%% ========== ======================================== ====================
%%% class_to_bin
%%% ========== ======================================== ====================
%%% @doc    信息
class_to_bin (info, {
    _player_id_8,
    _age_9,
    _nickname_10,
    _seat_number_11,
    _job_number_12,
    _department_13
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _nickname_10_Bin     = list_to_binary(_nickname_10),
    _nickname_10_BinSize = size(_nickname_10_Bin),
    %%% ---------- ---------------------------------------- --------------------
    <<
        _player_id_8:64/unsigned,
        _age_9:08/unsigned,
        _nickname_10_BinSize:16/unsigned, _nickname_10_Bin/binary,
        _seat_number_11:16/unsigned,
        _job_number_12:32/unsigned,
        _department_13:32/unsigned
    >>;
%%% @doc    新信息1
class_to_bin (new_info1, {
    _addr_23
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _addr_23_Bin     = list_to_binary(_addr_23),
    _addr_23_BinSize = size(_addr_23_Bin),
    %%% ---------- ---------------------------------------- --------------------
    <<
        _addr_23_BinSize:16/unsigned, _addr_23_Bin/binary
    >>;
%%% @doc    新信息2
class_to_bin (new_info2, {
    _phone_29,
    _addr_30
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _addr_30_Bin     = list_to_binary(_addr_30),
    _addr_30_BinSize = size(_addr_30_Bin),
    %%% ---------- ---------------------------------------- --------------------
    <<
        _phone_29:64/unsigned,
        _addr_30_BinSize:16/unsigned, _addr_30_Bin/binary
    >>;
%%% @doc    其他类|空类|通配
class_to_bin (_ClassName, _Class) ->
    <<>>.


%%% ========== ======================================== ====================
%%% tuple_to_bin_
%%% ========== ======================================== ====================
%%% @doc    玩家ID列表
tuple_to_bin_98 ({
    _player_id_100
}) ->
    %%% ---------- ---------------------------------------- --------------------
    <<
        _player_id_100:64/unsigned
    >>.


%%% ========== ======================================== ====================
%%% end
%%% ========== ======================================== ====================