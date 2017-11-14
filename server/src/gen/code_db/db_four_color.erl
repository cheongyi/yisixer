-module (db_four_color).

-author     ("WhoAreYou").
-date       ({2017, 11, 09}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2017 YiSiXEr").

-compile (export_all).
-export ([
    get_hucard_of_hand_card_by_record/1,    % 获取玩家记录手牌胡牌处理
    get_hucard_of_hand_card_list/1,         % 获取玩家手牌列表胡牌处理
    get_hucard_of_each_hand_card/1,         % 获取玩家对应手牌胡牌处理
    get_handle_of_hand_card_by_record/1,    % 获取玩家记录手牌默认处理
    get_handle_of_hand_card_list/1,         % 获取玩家手牌列表默认处理
    get_handle_of_each_hand_card/1,         % 获取玩家对应手牌默认处理
    get_henums_of_side_card_list/1,         % 获取玩家边牌列表合数
    get_next_todo_type/1,                   % 获取下个将玩类型
    get_next_player_by_todo_type/2,         % 根据将玩类型获取下个玩家
    get_next_player_registered_name/1,      % 获取下家进程注册名称
    get_player_number_by_todo_type/1        % 根据将玩类型获取玩家数量
]).


-include ("define.hrl").
-include ("record.hrl").


%% ==================== 胡牌逻辑处理 ====================
%% @todo   获取玩家记录手牌胡牌处理
get_hucard_of_hand_card_by_record (PlayerFourColorCard) ->
    get_hucard_of_hand_card_list(get_hand_card_list_by_record(PlayerFourColorCard)).

%% @todo   获取玩家手牌列表胡牌处理
get_hucard_of_hand_card_list (HandCardList) ->
    get_hucard_of_hand_card_list(HandCardList, {0, [], [], [], []}).
get_hucard_of_hand_card_list ([], Return) ->
    Return;
get_hucard_of_hand_card_list ([EachHandCardList | HandCardList], Return) ->
    get_hucard_of_hand_card_list(
        HandCardList,
        count_handle_of_each_hand_card(
            get_hucard_of_each_hand_card(EachHandCardList),
            Return
        )
    ).


%% @todo   获取玩家对应手牌胡牌处理
get_hucard_of_each_hand_card ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]}
    ]};
get_hucard_of_each_hand_card ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]}
    ]};
get_hucard_of_each_hand_card ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]}
    ]};
get_hucard_of_each_hand_card ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_hucard_of_each_hand_card (EachHandCardList) ->
    get_handle_of_each_hand_card(EachHandCardList).



%% ==================== 默认逻辑处理 ====================
%% @todo   获取玩家记录手牌默认处理
get_handle_of_hand_card_by_record (PlayerFourColorCard) ->
    get_handle_of_hand_card_list(get_hand_card_list_by_record(PlayerFourColorCard)).


%% @todo   获取玩家手牌列表默认处理
get_handle_of_hand_card_list (HandCardList) ->
    get_handle_of_hand_card_list(HandCardList, {0, [], [], [], []}).
get_handle_of_hand_card_list ([], Return) ->
    Return;
get_handle_of_hand_card_list ([EachHandCardList | HandCardList], Return) ->
    get_handle_of_hand_card_list(
        HandCardList,
        count_handle_of_each_hand_card(
            get_handle_of_each_hand_card(EachHandCardList),
            Return
        )
    ).


%% @todo   统计手牌样式的处理，减少列表运算
count_handle_of_each_hand_card ({0, [], [], [], []}, Return) ->
    Return;
count_handle_of_each_hand_card (
    {EachHeNumber, [],                 [],                 [],                 []},
    {HandHeNumber, HandSingleCardList, HandKinds2CardList, HandDoubleCardList, HandToSideCardList}
) ->
    {
        EachHeNumber        +  HandHeNumber,
        HandSingleCardList,
        HandKinds2CardList,
        HandDoubleCardList,
        HandToSideCardList
    };
count_handle_of_each_hand_card (
    {EachHeNumber, EachSingleCardList, [],                 EachDoubleCardList, []},
    {HandHeNumber, HandSingleCardList, HandKinds2CardList, HandDoubleCardList, HandToSideCardList}
) ->
    {
        EachHeNumber        +  HandHeNumber,
        EachSingleCardList  ++ HandSingleCardList,
        HandKinds2CardList,
        EachDoubleCardList  ++ HandDoubleCardList,
        HandToSideCardList
    };
count_handle_of_each_hand_card (
    {EachHeNumber, EachSingleCardList, [],                 EachDoubleCardList, EachToSideCardList},
    {HandHeNumber, HandSingleCardList, HandKinds2CardList, HandDoubleCardList, HandToSideCardList}
) ->
    {
        EachHeNumber        +  HandHeNumber,
        EachSingleCardList  ++ HandSingleCardList,
        HandKinds2CardList,
        EachDoubleCardList  ++ HandDoubleCardList,
        [EachToSideCardList |  HandToSideCardList]
    };
count_handle_of_each_hand_card (
    {EachHeNumber, EachSingleCardList, EachKinds2CardList, EachDoubleCardList, EachToSideCardList},
    {HandHeNumber, HandSingleCardList, HandKinds2CardList, HandDoubleCardList, HandToSideCardList}
) ->
    {
        EachHeNumber        +  HandHeNumber,
        EachSingleCardList  ++ HandSingleCardList,
        [EachKinds2CardList |  HandKinds2CardList],
        EachDoubleCardList  ++ HandDoubleCardList,
        [EachToSideCardList |  HandToSideCardList]
    }.


%% @todo   根据玩家记录获取手牌列表
get_hand_card_list_by_record (PlayerFourColorCard) ->
    [
        PlayerFourColorCard #player_four_color_card.four_color_bing_list,
        PlayerFourColorCard #player_four_color_card.green_jiang_shi_xiang,
        PlayerFourColorCard #player_four_color_card.green_che_ma_pao,
        PlayerFourColorCard #player_four_color_card.red_jiang_shi_xiang,
        PlayerFourColorCard #player_four_color_card.red_che_ma_pao,
        PlayerFourColorCard #player_four_color_card.white_jiang_shi_xiang,
        PlayerFourColorCard #player_four_color_card.white_che_ma_pao,
        PlayerFourColorCard #player_four_color_card.yellow_jiang_shi_xiang,
        PlayerFourColorCard #player_four_color_card.yellow_che_ma_pao
    ].


%% @todo   获取玩家对应手牌默认处理
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card (EachHandCardList) ->
    get_handle_of_each_hand_card_by_len(length(EachHandCardList), EachHandCardList).
%% @todo   根据长度获取玩家对应手牌默认处理
get_handle_of_each_hand_card_by_len (00, EachHandCardList) ->
    get_handle_of_each_hand_card_00(EachHandCardList);
get_handle_of_each_hand_card_by_len (01, EachHandCardList) ->
    get_handle_of_each_hand_card_01(EachHandCardList);
get_handle_of_each_hand_card_by_len (02, EachHandCardList) ->
    get_handle_of_each_hand_card_02(EachHandCardList);
get_handle_of_each_hand_card_by_len (03, EachHandCardList) ->
    get_handle_of_each_hand_card_03(EachHandCardList);
get_handle_of_each_hand_card_by_len (04, EachHandCardList) ->
    get_handle_of_each_hand_card_04(EachHandCardList);
get_handle_of_each_hand_card_by_len (05, EachHandCardList) ->
    get_handle_of_each_hand_card_05(EachHandCardList);
get_handle_of_each_hand_card_by_len (06, EachHandCardList) ->
    get_handle_of_each_hand_card_06(EachHandCardList);
get_handle_of_each_hand_card_by_len (07, EachHandCardList) ->
    get_handle_of_each_hand_card_07(EachHandCardList);
get_handle_of_each_hand_card_by_len (08, EachHandCardList) ->
    get_handle_of_each_hand_card_08(EachHandCardList);
get_handle_of_each_hand_card_by_len (09, EachHandCardList) ->
    get_handle_of_each_hand_card_09(EachHandCardList);
get_handle_of_each_hand_card_by_len (10, EachHandCardList) ->
    get_handle_of_each_hand_card_10(EachHandCardList);
get_handle_of_each_hand_card_by_len (11, EachHandCardList) ->
    get_handle_of_each_hand_card_11(EachHandCardList);
get_handle_of_each_hand_card_by_len (12, EachHandCardList) ->
    get_handle_of_each_hand_card_12(EachHandCardList);
get_handle_of_each_hand_card_by_len (13, EachHandCardList) ->
    get_handle_of_each_hand_card_13(EachHandCardList);
get_handle_of_each_hand_card_by_len (14, EachHandCardList) ->
    get_handle_of_each_hand_card_14(EachHandCardList);
get_handle_of_each_hand_card_by_len (15, EachHandCardList) ->
    get_handle_of_each_hand_card_15(EachHandCardList);
get_handle_of_each_hand_card_by_len (16, EachHandCardList) ->
    get_handle_of_each_hand_card_16(EachHandCardList).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 单张无用手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
% get_handle_of_each_hand_card_single ([EachHandCardList]) ->
%     {0, EachHandCardList, [], [], [{match_one_eat, EachHandCardList}]}.



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 配对手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
% get_handle_of_each_hand_card_2kinds (EachHandCardList) ->
%     {0, [], EachHandCardList, []}.



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 0张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_00 ([]) ->
    {0, [], [], [], [

    ]}.



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 将士相 ===== 1张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_01 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}}
]) ->
    {1, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_01 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {0, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_01 ([
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {0, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 车马炮 ===== 1张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_01 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}}
]) ->
    {0, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_01 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {0, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_01 ([
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {0, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 1张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_01 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}}
]) ->
    {0, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_01 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {0, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_01 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {0, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_01 ([
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_01 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 将士相 ===== 2张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_02 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}}
]) ->
    {2, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_02 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {1, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},
{{finish_hucard, {_Color, xiang}}, [_4ColorJiangCard01, _4Color__ShiCard01]},

{{eating_double, {_Color, xiang}}, [_4ColorJiangCard01, _4Color__ShiCard01]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_02 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {1, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4ColorJiangCard01, _4ColorXiangCard01]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{eating_double, {_Color,   shi}}, [_4ColorJiangCard01, _4ColorXiangCard01]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_02 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {0, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_02 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {0, [], [_4Color__ShiCard01, _4ColorXiangCard01], [], [
{{finish_hucard, {_Color, jiang}}, [_4Color__ShiCard01, _4ColorXiangCard01]},

{{eating_double, {_Color, jiang}}, [_4Color__ShiCard01, _4ColorXiangCard01]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_02 ([
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {0, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 车马炮 ===== 2张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_02 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}}
]) ->
    {0, [], [], [_4Color__CheCard01, _4Color__CheCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]}
    ]};
get_handle_of_each_hand_card_02 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {0, [], [_4Color__CheCard01, _4Color___MaCard01], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__CheCard01, _4Color___MaCard01]},

{{eating_double, {_Color,   pao}}, [_4Color__CheCard01, _4Color___MaCard01]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_02 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {0, [], [_4Color__CheCard01, _4Color__PaoCard01], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color__CheCard01, _4Color__PaoCard01]},

{{eating_double, {_Color,    ma}}, [_4Color__CheCard01, _4Color__PaoCard01]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_02 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {0, [], [], [_4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]}
    ]};
get_handle_of_each_hand_card_02 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {0, [], [_4Color___MaCard01, _4Color__PaoCard01], [], [
{{finish_hucard, {_Color,   che}}, [_4Color___MaCard01, _4Color__PaoCard01]},

{{eating_double, {_Color,   che}}, [_4Color___MaCard01, _4Color__PaoCard01]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_02 ([
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {0, [], [], [_4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 2张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_02 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}}
]) ->
    {0, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_02 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {0, [], [__Green_BingCard01, ____Red_BingCard01], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_02 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {0, [], [__Green_BingCard01, __White_BingCard01], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_02 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [], [__Green_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_02 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {0, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_02 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {0, [], [____Red_BingCard01, __White_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_02 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [], [____Red_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_02 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {0, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_02 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [], [__White_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_02 ([
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_02 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 将士相 ===== 3张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_03 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}}
]) ->
    {3, [], [], [], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]}
    ]};
get_handle_of_each_hand_card_03 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {2, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},
{{finish_hucard, {_Color, xiang}}, [_4ColorJiangCard01, _4Color__ShiCard01]},

{{eating_double, {_Color, xiang}}, [_4ColorJiangCard01, _4Color__ShiCard01]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_03 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {2, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4ColorJiangCard01, _4ColorXiangCard01]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{eating_double, {_Color,   shi}}, [_4ColorJiangCard01, _4ColorXiangCard01]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_03 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {1, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{eating_double, {_Color, xiang}}, [_4ColorJiangCard01, _4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_03 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {2, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_03 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {1, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{eating_double, {_Color,   shi}}, [_4ColorJiangCard01, _4ColorXiangCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_03 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {3, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_03 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {0, [_4ColorXiangCard01], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{eating_double, {_Color, jiang}}, [_4Color__ShiCard01, _4ColorXiangCard01]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {0, [_4Color__ShiCard01], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{eating_double, {_Color, jiang}}, [_4Color__ShiCard01, _4ColorXiangCard01]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 车马炮 ===== 3张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_03 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}}
]) ->
    {3, [], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]}
    ]};
get_handle_of_each_hand_card_03 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {0, [_4Color___MaCard01], [], [_4Color__CheCard01, _4Color__CheCard02], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{eating_double, {_Color,   pao}}, [_4Color__CheCard01, _4Color___MaCard01]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {0, [_4Color__PaoCard01], [], [_4Color__CheCard01, _4Color__CheCard02], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{eating_double, {_Color,    ma}}, [_4Color__CheCard01, _4Color__PaoCard01]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {0, [_4Color__CheCard01], [], [_4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{eating_double, {_Color,   pao}}, [_4Color__CheCard01, _4Color___MaCard01]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {1, [], [], [], [

    ]};
get_handle_of_each_hand_card_03 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {0, [_4Color__CheCard01], [], [_4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},
{{eating_double, {_Color,    ma}}, [_4Color__CheCard01, _4Color__PaoCard01]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {3, [], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]}
    ]};
get_handle_of_each_hand_card_03 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {0, [_4Color__PaoCard01], [], [_4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{eating_double, {_Color,   che}}, [_4Color___MaCard01, _4Color__PaoCard01]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {0, [_4Color___MaCard01], [], [_4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},
{{eating_double, {_Color,   che}}, [_4Color___MaCard01, _4Color__PaoCard01]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 3张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_03 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}}
]) ->
    {3, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]}
    ]};
get_handle_of_each_hand_card_03 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {0, [____Red_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {0, [__White_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [_Yellow_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {0, [__Green_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {1, [], [], [], [
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]},

{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]},

{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {0, [__Green_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]},

{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [__Green_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard01], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {3, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_03 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {0, [__White_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [_Yellow_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {0, [____Red_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},

{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [____Red_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_03 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [_Yellow_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [__White_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_03 ([
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_03 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 将士相 ===== 4张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_04 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}}
]) ->
    {8, [], [], [], [

    ]};
get_handle_of_each_hand_card_04 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {3, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {2, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{eating_double, {_Color, xiang}}, [_4ColorJiangCard01, _4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_04 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_04 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {2, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{eating_double, {_Color,   shi}}, [_4ColorJiangCard01, _4ColorXiangCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_04 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {4, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_04 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {2, [_4Color__ShiCard02], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{eating_double, {_Color,   shi}}, [_4ColorJiangCard01, _4ColorXiangCard01]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_04 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {2, [_4ColorXiangCard02], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{eating_double, {_Color, xiang}}, [_4ColorJiangCard01, _4Color__ShiCard01]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_04 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {4, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {8, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {0, [], [], [_4Color__ShiCard01, _4Color__ShiCard02, _4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_04 ([
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {8, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 车马炮 ===== 4张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_04 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}}
]) ->
    {8, [], [], [], [

    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {3, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {0, [], [], [_4Color__CheCard01, _4Color__CheCard02, _4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{eating_double, {_Color,   pao}}, [_4Color__CheCard01, _4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {1, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{eating_double, {_Color,   che}}, [_4Color___MaCard01, _4Color__PaoCard01]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {0, [], [], [_4Color__CheCard01, _4Color__CheCard02, _4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},
{{eating_double, {_Color,    ma}}, [_4Color__CheCard01, _4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {3, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {1, [_4Color___MaCard02], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{eating_double, {_Color,    ma}}, [_4Color__CheCard01, _4Color__PaoCard01]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {1, [_4Color__PaoCard02], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{eating_double, {_Color,   pao}}, [_4Color__CheCard01, _4Color___MaCard01]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {8, [], [], [], [

    ]};
get_handle_of_each_hand_card_04 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {0, [], [], [_4Color___MaCard01, _4Color___MaCard02, _4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},
{{eating_double, {_Color,   che}}, [_4Color___MaCard01, _4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [], [], [], [

    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 4张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}}
]) ->
    {8, [], [], [], [

    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {3, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {0, [], [], [__Green_BingCard01, __Green_BingCard02, ____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {1, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {0, [], [], [__Green_BingCard01, __Green_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [], [], [__Green_BingCard01, __Green_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {3, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {1, [____Red_BingCard02], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [____Red_BingCard02], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {1, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]}

    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {8, [], [], [], [

    ]};
get_handle_of_each_hand_card_04 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {0, [], [], [____Red_BingCard01, ____Red_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [____Red_BingCard02], [], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [], [], [____Red_BingCard01, ____Red_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [__White_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [_Yellow_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [], [], [], [

    ]};
get_handle_of_each_hand_card_04 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {0, [], [], [__White_BingCard01, __White_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_04 ([
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [], [

    ]};
get_handle_of_each_hand_card_04 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 将士相 ===== 5张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {8, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {8, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {3, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [_4Color__ShiCard01, _4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, jiang}}, [_4Color__ShiCard01, _4ColorXiangCard01]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {5, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [_4Color__ShiCard02], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},
{{finish_hucard, {_Color, xiang}}, [_4ColorJiangCard01, _4Color__ShiCard01]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{eating_double, {_Color,   shi}}, [_4ColorJiangCard01, _4ColorXiangCard01]},
{{eating_double, {_Color, xiang}}, [_4ColorJiangCard01, _4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [_4ColorXiangCard02], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4ColorJiangCard01, _4ColorXiangCard01]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{eating_double, {_Color,   shi}}, [_4ColorJiangCard01, _4ColorXiangCard01]},
{{eating_double, {_Color, xiang}}, [_4ColorJiangCard01, _4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {5, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {9, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {4, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4ColorJiangCard01, _4ColorXiangCard01]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {1, [], [], [_4Color__ShiCard01, _4Color__ShiCard02, _4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, [_4Color__ShiCard01, _4ColorXiangCard01]},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{eating_double, {_Color, jiang}}, [_4Color__ShiCard01, _4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {4, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},
{{finish_hucard, {_Color, xiang}}, [_4ColorJiangCard01, _4Color__ShiCard01]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_05 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {9, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {8, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {8, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 车马炮 ===== 5张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {8, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {3, [], [], [_4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color___MaCard01, _4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color___MaCard01, _4Color__PaoCard01]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [], [], [_4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {3, [], [], [_4Color__CheCard01, _4Color__CheCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {1, [], [_4Color__CheCard02, _4Color___MaCard02], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__CheCard01, _4Color___MaCard01]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{eating_double, {_Color,   pao}}, [_4Color__CheCard01, _4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {1, [], [_4Color__CheCard02, _4Color__PaoCard02], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color__CheCard01, _4Color__PaoCard01]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},
{{eating_double, {_Color,    ma}}, [_4Color__CheCard01, _4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [], [], [_4Color__CheCard01, _4Color__CheCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {8, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color__CheCard01, _4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color__CheCard01, _4Color__PaoCard01]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {1, [], [_4Color___MaCard02, _4Color__PaoCard02], [], [
{{finish_hucard, {_Color,   che}}, [_4Color___MaCard01, _4Color__PaoCard01]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},
{{eating_double, {_Color,   che}}, [_4Color___MaCard01, _4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color__CheCard01, _4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__CheCard01, _4Color___MaCard01]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [], [], [_4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [], [], [_4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 5张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {8, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {3, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [], [____Red_BingCard01, __White_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [____Red_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [__White_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {3, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {1, [], [__Green_BingCard02, ____Red_BingCard02], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [__Green_BingCard02, ____Red_BingCard02], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {1, [], [__Green_BingCard02, __White_BingCard02], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [__Green_BingCard02, _Yellow_BingCard02], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [__Green_BingCard02, __White_BingCard02], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [__Green_BingCard02, _Yellow_BingCard02], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {8, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [], [__Green_BingCard01, __White_BingCard01], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [__Green_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {1, [], [____Red_BingCard02, __White_BingCard02], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [____Red_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [____Red_BingCard02, _Yellow_BingCard02], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [], [__Green_BingCard01, ____Red_BingCard01], [], [
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [__White_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [_Yellow_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [__Green_BingCard01, ____Red_BingCard01], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [__Green_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [__White_BingCard02, _Yellow_BingCard02], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [__Green_BingCard01, __White_BingCard01], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [__White_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [____Red_BingCard02, __White_BingCard02], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [____Red_BingCard02, _Yellow_BingCard02], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [____Red_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {1, [], [__White_BingCard02, _Yellow_BingCard02], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [____Red_BingCard01, __White_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_05 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_05 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 将士相 ===== 6张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {8, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {8, [_4Color__ShiCard01, _4ColorXiangCard01], [], [], [

{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {8, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {6, [], [], [], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {6, [], [], [], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {10, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {5, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4ColorJiangCard01, _4ColorXiangCard01]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {4, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {5, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},
{{finish_hucard, {_Color, xiang}}, [_4ColorJiangCard01, _4Color__ShiCard01]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {10, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {9, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {4, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {4, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_06 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {9, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {8, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {6, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {8, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 车马炮 ===== 6张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {8, [], [], [_4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color___MaCard01, _4Color__PaoCard01], [], [], [

{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [], [], [_4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {6, [], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {6, [], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {8, [], [], [_4Color__CheCard01, _4Color__CheCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {2, [], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [], [], [_4Color__CheCard01, _4Color__CheCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color__CheCard01, _4Color__PaoCard01], [], [], [

{{eating_single, {_Color,   che}}, [_4Color__CheCard01]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color__CheCard01, _4Color___MaCard01], [], [], [

{{eating_single, {_Color,   che}}, [_4Color__CheCard01]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [], [], [_4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {6, [], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [], [], [_4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 6张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {8, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [], [____Red_BingCard01, __White_BingCard01], [], [
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [____Red_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [__White_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {6, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [__White_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [_Yellow_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [____Red_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [____Red_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {6, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [_Yellow_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [__White_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {8, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [__White_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [_Yellow_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {2, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]},

{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {2, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]},
{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {2, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [____Red_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {2, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {2, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [____Red_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [_Yellow_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {2, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [__White_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [], [__Green_BingCard01, __White_BingCard01], [], [
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [__Green_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [__Green_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [__Green_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [__Green_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {2, [], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {2, [], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [__Green_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [], [__Green_BingCard01, ____Red_BingCard01], [], [
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {2, [], [], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [__Green_BingCard01, ____Red_BingCard01], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [__Green_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [__Green_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [__Green_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [__Green_BingCard01, __White_BingCard01], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [__White_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {6, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [_Yellow_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [__White_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [_Yellow_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {2, [], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [__White_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [____Red_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [____Red_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [____Red_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [____Red_BingCard01, __White_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_06 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_06 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_06 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_06 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 将士相 ===== 7张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {8, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {8, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {6, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {3, [], [], [_4Color__ShiCard01, _4Color__ShiCard02, _4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {6, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {10, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {5, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {5, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {10, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {9, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {7, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_07 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {9, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 车马炮 ===== 7张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {6, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [], [], [_4Color___MaCard01, _4Color___MaCard02, _4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {6, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]},
{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [], [], [_4Color__CheCard01, _4Color__CheCard02, _4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {3, [], [], [_4Color__CheCard01, _4Color__CheCard02, _4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {6, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 7张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [__White_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [_Yellow_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [____Red_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [], [], [], [

    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [____Red_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [_Yellow_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__White_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {11, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {6, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [], [], [____Red_BingCard01, ____Red_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [____Red_BingCard02], [], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [____Red_BingCard01, ____Red_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {6, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [__White_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [_Yellow_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [__White_BingCard01, __White_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [__White_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [_Yellow_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [], [], [__Green_BingCard01, __Green_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [__Green_BingCard01, __Green_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {3, [], [], [__Green_BingCard01, __Green_BingCard02, ____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {5, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]},

{{eating_thrice, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {5, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_thrice, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [__Green_BingCard01, __Green_BingCard02, ____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [____Red_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {5, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_thrice, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [____Red_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [_Yellow_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [__Green_BingCard01, __Green_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [__Green_BingCard01, __Green_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__White_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [__Green_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [], [], [], [

    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__Green_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {6, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [__Green_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [____Red_BingCard02], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {5, [], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_thrice, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [____Red_BingCard02], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__Green_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [], [], [], [

    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [], [], [], [

    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__Green_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__Green_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [_Yellow_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__White_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [__White_BingCard01, __White_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [_Yellow_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [____Red_BingCard01, ____Red_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {3, [], [], [____Red_BingCard01, ____Red_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__White_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [____Red_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [____Red_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_07 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_07 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_07 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ===========================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 将士相 ===== 8张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    {16, [], [], [], [

    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {11, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {8, [], [], [_4Color__ShiCard01, _4Color__ShiCard02, _4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {11, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {16, [], [], [], [

    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {11, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {6, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {6, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {11, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {10, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {8, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {10, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {12, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_08 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {12, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {16, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 车马炮 ===== 8张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    {16, [], [], [], [

    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {16, [], [], [], [

    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {6, [], [], [_4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {6, [], [], [_4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [], [], [_4Color__CheCard01, _4Color__CheCard02, _4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {6, [], [], [_4Color__CheCard01, _4Color__CheCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {8, [], [], [_4Color__CheCard01, _4Color__CheCard02, _4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {16, [], [], [], [

    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 8张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}}
]) ->
    {16, [], [], [], [

    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [], [], [____Red_BingCard01, ____Red_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [____Red_BingCard02], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [____Red_BingCard01, ____Red_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11,[____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11,[____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {16, [], [], [], [

    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11,[_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [__White_BingCard01, __White_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11,[__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [], [

    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {6, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__White_BingCard01, _Yellow_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {6, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [____Red_BingCard02, __White_BingCard02], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [____Red_BingCard02, _Yellow_BingCard02], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [____Red_BingCard01, _Yellow_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [__White_BingCard02, _Yellow_BingCard02], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [____Red_BingCard01, __White_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [], [], [__Green_BingCard01, __Green_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [__Green_BingCard01, __Green_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {6, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [__Green_BingCard02, __White_BingCard02], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [__Green_BingCard02, _Yellow_BingCard02], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {8, [], [], [__Green_BingCard01, __Green_BingCard02, ____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [__Green_BingCard02, ____Red_BingCard02], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}

    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [__Green_BingCard02, ____Red_BingCard02], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [__Green_BingCard01, __Green_BingCard02, ____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [__Green_BingCard02, _Yellow_BingCard02], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [__Green_BingCard02, __White_BingCard02], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [__Green_BingCard01, __Green_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [__Green_BingCard01, __Green_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [__Green_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [__White_BingCard02, _Yellow_BingCard02], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__Green_BingCard01, __White_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [____Red_BingCard02], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [____Red_BingCard02, _Yellow_BingCard02], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {4, [], [____Red_BingCard02, __White_BingCard02], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [____Red_BingCard02], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__Green_BingCard01, ____Red_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {16, [], [], [], [

    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [__White_BingCard01, __White_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [], [

    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [____Red_BingCard01, ____Red_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [], [], [____Red_BingCard01, ____Red_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_08 ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [], [

    ]};
get_handle_of_each_hand_card_08 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 将士相 ===== 9张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_09 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {16, [_4ColorXiangCard01], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01]},

{{eating_single, {_Color, xiang}}, [_4ColorXiangCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {11, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {11, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {16, [_4Color__ShiCard01], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01]},

{{eating_single, {_Color,   shi}}, [_4Color__ShiCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {11, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {9, [], [], [], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {11, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {13, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_09 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {13, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
get_handle_of_each_hand_card_09 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {17, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 车马炮 ===== 9张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_09 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {16, [_4Color__PaoCard01], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01]},

{{eating_single, {_Color,   pao}}, [_4Color__PaoCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [], [], [_4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [], [], [_4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},
{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {16, [_4Color___MaCard01], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01]},

{{eating_single, {_Color,    ma}}, [_4Color___MaCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [], [], [_4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {9, [], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [], [], [_4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [], [], [_4Color__CheCard01, _4Color__CheCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {11, [], [], [_4Color__CheCard01, _4Color__CheCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {16, [_4Color__CheCard01], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01]},

{{eating_single, {_Color,   che}}, [_4Color__CheCard01]}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 9张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    {16, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__White_BingCard01, _Yellow_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {16, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [____Red_BingCard01, _Yellow_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, {   red,  bing}}, [__White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [____Red_BingCard01, __White_BingCard01], [], [
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [__White_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {9, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [_Yellow_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__White_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [_Yellow_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {5, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__White_BingCard01], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [____Red_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [____Red_BingCard01], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [____Red_BingCard01], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [____Red_BingCard01, __White_BingCard01], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {11, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [_Yellow_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {5, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__White_BingCard01], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {5, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {5, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_double, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {16, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__Green_BingCard01, _Yellow_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [__White_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [__Green_BingCard01, __White_BingCard01], [], [
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [__Green_BingCard01, _Yellow_BingCard01], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [__Green_BingCard01, __White_BingCard01], [], [
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, __White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, _Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {8, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_double, { green,  bing}}, [____Red_BingCard01, __White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [__Green_BingCard01, ____Red_BingCard01], [], [
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [__Green_BingCard01, ____Red_BingCard01], [], [
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_09 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_09 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_09 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 将士相 ===== 10张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_10 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {16, [], [], [_4ColorXiangCard01, _4ColorXiangCard02], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]},

{{decree_double, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {14, [], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},
{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {16, [], [], [_4Color__ShiCard01, _4Color__ShiCard02], [

{{decree_double, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {14, [], [], [], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {14, [], [], [], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},
{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {18, [], [], [], [
{{finish_hucard, {_Color, jiang}}, []},

{{onlyone_jiang, {_Color, jiang}}, []}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 车马炮 ===== 10张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_10 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {16, [], [], [_4Color__PaoCard01, _4Color__PaoCard02], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]},

{{decree_double, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {14, [], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},
{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {16, [], [], [_4Color___MaCard01, _4Color___MaCard02], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]},

{{decree_double, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {14, [], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {14, [], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},
{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {16, [], [], [_4Color__CheCard01, _4Color__CheCard02], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]},

{{decree_double, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02]}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 10张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    {16, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [__White_BingCard01, _Yellow_BingCard01], [], [], [

{{eating_single, { white,  bing}}, [__White_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {14, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {16, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {10, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [____Red_BingCard01, _Yellow_BingCard01], [], [], [

{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [____Red_BingCard01, __White_BingCard01], [], [], [

{{eating_single, {   red,  bing}}, [____Red_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {14, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {14, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [__White_BingCard01, __White_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [__Green_BingCard01, ____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [____Red_BingCard01, ____Red_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, __White_BingCard01]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [____Red_BingCard01, __White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [____Red_BingCard01, ____Red_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, { white,  bing}}, [__Green_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {16, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {10, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [__Green_BingCard01, __Green_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [__Green_BingCard01, __Green_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {10, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {6, [], [], [__Green_BingCard01, __Green_BingCard02, ____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {10, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [__Green_BingCard01, _Yellow_BingCard01], [], [], [

{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [__Green_BingCard01, __White_BingCard01], [], [

{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [__Green_BingCard01, ____Red_BingCard01], [], [

{{eating_single, { green,  bing}}, [__Green_BingCard01]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_10 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_10 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_10 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 将士相 ===== 11张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_11 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {19, [], [], [], [
{{finish_hucard, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]},

{{decree_thrice, {_Color, xiang}}, [_4ColorXiangCard01, _4ColorXiangCard02, _4ColorXiangCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {19, [], [], [], [
{{finish_hucard, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]},

{{decree_thrice, {_Color,   shi}}, [_4Color__ShiCard01, _4Color__ShiCard02, _4Color__ShiCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {19, [], [], [], [
{{finish_hucard, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]},

{{decree_thrice, {_Color, jiang}}, [_4ColorJiangCard01, _4ColorJiangCard02, _4ColorJiangCard03]}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 车马炮 ===== 11张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_11 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {19, [], [], [], [
{{finish_hucard, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]},

{{decree_thrice, {_Color,   pao}}, [_4Color__PaoCard01, _4Color__PaoCard02, _4Color__PaoCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {19, [], [], [], [
{{finish_hucard, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]},

{{decree_thrice, {_Color,    ma}}, [_4Color___MaCard01, _4Color___MaCard02, _4Color___MaCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {19, [], [], [], [
{{finish_hucard, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]},

{{decree_thrice, {_Color,   che}}, [_4Color__CheCard01, _4Color__CheCard02, _4Color__CheCard03]}
    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 11张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    {19, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {19, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__White_BingCard01, __White_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [____Red_BingCard01, ____Red_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [____Red_BingCard01, ____Red_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {19, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__White_BingCard01, __White_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [____Red_BingCard01, ____Red_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [____Red_BingCard01, ____Red_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__Green_BingCard01, __Green_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__Green_BingCard01, __Green_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__Green_BingCard01, __Green_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { green,  bing}}, [____Red_BingCard01, __White_BingCard01, _Yellow_BingCard01]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {9, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__Green_BingCard01, __Green_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__Green_BingCard01, __Green_BingCard02, ____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {11, [], [], [__Green_BingCard01, __Green_BingCard02, ____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_11 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_11 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_11 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 将士相 ===== 12张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_12 ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    {24, [], [], [], [

    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 车马炮 ===== 12张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_12 ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    {24, [], [], [], [

    ]};
%% --------------------------------------------------------------------------------
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 12张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    {24, [], [], [], [

    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [__White_BingCard01, __White_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {24, [], [], [], [

    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [____Red_BingCard01, ____Red_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [____Red_BingCard01, ____Red_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {24, [], [], [], [

    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {12, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [__Green_BingCard01, __Green_BingCard02, _Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [__Green_BingCard01, __Green_BingCard02, __White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {14, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {16, [], [], [__Green_BingCard01, __Green_BingCard02, ____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_12 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_12 ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {24, [], [], [], [

    ]};
get_handle_of_each_hand_card_12 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 13张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {24, [_Yellow_BingCard01], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01]},

{{eating_single, {yellow,  bing}}, [_Yellow_BingCard01]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {24, [__White_BingCard01], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01]},

{{eating_single, { white,  bing}}, [__White_BingCard01]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {17, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {24, [____Red_BingCard01], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01]},

{{eating_single, {   red,  bing}}, [____Red_BingCard01]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {17, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {17, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {17, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {19, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_13 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {24, [__Green_BingCard01], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01]},

{{eating_single, { green,  bing}}, [__Green_BingCard01]}
    ]};
get_handle_of_each_hand_card_13 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 14张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_14 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {24, [], [], [_Yellow_BingCard01, _Yellow_BingCard02], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]},

{{decree_double, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02]}
    ]};
get_handle_of_each_hand_card_14 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {22, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_14 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {24, [], [], [__White_BingCard01, __White_BingCard02], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02]},

{{decree_double, { white,  bing}}, [__White_BingCard01, __White_BingCard02]}
    ]};
get_handle_of_each_hand_card_14 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {22, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_14 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {22, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_14 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {24, [], [], [____Red_BingCard01, ____Red_BingCard02], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]},

{{decree_double, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02]}
    ]};
get_handle_of_each_hand_card_14 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {22, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_14 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {22, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_14 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {22, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},
{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_14 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {24, [], [], [__Green_BingCard01, __Green_BingCard02], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]},

{{decree_double, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02]}
    ]};
get_handle_of_each_hand_card_14 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 15张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_15 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {27, [], [], [], [
{{finish_hucard, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]},

{{decree_thrice, {yellow,  bing}}, [_Yellow_BingCard01, _Yellow_BingCard02, _Yellow_BingCard03]}
    ]};
get_handle_of_each_hand_card_15 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {27, [], [], [], [
{{finish_hucard, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]},

{{decree_thrice, { white,  bing}}, [__White_BingCard01, __White_BingCard02, __White_BingCard03]}
    ]};
get_handle_of_each_hand_card_15 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {27, [], [], [], [
{{finish_hucard, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]},

{{decree_thrice, {   red,  bing}}, [____Red_BingCard01, ____Red_BingCard02, ____Red_BingCard03]}
    ]};
get_handle_of_each_hand_card_15 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {27, [], [], [], [
{{finish_hucard, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]},

{{decree_thrice, { green,  bing}}, [__Green_BingCard01, __Green_BingCard02, __Green_BingCard03]}
    ]};
get_handle_of_each_hand_card_15 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).



%% ================================================================================
%% @todo   根据对应长度获取玩家对应手牌默认处理 ===== 四色卒 ===== 16张手牌 =====
%% @return {HeNumber::合数, SingleCardList::单张卡牌列表, Kinds2CardList::配对卡牌列表, DoubleCardList::成双手牌列表, ToSideCardList::可以令吃列表}
get_handle_of_each_hand_card_16 ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    {32, [], [], [], [

    ]};
get_handle_of_each_hand_card_16 (HandCardStyleList) ->
    ?DEBUG("~p(~p):~p", [?MODULE, ?LINE, HandCardStyleList]).




%% ================================================================================
%% @todo   获取玩家边牌列表合数
get_henums_of_side_card_list (EatCardList) ->
    get_henums_of_side_card_list_2(EatCardList, 0).
get_henums_of_side_card_list_2 ([], EatCardHeNumber) ->
    EatCardHeNumber;
get_henums_of_side_card_list_2 ([EachEatCardList | EatCardList], EatCardHeNumber) ->
    get_henums_of_side_card_list_2(
        EatCardList,
        EatCardHeNumber + get_henums_of_each_side_card(EachEatCardList)
    ).

%% @todo   获取玩家对应边牌合数 ===== 将士相 ===== 1张桌面牌 =====
get_henums_of_each_side_card ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}}
]) ->
    1;
%% @todo   获取玩家对应边牌合数 ===== 将士相 ===== 2张桌面牌 =====
get_henums_of_each_side_card ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    0;
get_henums_of_each_side_card ([
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    0;
%% @todo   获取玩家对应边牌合数 ===== 将士相 ===== 3张桌面牌 =====
get_henums_of_each_side_card ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    2;
get_henums_of_each_side_card ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    1;
get_henums_of_each_side_card ([
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    1;
%% @todo   获取玩家对应边牌合数 ===== 将士相 ===== 4张桌面牌 =====
get_henums_of_each_side_card ([
    _4ColorJiangCard01 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard02 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard03 = #four_color_card{color_style = {_Color, jiang}},
    _4ColorJiangCard04 = #four_color_card{color_style = {_Color, jiang}}
]) ->
    6;
get_henums_of_each_side_card ([
    _4Color__ShiCard01 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard02 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard03 = #four_color_card{color_style = {_Color,   shi}},
    _4Color__ShiCard04 = #four_color_card{color_style = {_Color,   shi}}
]) ->
    6;
get_henums_of_each_side_card ([
    _4ColorXiangCard01 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard02 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard03 = #four_color_card{color_style = {_Color, xiang}},
    _4ColorXiangCard04 = #four_color_card{color_style = {_Color, xiang}}
]) ->
    6;
%% --------------------------------------------------------------------------------
%% @todo   获取玩家对应边牌合数 ===== 车马炮 ===== 1张桌面牌 =====
%% @todo   获取玩家对应边牌合数 ===== 车马炮 ===== 2张桌面牌 =====
get_henums_of_each_side_card ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}}
]) ->
    0;
get_henums_of_each_side_card ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    0;
get_henums_of_each_side_card ([
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    0;
%% @todo   获取玩家对应边牌合数 ===== 车马炮 ===== 3张桌面牌 =====
get_henums_of_each_side_card ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}}
]) ->
    1;
get_henums_of_each_side_card ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    1;
get_henums_of_each_side_card ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    1;
get_henums_of_each_side_card ([
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    1;
%% @todo   获取玩家对应边牌合数 ===== 车马炮 ===== 4张桌面牌 =====
get_henums_of_each_side_card ([
    _4Color__CheCard01 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard02 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard03 = #four_color_card{color_style = {_Color,   che}},
    _4Color__CheCard04 = #four_color_card{color_style = {_Color,   che}}
]) ->
    6;
get_henums_of_each_side_card ([
    _4Color___MaCard01 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard02 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard03 = #four_color_card{color_style = {_Color,    ma}},
    _4Color___MaCard04 = #four_color_card{color_style = {_Color,    ma}}
]) ->
    6;
get_henums_of_each_side_card ([
    _4Color__PaoCard01 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard02 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard03 = #four_color_card{color_style = {_Color,   pao}},
    _4Color__PaoCard04 = #four_color_card{color_style = {_Color,   pao}}
]) ->
    6;
%% --------------------------------------------------------------------------------
%% @todo   获取玩家对应边牌合数 ===== 四色卒 ===== 1张桌面牌 =====
%% @todo   获取玩家对应边牌合数 ===== 四色卒 ===== 2张桌面牌 =====
get_henums_of_each_side_card ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}}
]) ->
    0;
get_henums_of_each_side_card ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}}
]) ->
    0;
get_henums_of_each_side_card ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}}
]) ->
    0;
get_henums_of_each_side_card ([
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    0;
%% @todo   获取玩家对应边牌合数 ===== 四色卒 ===== 3张桌面牌 =====
get_henums_of_each_side_card ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}}
]) ->
    1;
get_henums_of_each_side_card ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}}
]) ->
    1;
get_henums_of_each_side_card ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    1;
get_henums_of_each_side_card ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    1;
get_henums_of_each_side_card ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}}
]) ->
    1;
get_henums_of_each_side_card ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    1;
get_henums_of_each_side_card ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}}
]) ->
    1;
get_henums_of_each_side_card ([
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    1;
%% @todo   获取玩家对应边牌合数 ===== 四色卒 ===== 4张桌面牌 =====
get_henums_of_each_side_card ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard02 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard03 = #four_color_card{color_style = { green,  bing}},
    __Green_BingCard04 = #four_color_card{color_style = { green,  bing}}
]) ->
    6;
get_henums_of_each_side_card ([
    __Green_BingCard01 = #four_color_card{color_style = { green,  bing}},
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    4;
get_henums_of_each_side_card ([
    ____Red_BingCard01 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard02 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard03 = #four_color_card{color_style = {   red,  bing}},
    ____Red_BingCard04 = #four_color_card{color_style = {   red,  bing}}
]) ->
    6;
get_henums_of_each_side_card ([
    __White_BingCard01 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard02 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard03 = #four_color_card{color_style = { white,  bing}},
    __White_BingCard04 = #four_color_card{color_style = { white,  bing}}
]) ->
    6;
get_henums_of_each_side_card ([
    _Yellow_BingCard01 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard02 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard03 = #four_color_card{color_style = {yellow,  bing}},
    _Yellow_BingCard04 = #four_color_card{color_style = {yellow,  bing}}
]) ->
    6.


%% @todo   获取下个将玩类型
get_next_todo_type (away_card_finish_hucard) ->
    away_card_decree_thrice;
get_next_todo_type (away_card_decree_thrice) ->
    away_card_decree_double;
get_next_todo_type (away_card_decree_double) ->
    away_card_eating_double;
get_next_todo_type (away_card_eating_double) ->
    away_card_eating_single;
get_next_todo_type (away_card_eating_single) ->
    pump_card;
get_next_todo_type (pump_card_finish_hucard) ->
    pump_card_decree_thrice;
get_next_todo_type (pump_card_decree_thrice) ->
    pump_card_decree_double;
get_next_todo_type (pump_card_decree_double) ->
    pump_card_eating_double;
get_next_todo_type (pump_card_eating_double) ->
    pump_card_eating_single;
get_next_todo_type (pump_card_eating_single) ->
    pump_card_onlyone_jiang;
get_next_todo_type (pump_card_onlyone_jiang) ->
    pump_card.


%% @todo   根据将玩类型获取下个玩家
get_next_player_by_todo_type (away_card_finish_hucard, PlayerRegisteredName) ->
    get_next_player_registered_name(PlayerRegisteredName);
get_next_player_by_todo_type (away_card_decree_thrice, PlayerRegisteredName) ->
    get_next_player_registered_name(PlayerRegisteredName);
get_next_player_by_todo_type (away_card_decree_double, PlayerRegisteredName) ->
    get_next_player_registered_name(PlayerRegisteredName);
get_next_player_by_todo_type (away_card_eating_double, PlayerRegisteredName) ->
    get_next_player_registered_name(PlayerRegisteredName);
get_next_player_by_todo_type (away_card_eating_single, PlayerRegisteredName) ->
    get_next_player_registered_name(PlayerRegisteredName);
get_next_player_by_todo_type (pump_card, PlayerRegisteredName) ->
    get_next_player_registered_name(PlayerRegisteredName);
get_next_player_by_todo_type (_, PlayerRegisteredName) ->
    PlayerRegisteredName.


%% @todo   获取下家进程注册名称
get_next_player_registered_name (?FOUR_COLOR_PLAYER_SRV_A) ->
    ?FOUR_COLOR_PLAYER_SRV_B;
get_next_player_registered_name (?FOUR_COLOR_PLAYER_SRV_B) ->
    ?FOUR_COLOR_PLAYER_SRV_C;
get_next_player_registered_name (?FOUR_COLOR_PLAYER_SRV_C) ->
    ?FOUR_COLOR_PLAYER_SRV_D;
get_next_player_registered_name (?FOUR_COLOR_PLAYER_SRV_D) ->
    ?FOUR_COLOR_PLAYER_SRV_A.


%% @todo   根据将玩类型获取玩家列表
get_player_number_by_todo_type (away_card_finish_hucard) ->
    3;
get_player_number_by_todo_type (away_card_decree_thrice) ->
    3;
get_player_number_by_todo_type (away_card_decree_double) ->
    3;
get_player_number_by_todo_type (away_card_eating_double) ->
    1;
get_player_number_by_todo_type (away_card_eating_single) ->
    1;
get_player_number_by_todo_type (pump_card_finish_hucard) ->
    4;
get_player_number_by_todo_type (pump_card_decree_thrice) ->
    4;
get_player_number_by_todo_type (pump_card_decree_double) ->
    4;
get_player_number_by_todo_type (pump_card_eating_double) ->
    2;
get_player_number_by_todo_type (pump_card_eating_single) ->
    2;
get_player_number_by_todo_type (pump_card_onlyone_jiang) ->
    1;
get_player_number_by_todo_type (_)    ->
    0.












