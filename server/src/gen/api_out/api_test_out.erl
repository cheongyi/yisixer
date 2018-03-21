-module (api_test_out).

-copyright  ("Copyright © 2018 YiSiXEr").
-author     ("CHEONGYI").
-date       ({2018, 03, 21}).
-vsn        ("1.0.0").

-export ([
    get_all_player_info/1,
    get_other_player_info/1,
    get_player_info/1
]).


%%% ========== ======================================== ====================
get_all_player_info ({
}) ->
    <<
           100:16/unsigned,
        000003:16/unsigned
    >>.

get_other_player_info ({
    _player_id_39
}) ->
    <<
           100:16/unsigned,
        000002:16/unsigned,
        _player_id_39:64/unsigned
    >>.

get_player_info ({
    _player_id_25
}) ->
    <<
           100:16/unsigned,
        000001:16/unsigned,
        _player_id_25:64/unsigned
    >>.

