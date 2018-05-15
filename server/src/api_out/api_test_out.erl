-module (api_test_out).

%%% @doc    

-copyright  ("Copyright © 2017-2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 05, 15}).
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
    _player_id_74,
    _age_75,
    _nickname_76,
    _seat_number_77,
    _job_number_78,
    _department_79,
    _player_info_list_84,
    _player_rank_list_85
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _nickname_76_Bin     = list_to_binary(_nickname_76),
    _nickname_76_BinSize = size(_nickname_76_Bin),
    %%% ---------- ---------------------------------------- --------------------
    _player_info_list_84_ListLen = length(_player_info_list_84),
    BinList_player_info_list_84  = [
        class_to_bin(info, _player_info_list_84_Element)
        || 
        _player_info_list_84_Element <- _player_info_list_84
    ], 
    _player_info_list_84_Bin     = list_to_binary(BinList_player_info_list_84),
    %%% ---------- ---------------------------------------- --------------------
    _player_rank_list_85_ListLen = length(_player_rank_list_85),
    BinList_player_rank_list_85  = [
        test:class_to_bin(info, _player_rank_list_85_Element)
        || 
        _player_rank_list_85_Element <- _player_rank_list_85
    ], 
    _player_rank_list_85_Bin     = list_to_binary(BinList_player_rank_list_85),
    %%% ---------- ---------------------------------------- --------------------
    <<
           999:16/unsigned,
        100001:16/unsigned,
        _player_id_74:64/unsigned,
        _age_75:08/unsigned,
        _nickname_76_BinSize:16/unsigned, _nickname_76_Bin/binary,
        _seat_number_77:16/unsigned,
        _job_number_78:32/unsigned,
        _department_79:32/unsigned,
        _player_info_list_84_ListLen:16/unsigned, _player_info_list_84_Bin/binary,
        _player_rank_list_85_ListLen:16/unsigned, _player_rank_list_85_Bin/binary
    >>.


%%% @doc    获取玩家信息
get_other_player_info ({
    _player_info_110
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _player_info_110_Bin = class_to_bin(info, _player_info_110),
    %%% ---------- ---------------------------------------- --------------------
    <<
           999:16/unsigned,
        100002:16/unsigned,
        _player_info_110_Bin/binary
    >>.


%%% @doc    获取玩家信息
get_all_player_info ({
    _player_id_list_129,
    _all_player_info1_133,
    _all_player_info2_134
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _player_id_list_129_ListLen = length(_player_id_list_129),
    BinList_player_id_list_129  = [
        tuple_to_bin_129(_player_id_list_129_Element)
        || 
        _player_id_list_129_Element <- _player_id_list_129
    ], 
    _player_id_list_129_Bin     = list_to_binary(BinList_player_id_list_129),
    %%% ---------- ---------------------------------------- --------------------
    _all_player_info1_133_ListLen = length(_all_player_info1_133),
    BinList_all_player_info1_133  = [
        class_to_bin(new_info1, _all_player_info1_133_Element)
        || 
        _all_player_info1_133_Element <- _all_player_info1_133
    ], 
    _all_player_info1_133_Bin     = list_to_binary(BinList_all_player_info1_133),
    %%% ---------- ---------------------------------------- --------------------
    _all_player_info2_134_ListLen = length(_all_player_info2_134),
    BinList_all_player_info2_134  = [
        class_to_bin(new_info2, _all_player_info2_134_Element)
        || 
        _all_player_info2_134_Element <- _all_player_info2_134
    ], 
    _all_player_info2_134_Bin     = list_to_binary(BinList_all_player_info2_134),
    %%% ---------- ---------------------------------------- --------------------
    <<
           999:16/unsigned,
        100003:16/unsigned,
        _player_id_list_129_ListLen:16/unsigned, _player_id_list_129_Bin/binary,
        _all_player_info1_133_ListLen:16/unsigned, _all_player_info1_133_Bin/binary,
        _all_player_info2_134_ListLen:16/unsigned, _all_player_info2_134_Bin/binary
    >>.


%%% @doc    标识功能开放提示已播放
sign_play_player_function ({}) ->
    <<
           999:16/unsigned,
        100004:16/unsigned
    >>.


%%% @doc    jiekou_test
jiekou_test ({}) ->
    <<
           999:16/unsigned,
        100099:16/unsigned
    >>.


%%% ========== ======================================== ====================
%%% class_to_bin
%%% ========== ======================================== ====================
%%% @doc    文字错误信息
class_to_bin (info, {
    _player_id_39,
    _age_40,
    _nickname_41,
    _seat_number_42,
    _job_number_43,
    _department_44
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _nickname_41_Bin     = list_to_binary(_nickname_41),
    _nickname_41_BinSize = size(_nickname_41_Bin),
    %%% ---------- ---------------------------------------- --------------------
    <<
        _player_id_39:64/unsigned,
        _age_40:08/unsigned,
        _nickname_41_BinSize:16/unsigned, _nickname_41_Bin/binary,
        _seat_number_42:16/unsigned,
        _job_number_43:32/unsigned,
        _department_44:32/unsigned
    >>;
%%% @doc    新信息1
class_to_bin (new_info1, {
    _addr_54
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _addr_54_Bin     = list_to_binary(_addr_54),
    _addr_54_BinSize = size(_addr_54_Bin),
    %%% ---------- ---------------------------------------- --------------------
    <<
        _addr_54_BinSize:16/unsigned, _addr_54_Bin/binary
    >>;
%%% @doc    新信息2
class_to_bin (new_info2, {
    _phone_60,
    _addr_61
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _addr_61_Bin     = list_to_binary(_addr_61),
    _addr_61_BinSize = size(_addr_61_Bin),
    %%% ---------- ---------------------------------------- --------------------
    <<
        _phone_60:64/unsigned,
        _addr_61_BinSize:16/unsigned, _addr_61_Bin/binary
    >>;
%%% @doc    其他类|空类|通配
class_to_bin (_ClassName, _Class) ->
    <<>>.


%%% ========== ======================================== ====================
%%% tuple_to_bin_
%%% ========== ======================================== ====================
%%% @doc    玩家ID列表
tuple_to_bin_129 ({
    _player_id_131
}) ->
    %%% ---------- ---------------------------------------- --------------------
    <<
        _player_id_131:64/unsigned
    >>.


%%% ========== ======================================== ====================
%%% end
%%% ========== ======================================== ====================