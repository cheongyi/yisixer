%%% %% 测试
-module (api_test_out).

-copyright  ("Copyright @2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 26}).
-vsn        ("1.0.0").

-export ([
    get_player_info/1,
    get_other_player_info/1,
    get_all_player_info/1,

    class_to_bin/2
]).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
get_player_info ({
    _player_id_30,
    _age_31,
    _nickname_32,
    _seat_number_33,
    _job_number_34,
    _department_35,
    _player_info_list_40,
    _player_rank_list_41
}) ->
    _nickname_32_Bin    = list_to_binary(_nickname_32),
    _nickname_32_BinLen = size(_nickname_32_Bin),

    BinList_player_info_list_40 = [
        class_to_bin(info, _player_info_list_40_Element)
        || 
        _player_info_list_40_Element <- _player_info_list_40
    ], 
    _player_info_list_40_Bin    = list_to_binary(BinList_player_info_list_40),
    _player_info_list_40_BinLen = length(_player_info_list_40),

    BinList_player_rank_list_41 = [
        api_rank_out:class_to_bin(info, _player_rank_list_41_Element)
        || 
        _player_rank_list_41_Element <- _player_rank_list_41
    ], 
    _player_rank_list_41_Bin    = list_to_binary(BinList_player_rank_list_41),
    _player_rank_list_41_BinLen = length(_player_rank_list_41),

    <<
           100:16/unsigned,
        100001:16/unsigned,
        _player_id_30:64/signed,
        _age_31:08/signed,
        _nickname_32_BinLen:16/unsigned, _nickname_32_Bin/binary,
        _seat_number_33:16/signed,
        _job_number_34:32/signed,
        _department_35:32/unsigned,
        _player_info_list_40_BinLen:16/unsigned, _player_info_list_40_Bin/binary,
        _player_rank_list_41_BinLen:16/unsigned, _player_rank_list_41_Bin/binary
    >>.

get_other_player_info ({
    _player_id_55,
    _player_info_56
}) ->
    _player_info_56_Bin = class_to_bin(info, _player_info_56),

    <<
           100:16/unsigned,
        100002:16/unsigned,
        _player_id_55:64/signed,
        _player_info_56_Bin/binary
    >>.

get_all_player_info ({
    _all_player_info_70
}) ->
    BinList_all_player_info_70 = [
        element_to_bin_70(_all_player_info_70_Element)
        || 
        _all_player_info_70_Element <- _all_player_info_70
    ], 
    _all_player_info_70_Bin    = list_to_binary(BinList_all_player_info_70),
    _all_player_info_70_BinLen = length(_all_player_info_70),

    <<
           100:16/unsigned,
        100003:16/unsigned,
        _all_player_info_70_BinLen:16/unsigned, _all_player_info_70_Bin/binary
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
class_to_bin (_ClassName, _Class) ->
    <<>>.


%%% ========== ======================================== ====================
%%% element_to_bin_
%%% ========== ======================================== ====================

element_to_bin_70 ({
    _player_id_72,
    _age_73,
    _nickname_74,
    _seat_number_75,
    _job_number_76,
    _department_77
}) ->
    _nickname_74_Bin    = list_to_binary(_nickname_74),
    _nickname_74_BinLen = size(_nickname_74_Bin),

    <<
        _player_id_72:64/signed,
        _age_73:08/signed,
        _nickname_74_BinLen:16/unsigned, _nickname_74_Bin/binary,
        _seat_number_75:16/signed,
        _job_number_76:32/signed,
        _department_77:32/unsigned
    >>.



%%% ========== ======================================== ====================
%%% end
%%% ========== ======================================== ====================
