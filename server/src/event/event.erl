-module (event).

%%% @doc    事件进程

-copyright  ("Copyright © 2017-2018 Tools@YiSiXEr").
-author     ("WhoAreYou").
-date       ({2018, 09, 06}).
-vsn        ("1.0.0").

-compile(export_all).
-export ([
    start/2,
    start_link/2,

    init/3
]).

-record (state, {
    server,
    name    = "",
    to_go   = 0
}).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    启动进程
start (EventName, Delay) ->
    spawn(?MODULE, init, [self(), EventName, Delay]).

start_link (EventName, Delay) ->
    spawn_link(?MODULE, init, [self(), EventName, Delay]).

%%% @doc    事件模块初始化
init (Server, EventName, Delay) ->
    loop(#state{server = Server, name = EventName, to_go = time_to_go(Delay)}).

%%% @doc    取消事件
cancel (Pid) ->
    %% 设置监控器，以免进程已经死亡了
    Ref = erlang:monitor(process, Pid),
    Pid ! {self(), Ref, cancel},
    receive
        {Ref, ok} ->
            erlang:demonitor(Ref),
            ok;
        {'DOWN', Ref, process, Pid, _Reason} ->
            ok
    end.

%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    进程主循环
loop (State = #state{server = Server, to_go = [Timeout | Next]}) ->
    receive
        {Server, Ref, cancel} ->
            Server ! {Ref, ok}
    after Timeout * 1000 ->
        loop(State #state{to_go = Next})
    end;
loop (State = #state{server = Server, to_go = []}) ->
    Server ! {done, State #state.name}.


%%% @doc    日期转为秒数
time_to_go (Delay) ->
    DateTime    = erlang:localtime(),
    ToGo        = calendar:datetime_to_gregorian_seconds(Delay) - 
        calendar:datetime_to_gregorian_seconds(DateTime),
    normalize(max(0, ToGo)).

%%% @doc    标准化分割秒数
%%% @remark 避免超时毫秒超过限制
normalize (ToGo) ->
    Limit   = 49 * 86400,
    [ToGo rem Limit | lists:duplicate(ToGo div Limit, Limit)].
