-module (test_process).

-copyright  ("Copyright © 2019 Tools@YiSiXEr").
-author     ("CHEONGYI").
-date       ({2019, 07, 15}).
-vsn        ("1.0.0").


-ifndef(USER_DEFAULT_HELPER_H).
-define(USER_DEFAULT_HELPER_H, true).

% -ifndef(MIXER_H).
% -define(MIXER_H, true).
% -include_lib("mixer/include/mixer.hrl").
% -endif.

%% misc
-mixin([{test_process, except, [help/0]}]).

%% trace
% -mixin([{bg_trace_helper, [
%     trace/1, trace/2, trace/3, trace/4,
%     trace_pid/1, trace_pid/2, trace_pid/3, trace_pid/4, trace_pid/5
% ]}]).

% %% debug
% -mixin([{bg_log_h, [open_debug/0, close_debug/0]}]).

-endif.


-compile(export_all).
-export ([
]).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    最小堆大小的斐波那契数列
min_heap_size () ->
    min_heap_size(12, 38).
min_heap_size (Base1, Base2) when Base2 =< 833026 ->
    Base3 = 1 + Base1 + Base2,
    io:format("word : ~p = 1 + ~p + ~p~n", [Base3, Base1, Base2]),
    min_heap_size(Base2, Base3);
min_heap_size (_Base1, Base2) ->
    Base3 = Base2 * 120 div 100,
    io:format("word : ~p = ~p * 20%~n", [Base3, Base2]).

help () ->
    "co() or compile()                          -- 编译~n"
    "console_clear()                            -- 减少大多数打印~n"
    "top()                                      -- 输出排名前3的进程信息~n"
    "top(AttrName)                              -- 输出排名前3的进程信息~n"
    "top(N)                                     -- 输出排名前几的进程信息~n"
    "top(AttrName, N)                           -- 输出排名前几的进程信息~n"
    "reload_config()                            -- 重新加载配置文件(sys.config)~n"
    "reload_config(ConfigFile)                  -- 重新加载配置文件(sys.config)~n"
    "~n====== trace ======~n"
    "trace(ModOrTSpecs)                         -- 跟踪模块信息~n"
    "trace(TSpecs, Config)                      -- 跟踪模块信息~n"
    "trace(Mod, Config)                         -- 跟踪模块信息~n"
    "trace(Mod, Fun)                            -- 时跟踪模块内某方法信息~n"
    "clear_trace()                              -- 清除跟踪~n"
    "~n====== trace_all ====== ~n"
    "trace_all(ModOrTSpecs)                     -- 跟踪该模块或对应规格并标准输出, 跟踪数3条~n"
    "trace_all(TSpecs0, Config)                 -- 跟踪该模块或对应规格并标准输出, 跟踪数3条~n"
    "trace_all(Mod, Fun)                        -- 跟踪该模块或对应规格并标准输出, 跟踪数3条~n"
    "trace_all(Mod, Config)                     -- 跟踪该模块或对应规格并标准输出, 跟踪数3条~n"
    "trace_all(Mod, Fun, Args)                  -- 跟踪模块下方法并标准输出, 跟踪数3条~n"
    "trace_all(Mod, Fun, ArityOrArgs, Config)   -- 跟踪模块下方法并标准输出, 跟踪数3条~n".
