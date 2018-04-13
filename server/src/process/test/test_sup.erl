-module (test_sup).

-copyright  ("Copyright © 2017 YiSiXEr").
-author     ("WhoAreYou").
-date       ({2017, 11, 09}).
-vsn        ("1.0.0").

-behaviour  (supervisor).

-export ([start_link/0]).
-export ([init/1]).

-include ("define.hrl").
% -include ("record.hrl").

-define (SERVER, ?MODULE).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    Start the process and link.
start_link () ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%% ========== ======================================== ====================
%%% callback
%%% ========== ======================================== ====================
%%% @doc    Process start callback.
init ([]) ->
    ChildSpecs = [
        {test_srv,  {test_srv,  start_link, []}, permanent, brutal_kill, worker, [test_srv]},
        {test_proc, {test_proc, start_link, []}, permanent, brutal_kill, worker, [test_proc]}
    ],
    {ok, {{one_for_one, 10, 10}, ChildSpecs}}.




%%% ========== ======================================== ====================
% {ok, {{Restart Strategy, Intensity, Period}, ChildSpecs}}.
% 1.重启策略（Restart Strategy） 
    % a. one_for_one 
    %   当一个child process挂掉时，它的监控者（supervisor）仅重启该child process，而不会影响其他child process 
    % b.one_for_all 
    %   当一个child process挂掉时，它的监控者（supervisor）将会terminate其余所有child  process，然后再重启所有child process 
    % c.rest_for_one 
    %   当一个child process挂掉时，它的监控者（supervisor）只会terminate在该child process之后启动的process，然后再将这些process 通通重启 
    % d.simple_one_for_one 
    %   与one_for_one相同，唯一的区别是：所有的child process都是动态添加的并且执行同样一份代码（稍后详述） 
    %   并不会真正的去启动一个child process，
    %   而必须通过调用 supervisor:start_child(Sup, List) 动态添加child process，
    %   其中第一个参数Sup是表示你要往哪个supervisor下添加child process，
    %   第二个参数用来在创建child process时传递给它（内部调用apply(M, F, A++List)) 

% 2.最大重启频率（Maximum Restart Frequency） 
%   Intensity :: integer() >= 0,强度
%   Period    :: integer() >= 1,间隔
%   该属性的主要目的是为了防止child proces 频繁的terminate->restart，
%   当某个child process超过这个频率，supervisor将会terminate所有的child process然后再terminate掉自己

% 3.Child Specification 
%   这个属性说白了，就是告诉supervisor，你要监控哪些child process，你该怎么启动这些child process以及如何结束它们等等，
%   该属性的详细格式如下

    % ========== 子规程ChildSpecification ==========
    % ChildId   :: 用来内部标识子规范
    % StartFunc :: 启动子进程时调用的函数
    % 它将成为对 supervisor, gen_server, gen_fsm or gen_event:start_link的调用
    % Restart   :: 标识一个进程终止后将怎样重启，
    %   permanent 总会被重启;
    %   temporary 从不会被重启;
    %   transient 仅当不正常的被终止后才重启，例如非normal得退出原因
    % Shutdown  :: 一个进程将怎样被终止
    %   Integer(ms) 整型值,进程在被强制干掉之前有Integer毫秒的时间料理后事自行终止
    %   brutal_kill 进程马上会被无条件终止
    %   infinity    当一个子进程是supervisor那么就要用infinity,意思是给supervisor足够的时间进行重启
    % Type      :: 指定子进程是supervisor还是worker
    % Modules   :: 是有一个元素的列表[Module]，
    %   假如子进程是supervisor、gen_server 或 gen_fsm，那么Module 是回调模块的名称；
    %   假如子进程是gen_event，那么Modules 应该是dynamic



