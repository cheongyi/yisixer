=== 代码参照 ========================
缩进      4个空格


=== 词汇解释 ========================
player_123456789        玩家进程注册名
player_id    uid        玩家ID
ingot                   金币
gkey                    金钥
star                    星星
pack_max_num            仓库上限

%%% ========== ======================================== ====================
%%% 文件命名规范
*.beam          =>  Erlang compile 后的十六进制文件
*.hrl           =>  Erlang的头文件
*.erl           =>  Erlang的源码文件
api_*.erl       =>  API协议进出
api_*_out.erl   =>  API模块的协议发出封装
mod_*.erl       =>  逻辑处理模块
lib_*.erl       =>  公用类库
*_sup.erl       =>  督程
*_srv.erl       =>  子工作进程worker
game_*.erl      =>  系统相关模块
*.app           =>  应用的配置文件
*.sh            =>  类Linux下的脚本文件
start.sh        =>  启动文件
build.sh        =>  编译文件
enum_table.txt  =>  数据库表数据转换成Erlang宏定义的配置文件

%%% @doc    函数注释
%% 行注释
% 代码后注释
%%% ========== ======================================== ====================
%%% 功能块注释
%%% ========== ======================================== ====================


%%% ========== ======================================== ====================
erlc +"'S'" lib_time.erl


%%% ========== ======================================== ====================
%% @todo   浮点数
100000.01 - 50000.01.  
49999.99999999999
%%% ========== ======================================== ====================
%% @todo   Eshell 函数帮助
Eshell V5.8.5  (abort with ^G)
1> help().

%% @doc    ** Eshell 内置命令 **
** shell internal commands **
%% 显示所有绑定的变量
b()                 -- display all variable bindings 
%% 重复某次查询 <N>
e(N)                -- repeat the expression in query <N>
%% 释放所有绑定的变量
f()                 -- forget all variable bindings
%% 释放某个绑定的变量
f(X)                -- forget the binding of variable X
%% 显示之前的操作
h()                 -- history
%% 设置保留之前操作命令的条数
history(N)          -- set how many previous commands to keep
%% 设置保留之前操作结果的条数
results(N)          -- set how many previous command results to keep
%% 设置的执行过程中的异常处理
catch_exception(B)  -- how exceptions are handled
%% 使用某次查询的值 <N>
v(N)                -- use the value of query <N>
%% 定义一个记录(record)
rd(R,D)             -- define a record
%% 移除所有记录(record)信息
rf()                -- remove all record information
%% 移除某个记录(record)信息
rf(R)               -- remove record information about R
%% 显示所有记录(record)信息
rl()                -- display all record information
%% 显示某个记录(record)信息
rl(R)               -- display record information about R
%% 显示某个数据项(Term)的所有内容
rp(Term)            -- display Term using the shell's record information
%% 从文件中读取记录(record)信息（通配符允许)
rr(File)            -- read record information from File (wildcards allowed)
%% 从文件中读取选定的记录(record)信息
rr(F,R)             -- read selected record information from file(s)
%% 从文件中读取指定选项的选定的记录(record)信息
rr(F,R,O)           -- read selected record information with options

%% @doc    ** c 模块命令 **
** commands in module c **
%% 显示一个进程的栈回溯
bt(Pid)             -- stack backtrace for a process
%% 编译并加载文件进Eshell
c(File)             -- compile and load code in <File>
%% 改变工作目录
cd(Dir)             -- change working directory
%% 刷新信箱（以便shell接收信息）
flush()             -- flush any messages sent to the shell
%% 帮助信息
help()              -- help info
%% 显示系统信息
i()                 -- information about the system
%% 和 i() 一样显示系统信息，还包括网络节点的系统信息
ni()                -- information about the networked system
%% 通过 pid <X,Y,Z> 获取某个进程的信息
i(X,Y,Z)            -- information about pid <X,Y,Z>
%% 加载或重新加载模块
l(Module)           -- load or reload module
%% 编译一个列表的 Erlang 模块
lc([File])          -- compile a list of Erlang modules
%% 显示当前工作目录下的文件列表
ls()                -- list files in the current directory
%% 显示某个对应目录下的文件列表
ls(Dir)             -- list files in directory <Dir>
%% 显示已加载进系统的模块
m()                 -- which modules are loaded
%% 显示某个模块信息
m(Mod)              -- information about module <Mod>
%% 显示内存分配信息
memory()            -- memory allocation information
%% 显示某项内存分配信息 <T>
memory(T)           -- memory allocation information of type <T>
%% 在所有节点编译及加载模块
nc(File)            -- compile and load code in <File> on all nodes
%% 在所有节点重新加载模块
nl(Module)          -- load module on all nodes
%% 通过 pid <X,Y,Z> 获取某个进程 pid
pid(X,Y,Z)          -- convert X,Y,Z to a Pid
%% 显示当前工作目录
pwd()               -- print working directory
%% 退出 erlang shell
q()                 -- quit - shorthand for init:stop()
%% 显示注册过的进程信息
regs()              -- information about registered processes
%% 和 regs() 一样显示注册过的进程信息，还包括网络节点的进程信息
nregs()             -- information about all registered processes
%% 查找某个模块未定义的函数，未使用的函数，已弃用的函数
xm(M)               -- cross reference check a module
%% 编译 Yecc 文件(.yrl)
y(File)             -- generate a Yecc parser


%% @doc    ** i 模块命令  **
** commands in module i (interpreter interface) **
%% 显示 i 模块的帮助信息
ih()                -- print help for the i module



%%% ========== ======================================== ====================
{
2#0 band 2#0,
2#0 band 2#1,
2#1 band 2#0,
2#1 band 2#1,
2#0 bor  2#0,
2#0 bor  2#1,
2#1 bor  2#0,
2#1 bor  2#1,
2#0 bxor 2#0,
2#0 bxor 2#1,
2#1 bxor 2#0,
2#1 bxor 2#1,
bnot 2#1,
2#1111 bsl 1,
2#1111 bsr 1
}.


%%% ========== ======================================== ====================
46> erlang:term_to_binary('').
<<131,100,0,0>>

47> erlang:term_to_binary('a').
<<131,100,0,1,97>>

47> erlang:term_to_binary("").
<<131,106>>

47> erlang:term_to_binary("1").
<<131,107,0,1,49>>

48> erlang:term_to_binary([]).
<<131,106>>

54> erlang:term_to_binary(1).
<<131,97,1>>

49> erlang:term_to_binary({}).
<<131,104,0>>

50> erlang:term_to_binary({1}).
<<131,104,1,97,1>>

60> erlang:term_to_binary(<<>>).
<<131,109,0,0,0,0>>

47> erlang:term_to_binary(fun erlang:time/0).
<<131,113,100,0,6,101,114,108,97,110,103,100,0,4,116,105,
  109,101,97,0>>
  
47> erlang:term_to_binary(fun a:b/0).
<<131,113,100,0,1,97,100,0,1,98,97,0>>
%%% ========== ======================================== ====================
%%% 数据类型的大小比较
Atom    = atom.
Binary  = <<>>.
Fun     = fun() -> ok end.
List    = [].
Number  = 0.
Pid     = self().
Port    = lists:nth(1, erlang:ports()).
Ref     = make_ref().
String  = "".
Tuple   = {}.
lists:sort([Atom, Binary, Fun, List, Number, Pid, Port, Ref, String, Tuple]).

[0,atom,#Ref<0.0.0.488>,#Fun<erl_eval.20.21881191>,
 #Port<0.1>,<0.113.0>,{},[],[],<<>>]
数值 < 原子 < 引用 < 匿名函数 < 端口 < 进程 < 元组 < 列表 < 二进制串


%%% ========== ======================================== ====================
SMP 对称多处理结构
reduction   归约数





