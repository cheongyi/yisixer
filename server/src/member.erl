-module (member).

%%% @doc    判断一个数字在不在N个整数中

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("WhoAreYou").
-date       ({2019, 07, 07}).
-vsn        ("1.0.0").

-export ([gen_config/1]).
-export ([check/1]).

-include ("define.hrl").
% -include ("record.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    判断这个数是否在配置里面
check (Number) ->
    List    = number_config:get_number_list(Number),
    lists:member(Number, List).

%%% @doc    生成配置
gen_config (GenNumber) when GenNumber >= 1 andalso GenNumber =< 1000000 ->
    {ok, File} = file:open("src/number_config.erl", [write]),
    file:write(File, "-module (number_config).\n"),
    file:write(File, "
-copyright  (\"Copyright @2019 Tools@YiSiXEr\").
-author     (\"WhoAreYou\").
-date       ({2019, 07, 07}).
-vsn        (\"1.0.0\").\n"),
    file:write(File, "
-export ([get_number_list/1]).\n\n"),
    file:write(File, "
%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ===================="),
    loop_gen_config(File, 1, GenNumber),
    file:write(File, "
get_number_list (_) ->
    []."),
    ok.

loop_gen_config (File, GenNumber, GenNumber) ->
    MinNumber   = integer_to_list(GenNumber),
    MaxNumber   = integer_to_list(GenNumber + 10000 - 1),
    file:write(File, "
get_number_list (Number) when Number >= " ++ MinNumber ++ " andalso Number =< " ++ MaxNumber ++ " ->
    [" ++ integer_to_list(GenNumber) ++ "];"),
    GenNumber;
loop_gen_config (File, Number, GenNumber) when Number < GenNumber->
    MinNumber   = integer_to_list(Number),
    MaxNumber   = integer_to_list(Number + 10000 - 1),
    file:write(File, "
get_number_list (Number) when Number >= " ++ MinNumber ++ " andalso Number =< " ++ MaxNumber ++ " ->
    [
" ++ integer_to_list(Number)),
    NewGenNumber    = min(GenNumber, Number + 10000 - 1),
    NewNumber       = loop_gen_config_4(File, Number + 1, NewGenNumber),
    loop_gen_config(File, NewNumber, GenNumber);
loop_gen_config (_File, _Number, GenNumber) ->
    GenNumber.

loop_gen_config_4 (File, MaxGenNumber, MaxGenNumber) ->
    file:write(File, ", " ++ integer_to_list(MaxGenNumber) ++ "
    ];"),
    MaxGenNumber + 1;
loop_gen_config_4 (File, Number, MaxGenNumber) ->
    case (Number - 1) rem 10 of
        0 -> file:write(File, ",\n" ++ integer_to_list(Number));
        _ -> file:write(File, ", "  ++ integer_to_list(Number))
    end,
    loop_gen_config_4(File, Number + 1, MaxGenNumber).

