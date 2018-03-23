-module (api_test_out).

-copyright  ("Copyright © 2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 22}).
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
    _player_id_29,
    _age_30,
    _nickname_31,
    _seat_number_32,
    _job_number_33,
    _department_34,
    _player_info_list_39,
    _player_rank_list_40
}) ->
    _nickname_31_Bin    = list_to_binary(_nickname_31),
    _nickname_31_BinLen = size(_nickname_31_Bin),

    BinList_player_info_list_39 = [
        class_to_bin(info, _player_info_list_39_Element)
        || 
        _player_info_list_39_Element <- _player_info_list_39
    ], 
    _player_info_list_39_Bin    = list_to_binary(BinList_player_info_list_39),
    _player_info_list_39_BinLen = size(_player_info_list_39_Bin),

    BinList_player_rank_list_40 = [
        rank:class_to_bin(info, _player_rank_list_40_Element)
        || 
        _player_rank_list_40_Element <- _player_rank_list_40
    ], 
    _player_rank_list_40_Bin    = list_to_binary(BinList_player_rank_list_40),
    _player_rank_list_40_BinLen = size(_player_rank_list_40_Bin),

    <<
           100:16/unsigned,
        100001:16/unsigned,
        _player_id_29:64/unsigned,
        _age_30:8/unsigned,
        _nickname_31_BinLen:16/unsigned, _nickname_31_Bin/binary,
        _seat_number_32:16/unsigned,
        _job_number_33:32/unsigned,
        _department_34:8/unsigned,
        _player_info_list_39_BinLen:16/unsigned, _player_info_list_39_Bin/binary,
        _player_rank_list_40_BinLen:16/unsigned, _player_rank_list_40_Bin/binary
    >>.

get_other_player_info ({
    _player_id_54,
    _player_info_55
}) ->
    _player_info_55_Bin = class_to_bin(info, _player_info_55),

    <<
           100:16/unsigned,
        100002:16/unsigned,
        _player_id_54:64/unsigned,
        _player_info_55_Bin/binary
    >>.

get_all_player_info ({
    _all_player_info_69
}) ->
    BinList_all_player_info_69 = [
        element_to_bin_69(_all_player_info_69_Element)
        || 
        _all_player_info_69_Element <- _all_player_info_69
    ], 
    _all_player_info_69_Bin    = list_to_binary(BinList_all_player_info_69),
    _all_player_info_69_BinLen = size(_all_player_info_69_Bin),

    <<
           100:16/unsigned,
        100003:16/unsigned,
        _all_player_info_69_BinLen:16/unsigned, _all_player_info_69_Bin/binary
    >>.


%%% ========== ======================================== ====================
%%% class_to_bin
%%% ========== ======================================== ====================
class_to_bin (info, {
    _player_id_6,
    _age_7,
    _nickname_8,
    _seat_number_9,
    _job_number_10,
    _department_11
}) ->
    _nickname_8_Bin    = list_to_binary(_nickname_8),
    _nickname_8_BinLen = size(_nickname_8_Bin),

    <<,
        _player_id_6:64/unsigned,
        _age_7:8/unsigned,
        _nickname_8_BinLen:16/unsigned, _nickname_8_Bin/binary,
        _seat_number_9:16/unsigned,
        _job_number_10:32/unsigned,
        _department_11:8/unsigned
    >>;
class_to_bin (_ClassName, _Class) ->
    <<>>.


%%% ========== ======================================== ====================
%%% element_to_bin_
%%% ========== ======================================== ====================
element_to_bin_69 ({
    _player_id_71,
    _age_72,
    _nickname_73,
    _seat_number_74,
    _job_number_75,
    _department_76
}) ->
    _nickname_73_Bin    = list_to_binary(_nickname_73),
    _nickname_73_BinLen = size(_nickname_73_Bin),

    <<,
        _player_id_71:64/unsigned,
        _age_72:8/unsigned,
        _nickname_73_BinLen:16/unsigned, _nickname_73_Bin/binary,
        _seat_number_74:16/unsigned,
        _job_number_75:32/unsigned,
        _department_76:8/unsigned
    >>;


%%% ========== ======================================== ====================
%%% end
%%% ========== ======================================== ====================
