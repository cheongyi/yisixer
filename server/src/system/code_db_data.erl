-module (code_db_data).

%%% @doc    生成数据到代码文件(配置)

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("WhoAreYou").
-date       ({2018, 06, 26}).
-vsn        ("1.0.0").

-compile(export_all).
-export ([

]).

-include ("define.hrl").
-include ("gen/game_db.hrl").

-define (TABLE_LIST, [
    platform,
    item
]).

-define (LOGIC_LIST, [
    platform_by_sign
]).

-define(LOGIC_INCLUDE_WHEN_LIST, [

]).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
get_table_list () ->
    ?TABLE_LIST.

get_logic_list () ->
    ?LOGIC_LIST.

get_logic_include_when_list () ->
    ?LOGIC_INCLUDE_WHEN_LIST.


%%% ========== ======================================== ====================
%%% @doc    根据标识获取平台
platform_by_sign () ->
    List = lib_ets:tab2list(?ETS_TAB(platform)),
    [
        {
            [Record #platform.sign],
            Record
        }
        ||
        Record <- List
    ].
    


%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================


