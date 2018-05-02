-module (api_test_out).

%%% @doc    

-copyright  ("Copyright © 2017-2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 05, 02}).
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
    _nickname_45_Bin    = list_to_binary(_nickname_45),
    _nickname_45_BinLen = size(_nickname_45_Bin),
    %%% ---------- ---------------------------------------- --------------------
    BinList_player_info_list_53 = [
        class_to_bin(info, _player_info_list_53_Element)
        || 
        _player_info_list_53_Element <- _player_info_list_53
    ], 
    _player_info_list_53_Bin    = list_to_binary(BinList_player_info_list_53),
    _player_info_list_53_BinLen = size(_player_info_list_53_Bin),
    %%% ---------- ---------------------------------------- --------------------
    BinList_player_rank_list_54 = [
        test:class_to_bin(info, _player_rank_list_54_Element)
        || 
        _player_rank_list_54_Element <- _player_rank_list_54
    ], 
    _player_rank_list_54_Bin    = list_to_binary(BinList_player_rank_list_54),
    _player_rank_list_54_BinLen = size(_player_rank_list_54_Bin),
    %%% ---------- ---------------------------------------- --------------------
    <<
           100:16/unsigned,
        100001:16/unsigned,
        _player_id_43:64/unsigned,
        _age_44:08/unsigned,
        _nickname_45_BinLen:16/unsigned, _nickname_45_Bin/binary,
        _seat_number_46:16/unsigned,
        _job_number_47:32/unsigned,
        _department_48:32/unsigned,
        _player_info_list_53_BinLen:16/unsigned, _player_info_list_53_Bin/binary,
        _player_rank_list_54_BinLen:16/unsigned, _player_rank_list_54_Bin/binary
    >>.


%%% @doc    获取玩家信息
get_other_player_info ({
    _player_info_78
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _player_info_78_Bin = class_to_bin(info, _player_info_78),
    %%% ---------- ---------------------------------------- --------------------
    <<
           100:16/unsigned,
        100002:16/unsigned,
        _player_info_78_Bin/binary
    >>.


%%% @doc    获取玩家信息
get_all_player_info ({
    _player_id_list_92,
    _all_player_info1_96,
    _all_player_info2_97
}) ->
    %%% ---------- ---------------------------------------- --------------------
    BinList_player_id_list_92 = [
        tuple_to_bin_92(_player_id_list_92_Element)
        || 
        _player_id_list_92_Element <- _player_id_list_92
    ], 
    _player_id_list_92_Bin    = list_to_binary(BinList_player_id_list_92),
    _player_id_list_92_BinLen = size(_player_id_list_92_Bin),
    %%% ---------- ---------------------------------------- --------------------
    BinList_all_player_info1_96 = [
        class_to_bin(new_info1, _all_player_info1_96_Element)
        || 
        _all_player_info1_96_Element <- _all_player_info1_96
    ], 
    _all_player_info1_96_Bin    = list_to_binary(BinList_all_player_info1_96),
    _all_player_info1_96_BinLen = size(_all_player_info1_96_Bin),
    %%% ---------- ---------------------------------------- --------------------
    BinList_all_player_info2_97 = [
        class_to_bin(new_info2, _all_player_info2_97_Element)
        || 
        _all_player_info2_97_Element <- _all_player_info2_97
    ], 
    _all_player_info2_97_Bin    = list_to_binary(BinList_all_player_info2_97),
    _all_player_info2_97_BinLen = size(_all_player_info2_97_Bin),
    %%% ---------- ---------------------------------------- --------------------
    <<
           100:16/unsigned,
        100003:16/unsigned,
        _player_id_list_92_BinLen:16/unsigned, _player_id_list_92_Bin/binary,
        _all_player_info1_96_BinLen:16/unsigned, _all_player_info1_96_Bin/binary,
        _all_player_info2_97_BinLen:16/unsigned, _all_player_info2_97_Bin/binary
    >>.


%%% @doc    标识功能开放提示已播放
sign_play_player_function ({}) ->
    <<
           100:16/unsigned,
        100004:16/unsigned
    >>.


%%% @doc    jiekou_test
jiekou_test ({}) ->
    <<
           100:16/unsigned,
        100099:16/unsigned
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
    _nickname_10_Bin    = list_to_binary(_nickname_10),
    _nickname_10_BinLen = size(_nickname_10_Bin),
    %%% ---------- ---------------------------------------- --------------------
    <<
        _player_id_8:64/unsigned,
        _age_9:08/unsigned,
        _nickname_10_BinLen:16/unsigned, _nickname_10_Bin/binary,
        _seat_number_11:16/unsigned,
        _job_number_12:32/unsigned,
        _department_13:32/unsigned
    >>;
%%% @doc    新信息1
class_to_bin (new_info1, {
    _addr_23
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _addr_23_Bin    = list_to_binary(_addr_23),
    _addr_23_BinLen = size(_addr_23_Bin),
    %%% ---------- ---------------------------------------- --------------------
    <<
        _addr_23_BinLen:16/unsigned, _addr_23_Bin/binary
    >>;
%%% @doc    新信息2
class_to_bin (new_info2, {
    _phone_29,
    _addr_30
}) ->
    %%% ---------- ---------------------------------------- --------------------
    _addr_30_Bin    = list_to_binary(_addr_30),
    _addr_30_BinLen = size(_addr_30_Bin),
    %%% ---------- ---------------------------------------- --------------------
    <<
        _phone_29:64/unsigned,
        _addr_30_BinLen:16/unsigned, _addr_30_Bin/binary
    >>;
%%% @doc    其他类|空类|通配
class_to_bin (_ClassName, _Class) ->
    <<>>.


%%% ========== ======================================== ====================
%%% tuple_to_bin_
%%% ========== ======================================== ====================
%%% @doc    玩家ID列表
tuple_to_bin_92 ({
    _player_id_94
}) ->
    %%% ---------- ---------------------------------------- --------------------
    <<
        _player_id_94:64/unsigned
    >>.


%%% ========== ======================================== ====================
%%% end
%%% ========== ======================================== ====================