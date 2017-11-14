-module (lib_misc).

-author ("CHEONGYI").

-copyright ("Copyright © 2017 YiSiXEr").

-compile (export_all).

-export ([
    % key_index_of_record/2,                      % 获取键在记录的索引
    index_of_tuple/2,                           % 获取元素在元组的索引
    index_of_list/2                             % 获取元素在列表的索引
]).



%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
% %%% @doc    获取键在记录的索引
% key_index_of_record (Key, Record) ->
%     RecordName  = element(1, Record),
%     FieldList   = record_info(fields, RecordName),    % 这个编译过不去
%     index_of_list_3(Element, FieldList, 2).

%%% @doc    获取元素在元组的索引
index_of_tuple (Element, Tuple) ->
    index_of_list_3(Element, tuple_to_list(Tuple), 1).


%%% @doc    获取元素在列表的索引
index_of_list (Element, List) ->
    index_of_list_3(Element, List, 1).

index_of_list_3 (Element, [Element | List], Index) ->
    Index;
index_of_list_3 (Element, [_ | List], Index) ->
    index_of_list_3(Element, List, Index + 1);
index_of_list_3 (_Element, [], _Index) ->
    0.









