%%% %% 测试
-module (api_test_out).

-copyright  ("Copyright @2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 04, 01}).
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
    _player_id_42,
    _age_43,
    _nickname_44,
    _seat_number_45,
    _job_number_46,
    _department_47,
    _player_info_list_52,
    _player_rank_list_53
}) ->
    _nickname_44_Bin    = list_to_binary(_nickname_44),
    _nickname_44_BinLen = size(_nickname_44_Bin),

    BinList_player_info_list_52 = [
        class_to_bin(info, _player_info_list_52_Element)
        || 
        _player_info_list_52_Element <- _player_info_list_52
    ], 
    _player_info_list_52_Bin    = list_to_binary(BinList_player_info_list_52),
    _player_info_list_52_BinLen = length(_player_info_list_52),

    BinList_player_rank_list_53 = [
        api_test_out:class_to_bin(info, _player_rank_list_53_Element)
        || 
        _player_rank_list_53_Element <- _player_rank_list_53
    ], 
    _player_rank_list_53_Bin    = list_to_binary(BinList_player_rank_list_53),
    _player_rank_list_53_BinLen = length(_player_rank_list_53),

    <<
           100:16/unsigned,
        100001:16/unsigned,
        _player_id_42:64/signed,
        _age_43:08/signed,
        _nickname_44_BinLen:16/unsigned, _nickname_44_Bin/binary,
        _seat_number_45:16/signed,
        _job_number_46:32/signed,
        _department_47:32/unsigned,
        _player_info_list_52_BinLen:16/unsigned, _player_info_list_52_Bin/binary,
        _player_rank_list_53_BinLen:16/unsigned, _player_rank_list_53_Bin/binary
    >>.

get_other_player_info ({
    _player_info_77
}) ->
    _player_info_77_Bin = class_to_bin(info, _player_info_77),

    <<
           100:16/unsigned,
        100002:16/unsigned,
        _player_info_77_Bin/binary
    >>.

get_all_player_info ({
    _player_id_list_91,
    _all_player_info1_95,
    _all_player_info2_96
}) ->
    BinList_player_id_list_91 = [
        element_to_bin_91(_player_id_list_91_Element)
        || 
        _player_id_list_91_Element <- _player_id_list_91
    ], 
    _player_id_list_91_Bin    = list_to_binary(BinList_player_id_list_91),
    _player_id_list_91_BinLen = length(_player_id_list_91),

    BinList_all_player_info1_95 = [
        class_to_bin(new_info1, _all_player_info1_95_Element)
        || 
        _all_player_info1_95_Element <- _all_player_info1_95
    ], 
    _all_player_info1_95_Bin    = list_to_binary(BinList_all_player_info1_95),
    _all_player_info1_95_BinLen = length(_all_player_info1_95),

    BinList_all_player_info2_96 = [
        class_to_bin(new_info2, _all_player_info2_96_Element)
        || 
        _all_player_info2_96_Element <- _all_player_info2_96
    ], 
    _all_player_info2_96_Bin    = list_to_binary(BinList_all_player_info2_96),
    _all_player_info2_96_BinLen = length(_all_player_info2_96),

    <<
           100:16/unsigned,
        100003:16/unsigned,
        _player_id_list_91_BinLen:16/unsigned, _player_id_list_91_Bin/binary,
        _all_player_info1_95_BinLen:16/unsigned, _all_player_info1_95_Bin/binary,
        _all_player_info2_96_BinLen:16/unsigned, _all_player_info2_96_Bin/binary
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
    _player_id_7,
    _age_8,
    _nickname_9,
    _seat_number_10,
    _job_number_11,
    _department_12
}) ->
    _nickname_9_Bin    = list_to_binary(_nickname_9),
    _nickname_9_BinLen = size(_nickname_9_Bin),

    <<
        _player_id_7:64/signed,
        _age_8:08/signed,
        _nickname_9_BinLen:16/unsigned, _nickname_9_Bin/binary,
        _seat_number_10:16/signed,
        _job_number_11:32/signed,
        _department_12:32/unsigned
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
        _addr_22
    ] = ClassExtend,
    _addr_22_Bin    = list_to_binary(_addr_22),
    _addr_22_BinLen = size(_addr_22_Bin),

    <<
        ClassInherit_Bin/binary,
        _addr_22_BinLen:16/unsigned, _addr_22_Bin/binary
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
        _phone_28,
        _addr_29
    ] = ClassExtend,
    _addr_29_Bin    = list_to_binary(_addr_29),
    _addr_29_BinLen = size(_addr_29_Bin),

    <<
        ClassInherit_Bin/binary,
        _phone_28:64/signed,
        _addr_29_BinLen:16/unsigned, _addr_29_Bin/binary
    >>;
class_to_bin (_ClassName, _Class) ->
    <<>>.


%%% ========== ======================================== ====================
%%% element_to_bin_
%%% ========== ======================================== ====================

element_to_bin_91 ({
    _player_id_93
}) ->
    <<
        _player_id_93:64/signed
    >>.



%%% ========== ======================================== ====================
%%% end
%%% ========== ======================================== ====================
