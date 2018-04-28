%%% %% 测试
-module (api_test_out).

-copyright  ("Copyright @2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 04, 28}).
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
    _nickname_45_Bin    = list_to_binary(_nickname_45),
    _nickname_45_BinLen = size(_nickname_45_Bin),

    BinList_player_info_list_53 = [
        class_to_bin(info, _player_info_list_53_Element)
        || 
        _player_info_list_53_Element <- _player_info_list_53
    ], 
    _player_info_list_53_Bin    = list_to_binary(BinList_player_info_list_53),
    _player_info_list_53_BinLen = length(_player_info_list_53),

    BinList_player_rank_list_54 = [
        api_test_out:class_to_bin(info, _player_rank_list_54_Element)
        || 
        _player_rank_list_54_Element <- _player_rank_list_54
    ], 
    _player_rank_list_54_Bin    = list_to_binary(BinList_player_rank_list_54),
    _player_rank_list_54_BinLen = length(_player_rank_list_54),

    <<
           100:16/unsigned,
        100001:16/unsigned,
        _player_id_43:64/signed,
        _age_44:08/signed,
        _nickname_45_BinLen:16/unsigned, _nickname_45_Bin/binary,
        _seat_number_46:16/signed,
        _job_number_47:32/signed,
        _department_48:32/unsigned,
        _player_info_list_53_BinLen:16/unsigned, _player_info_list_53_Bin/binary,
        _player_rank_list_54_BinLen:16/unsigned, _player_rank_list_54_Bin/binary
    >>.

get_other_player_info ({
    _player_info_78
}) ->
    _player_info_78_Bin = class_to_bin(info, _player_info_78),

    <<
           100:16/unsigned,
        100002:16/unsigned,
        _player_info_78_Bin/binary
    >>.

get_all_player_info ({
    _player_id_list_92,
    _all_player_info1_96,
    _all_player_info2_97
}) ->
    BinList_player_id_list_92 = [
        element_to_bin_92(_player_id_list_92_Element)
        || 
        _player_id_list_92_Element <- _player_id_list_92
    ], 
    _player_id_list_92_Bin    = list_to_binary(BinList_player_id_list_92),
    _player_id_list_92_BinLen = length(_player_id_list_92),

    BinList_all_player_info1_96 = [
        class_to_bin(new_info1, _all_player_info1_96_Element)
        || 
        _all_player_info1_96_Element <- _all_player_info1_96
    ], 
    _all_player_info1_96_Bin    = list_to_binary(BinList_all_player_info1_96),
    _all_player_info1_96_BinLen = length(_all_player_info1_96),

    BinList_all_player_info2_97 = [
        class_to_bin(new_info2, _all_player_info2_97_Element)
        || 
        _all_player_info2_97_Element <- _all_player_info2_97
    ], 
    _all_player_info2_97_Bin    = list_to_binary(BinList_all_player_info2_97),
    _all_player_info2_97_BinLen = length(_all_player_info2_97),

    <<
           100:16/unsigned,
        100003:16/unsigned,
        _player_id_list_92_BinLen:16/unsigned, _player_id_list_92_Bin/binary,
        _all_player_info1_96_BinLen:16/unsigned, _all_player_info1_96_Bin/binary,
        _all_player_info2_97_BinLen:16/unsigned, _all_player_info2_97_Bin/binary
    >>.

sign_play_player_function ({

}) ->
    <<
           100:16/unsigned,
        100004:16/unsigned
    >>.

jiekou_test ({

}) ->
    <<
           100:16/unsigned,
        100099:16/unsigned
    >>.


%%% ========== ======================================== ====================
%%% class_to_bin
%%% ========== ======================================== ====================
class_to_bin (info, {
    _player_id_8,
    _age_9,
    _nickname_10,
    _seat_number_11,
    _job_number_12,
    _department_13
}) ->
    _nickname_10_Bin    = list_to_binary(_nickname_10),
    _nickname_10_BinLen = size(_nickname_10_Bin),

    <<
        _player_id_8:64/signed,
        _age_9:08/signed,
        _nickname_10_BinLen:16/unsigned, _nickname_10_Bin/binary,
        _seat_number_11:16/signed,
        _job_number_12:32/signed,
        _department_13:32/unsigned
    >>;
class_to_bin (new_info1, ClassTuple) ->
    ClassSize                   = tuple_size(ClassTuple),
    {ClassFather, ClassExtend}  = lists:split(
        ClassSize - 1,
        tuple_to_list(ClassTuple)
    ),
    ClassInherit_Bin            = api_test_out:class_to_bin(
        info, 
        list_to_tuple(ClassFather)
    ),
    [
        _addr_23
    ] = ClassExtend,
    _addr_23_Bin    = list_to_binary(_addr_23),
    _addr_23_BinLen = size(_addr_23_Bin),

    <<
        ClassInherit_Bin/binary,
        _addr_23_BinLen:16/unsigned, _addr_23_Bin/binary
    >>;
class_to_bin (new_info2, ClassTuple) ->
    ClassSize                   = tuple_size(ClassTuple),
    {ClassFather, ClassExtend}  = lists:split(
        ClassSize - 2,
        tuple_to_list(ClassTuple)
    ),
    ClassInherit_Bin            = class_to_bin(
        info, 
        list_to_tuple(ClassFather)
    ),
    [
        _phone_29,
        _addr_30
    ] = ClassExtend,
    _addr_30_Bin    = list_to_binary(_addr_30),
    _addr_30_BinLen = size(_addr_30_Bin),

    <<
        ClassInherit_Bin/binary,
        _phone_29:64/signed,
        _addr_30_BinLen:16/unsigned, _addr_30_Bin/binary
    >>;
class_to_bin (_ClassName, _Class) ->
    <<>>.


%%% ========== ======================================== ====================
%%% element_to_bin_
%%% ========== ======================================== ====================

element_to_bin_92 ({
    _player_id_94
}) ->
    <<
        _player_id_94:64/signed
    >>.



%%% ========== ======================================== ====================
%%% end
%%% ========== ======================================== ====================
