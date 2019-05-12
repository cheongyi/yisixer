-module (sorting_algo).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @doc    排序算法
%%% @link   https://www.cnblogs.com/onepixel/articles/7674659.html
%%% @type    比较排序:交换(01冒泡、02快速排序)、插入(03简单插入、04希尔排序)、选择(05简单选择、06堆排序)、07归并(二路、多路归并排序)
%%% @type   非比较排序:08计数排序、09桶排序、10基数排序
%%% 相关概念
% 稳定：如果a原本在b前面，而a=b，排序之后a仍然在b的前面。
% 不稳定：如果a原本在b的前面，而a=b，排序之后 a 可能会出现在 b 的后面。
% 时间复杂度：对排序数据的总的操作次数。反映当n变化时，操作次数呈现什么规律。
% 常数阶O(1) < 对数阶O(log2n) < 线性阶O(n) < 线性对数O(nlog2n) < 平方阶O(n^2) < 立方阶O(n^3) < k次方阶O(n^k)
% 假设n=8: 1 < 3             < 8         < 24              < 64          < 512         < 8^k
% 指数阶O(2^n) = 256
% 空间复杂度：是指算法在计算机内执行时所需存储空间的度量，它也是数据规模n的函数。
%%% @end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-author     ("CHEONGYI").
-date       ({2019, 04, 27}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2019 YiSiXEr").

-compile(export_all).
-export ([
    bubble/1,
    % 01、冒泡排序（Bubble    Sort）
    quick/1
    % 02、快速排序（Quick     Sort）
    % 03、插入排序（Insertion Sort）
    % 04、希尔排序（Shell     Sort）
    % 05、选择排序（Selection Sort）
    % 06、堆排序  （Heap      Sort）
    % 07、归并排序（Merge     Sort）
    % 08、计数排序（Counting  Sort）
    % 09、桶排序  （Bucket    Sort）
    % 10、基数排序（Radix     Sort）
]).


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%   排序方法    时间复杂度（平均）   时间复杂度（最坏）   时间复杂度（最好）   空间复杂度   稳定性
%   冒泡排序    O(n^2)             O(n^2)            O(n)              O(1)     稳定
%%% @doc    01、冒泡排序（Bubble    Sort）
%%% 冒泡排序是一种简单的排序算法。
%%% 它重复地走访过要排序的数列，一次比较两个元素，如果它们的顺序错误就把它们交换过来。
%%% 走访数列的工作是重复地进行直到没有再需要交换，也就是说该数列已经排序完成。
%%% 这个算法的名字由来是因为越小的元素会经由交换慢慢“浮”到数列的顶端。
%%% @end
bubble (List) ->
    do_bubble(List, [], []).

do_bubble ([A, B | List], TempL, Return) when A > B -> do_bubble(          [A | List], [B | TempL],        Return);
do_bubble ([A, B | List], TempL, Return)            -> do_bubble(          [B | List], [A | TempL],        Return);
do_bubble (        [Max], TempL, Return)            -> do_bubble(lists:reverse(TempL),          [], [Max | Return]);
do_bubble (           [],    [], Return)            -> Return.

%%% @doc 来自百度的代码
%%% bubble_sort的耗时大概是bubble的2-2.5倍
bubble_sort (List) ->
    bubble_sort(List, length(List)).
 
bubble_sort (List,   0) -> List;
bubble_sort (List, Len) -> bubble_sort(do_bubble_sort(List), Len - 1).
 
do_bubble_sort ([A])           -> [A];
do_bubble_sort ([A, B | List]) ->
    case A =< B of
        true  -> [A | do_bubble_sort([B | List])];
        false -> [B | do_bubble_sort([A | List])]
    end.

%%% @TEST
test_bubble () -> test_bubble(bad, 1000).
test_bubble (Type, Base) ->
    Time1        = test(Type, sort,        1 * Base),
    Time3        = test(Type, sort,        3 * Base),
    Time5        = test(Type, sort,        5 * Base),
    BubbleSort_1 = test(Type, bubble_sort, 1 * Base),    % Time(microseconds) :: 2615709
    Bubble_1     = test(Type, bubble,      1 * Base),    % Time(microseconds) :: 1166016
    BubbleSort_3 = test(Type, bubble_sort, 3 * Base),    % Time(microseconds) :: 26292670
    Bubble_3     = test(Type, bubble,      3 * Base),    % Time(microseconds) :: 10804463
    BubbleSort_5 = test(Type, bubble_sort, 5 * Base),    % Time(microseconds) :: 75224230
    Bubble_5     = test(Type, bubble,      5 * Base),    % Time(microseconds) :: 32434323
    [
        {lists, Time1, Time3, Time5},
        {1 * Base, BubbleSort_1, Bubble_1, BubbleSort_1 / Bubble_1},
        {3 * Base, BubbleSort_3, Bubble_3, BubbleSort_3 / Bubble_3},
        {5 * Base, BubbleSort_5, Bubble_5, BubbleSort_5 / Bubble_5},
        {'3/1', BubbleSort_3 / BubbleSort_1, Bubble_3 / Bubble_1},
        {'5/3', BubbleSort_5 / BubbleSort_3, Bubble_5 / Bubble_3},
        {'5/1', BubbleSort_5 / BubbleSort_1, Bubble_5 / Bubble_1}
    ].
    % {10000,  3892837,  2016546,   1.9304479044861858},
    % {30000, 33267079, 16624236,   2.0011192694810154},
    % {50000, 91876309, 48982520,   1.875695840067028},
    % {'3/1',  8.54571588792441,    8.243916082251532},
    % {'5/3',  2.7617786641261772,  2.9464523963687714},
    % {'5/1', 23.601375808953726,  24.290306296013085}

%%% @doc 测试最坏耗时    
test (best, sort, Count) ->
    List      = lists:seq(1, Count),
    test(lists, sort, List);
test (best, Function, Count) ->
    List      = lists:seq(1, Count),
    test(sorting_algo, Function, List);
test (bad, sort, Count) ->
    List      = lists:reverse(lists:seq(1, Count)),
    test(lists, sort, List);
test (bad, Function, Count) ->
    List      = lists:reverse(lists:seq(1, Count)),
    test(sorting_algo, Function, List);
test (Module, Function, List) ->
    {Time, _} = timer:tc(Module, Function, [List]),
    Time.


%   希尔排序    O(n^2)             O(n^2)            O(n)              O(1)       稳定
%   选择排序    O(n^2)             O(n^2)            O(n)              O(1)       稳定
%   堆排序      O(n^2)             O(n^2)            O(n)              O(1)       稳定
%   归并排序    O(n^2)             O(n^2)            O(n)              O(1)       稳定
%   计数排序    O(n^2)             O(n^2)            O(n)              O(1)       稳定
%   捅排序      O(n^2)             O(n^2)            O(n)              O(1)       稳定
%   基数排序    O(n^2)             O(n^2)            O(n)              O(1)       稳定

%%% ========== ======================================== ====================
%   快速排序    O(nlog2n)          O(n^2)            O(nlog2n)         O(nlog2n)  不稳定
%%% @doc    02、快速排序（Quick     Sort）
quick ([Head | List]) ->
    quick([Little || Little <- List, Little  < Head]) ++
    [Head] ++
    quick([Bigger || Bigger <- List, Bigger >= Head]);
quick ([]) ->
    [].


%   插入排序    O(n^2)             O(n^2)            O(n)              O(1)       稳定
%%% @doc    03、插入排序（Insertion Sort）
%%% @doc    04、希尔排序（Shell     Sort）
%%% @doc    05、选择排序（Selection Sort）
%%% @doc    06、堆排序  （Heap      Sort）
%%% @doc    07、归并排序（Merge     Sort）
%%% @doc    08、计数排序（Counting  Sort）
%%% @doc    09、桶排序  （Bucket    Sort）
%%% @doc    10、基数排序（Radix     Sort）








