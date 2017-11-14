-module (mod_four_color).

-author ('Chen HongYi').

-compile (export_all).
-export ([
    random_card/0,                          % 随机打乱四色总牌
    distribute_card/1,                      % 分发手牌
    sort_hand_card/2,                       % 排序手牌
    banker_is_hucard_else_away_card/1,      % 判断庄家是否胡牌否则出牌
    is_player_hucard/1,                     % 玩家是否胡牌
    is_hucard_by_record/1,                  % 根据玩家数据判断是否胡牌
    player_away_card/1,                     % 玩家打出手牌
    player_away_card_update/2,              % 玩家打出手牌变更数据
    player_isneed_away_or_pump_card/1,      % 玩家是否需要打出去或摸出来的卡牌

    get_player_registered_name/0,           % 获取玩家进程注册名称
    get_player_registered_name/1,           % 获取玩家进程注册名称
    init_player_four_color_card/1,          % 初始玩家的四色牌数据
    update_player_four_color_card/1,        % 变更玩家的四色牌数据
    get_player_four_color_card/1,           % 获取玩家的四色牌数据
    get_player_four_color_card_del_away/3,  % 获取玩家的四色牌数据扣除打出去的手牌
    get_player_four_color_card_del_side/3,  % 获取玩家的四色牌数据扣除侧边上的手牌
    get_player_four_color_card_by_change/3, % 获取玩家四色牌数据改变后
    get_player_hand_card_list/1,            % 获取玩家的四色牌手牌列表
    get_player_side_card_list/1,            % 获取玩家的四色牌边牌列表
    get_player_each_hand_card_list/2,       % 获取玩家对应颜色样式手牌列表
    set_four_color_card_list_first_owner/2, % 设置四色牌初始所有者
    set_four_color_card_list_final_owner/2, % 设置四色牌最终所有者

    a/0
]).


-include ("define.hrl").
-include ("record.hrl").



%% ==================== 逻辑处理 ====================
%% @todo   随机打乱四色总牌
random_card () ->
    RandomCardList = [
        {
            lib_misc:random_number(?CARD_TOTAL_NUMBER),
            #four_color_card{
                color_style = {CradColor, CradStyle},
                color       = CradColor,
                style       = CradStyle,
                order       = CardOrder
            } 
        }
        ||
        CradColor <- ?CARD_COLOR_LIST,
        CradStyle <- ?CARD_STYLE_LIST,
        CardOrder <- lists:seq(1, ?SAME_STYLE_NUMBER_MAX)
    ],
    [
        FourColorCard
        ||
        {_RandomNumber, FourColorCard} <- lists:keysort(1, RandomCardList)
    ].


%% @todo   分发手牌
%% @doc    总共七种四张四色112，发给4个人每人20张，庄家多一个，剩下为底牌
distribute_card (RandomCardList) ->
    distribute_card(RandomCardList, 0, {[], [], [], []}).
distribute_card (
    [CardToA | RandomCardListEnd], 
    ?CRAD_HAND_NUMBER_MAX, 
    {RandomCardListToA, RandomCardListToB, RandomCardListToC, RandomCardListToD}
) ->
    {
        [CardToA | RandomCardListToA], 
        RandomCardListToB, 
        RandomCardListToC, 
        RandomCardListToD, 
        RandomCardListEnd
    };
distribute_card (
    [CardToA, CardToB, CardToC, CardToD | RandomCardList], 
    Number, 
    {RandomCardListToA, RandomCardListToB, RandomCardListToC, RandomCardListToD}
) ->
    distribute_card (
        RandomCardList,
        Number + 1, 
        {
            [CardToA | RandomCardListToA], 
            [CardToB | RandomCardListToB], 
            [CardToC | RandomCardListToC], 
            [CardToD | RandomCardListToD]
        }
    ).


%% @todo   排序手牌
sort_hand_card (PlayerRegisteredName, BecomeHandCardList) ->
    sort_hand_card_3(
        PlayerRegisteredName,
        BecomeHandCardList, 
        #player_four_color_card{
            player_id       = PlayerRegisteredName,
            hand_card_list  = set_four_color_card_list_first_owner(
                PlayerRegisteredName,
                lists:sort(BecomeHandCardList)
            )
        }
    ).
sort_hand_card_3 (
    _PlayerRegisteredName,
    [], 
    PlayerFourColorCard = #player_four_color_card{
        four_color_bing_list    = FourColorBingList,
        green_jiang_shi_xiang   = GreenJiangShiXiangList,
        green_che_ma_pao        = GreenCheMaPaoList,
        red_jiang_shi_xiang     = RedJiangShiXiangList,
        red_che_ma_pao          = RedCheMaPaoList,
        white_jiang_shi_xiang   = WhiteJiangShiXiangList,
        white_che_ma_pao        = WhiteCheMaPaoList,
        yellow_jiang_shi_xiang  = YellowJiangShiXiangList,
        yellow_che_ma_pao       = YellowCheMaPaoList
    }
) ->
    PlayerFourColorCard #player_four_color_card{
        four_color_bing_list    = lists:sort(FourColorBingList),
        green_jiang_shi_xiang   = lists:sort(GreenJiangShiXiangList),
        green_che_ma_pao        = lists:sort(GreenCheMaPaoList),
        red_jiang_shi_xiang     = lists:sort(RedJiangShiXiangList),
        red_che_ma_pao          = lists:sort(RedCheMaPaoList),
        white_jiang_shi_xiang   = lists:sort(WhiteJiangShiXiangList),
        white_che_ma_pao        = lists:sort(WhiteCheMaPaoList),
        yellow_jiang_shi_xiang  = lists:sort(YellowJiangShiXiangList),
        yellow_che_ma_pao       = lists:sort(YellowCheMaPaoList)
    };
sort_hand_card_3 (
    PlayerRegisteredName,
    [BecomeHandCard | BecomeHandCardList], 
    OldPlayerFourColorCard
) ->
    PlayerHandCard          = set_four_color_card_first_owner(
        PlayerRegisteredName,
        BecomeHandCard
    ),
    PlayerEachHandCardList  = get_player_each_hand_card_list(
        PlayerHandCard,
        OldPlayerFourColorCard
    ),
    NewPlayerFourColorCard  = get_player_four_color_card_by_change(
        PlayerHandCard,
        OldPlayerFourColorCard,
        [PlayerHandCard | PlayerEachHandCardList]
    ),
    sort_hand_card_3(PlayerRegisteredName, BecomeHandCardList, NewPlayerFourColorCard).


%% @todo   判断庄家是否胡牌否则出牌
banker_is_hucard_else_away_card (PlayerRegisteredName) ->
    case is_player_hucard(PlayerRegisteredName) of
        {true, PlayerRegisteredName, CardHeNumber} ->
            ?FOUR_COLOR_SRV ! {hucard, PlayerRegisteredName, CardHeNumber};
        _ ->
            ?FOUR_COLOR_SRV ! player_away_card(PlayerRegisteredName)
    end.


%% @todo   玩家是否胡牌
is_player_hucard (PlayerRegisteredName) ->
    PlayerFourColorCard     = get_player_four_color_card(PlayerRegisteredName),
    is_hucard_by_record(PlayerFourColorCard).
is_player_hucard_2 (PlayerRegisteredName, AwayOrPumpCard) ->
    PlayerFourColorCard     = get_player_four_color_card(PlayerRegisteredName),
    PlayerEachHandCardList  = get_player_each_hand_card_list(
        AwayOrPumpCard,
        PlayerFourColorCard
    ),
    is_player_hucard_3(PlayerFourColorCard, AwayOrPumpCard, PlayerEachHandCardList).
is_player_hucard_3 (
    PlayerFourColorCard, 
    AwayOrPumpCard  = #four_color_card{style    = ?CARD_STYLE_JIANG}, 
    []
) ->
    PlayerSideCardList      = PlayerFourColorCard #player_four_color_card.side_card_list,
    NewPlayerFourColorCard  = PlayerFourColorCard #player_four_color_card{
        side_card_list      = [[AwayOrPumpCard] | PlayerSideCardList]
    },
    is_hucard_by_record(NewPlayerFourColorCard);
is_player_hucard_3 (PlayerFourColorCard, AwayOrPumpCard, PlayerEachHandCardList) ->
    {
        _HeNumber, 
        _SingleCardList, 
        _Kinds2CardList, 
        _DoubleCardList,
        ToSideCardList
    } = db_four_color:get_handle_of_each_hand_card(PlayerEachHandCardList),
    case lists:keyfind(
        {finish_hucard, AwayOrPumpCard #four_color_card.color_style}, 
        1, 
        ToSideCardList
    ) of
        {_, BecomeSideCardList} ->
            PlayerHandCardList      = PlayerFourColorCard #player_four_color_card.hand_card_list,
            PlayerSideCardList      = PlayerFourColorCard #player_four_color_card.side_card_list,
            PlayerEachSideCardList  = lists:sort([AwayOrPumpCard | BecomeSideCardList]),
            NewPlayerFourColorCard  = get_player_four_color_card_del_side(
                AwayOrPumpCard,
                PlayerFourColorCard #player_four_color_card{
                    hand_card_list  = PlayerHandCardList -- BecomeSideCardList,
                    side_card_list  = [PlayerEachSideCardList | PlayerSideCardList]
                },
                PlayerEachHandCardList -- BecomeSideCardList
            ),
            is_hucard_by_record(NewPlayerFourColorCard);
        _ ->
            {false, PlayerFourColorCard, 0}
    end.


%% @todo   根据玩家数据判断是否胡牌
is_hucard_by_record (PlayerFourColorCard) ->
    PlayerHandCardList      = PlayerFourColorCard #player_four_color_card.hand_card_list,
    PlayerSideCardList      = PlayerFourColorCard #player_four_color_card.side_card_list,
    % 获取手牌合数
    {
        HandCardHeNumber, 
        HandSingleCardList, 
        HandKinds2CardList, 
        _HandDoubleCardList,
        _HandToSideCardList
    } = db_four_color:get_hucard_of_hand_card_by_record(PlayerFourColorCard),
    % 获取吃牌合数
    SideCardHeNumber        = db_four_color:get_henums_of_side_card_list(PlayerSideCardList),
    HandSideHeNumber        = HandCardHeNumber + SideCardHeNumber,
    % 检查卡牌长度是否==21
    HandSideCardLen         = length(PlayerHandCardList) + length(lists:merge(PlayerSideCardList)),
    {
        HandSideHeNumber   >= (?CAN_WIN_HE_NUMBER_MIN - 2) andalso
        HandSideCardLen    == ?CAN_WIN_CARD_LENGTH andalso
        HandSingleCardList == [] andalso
        HandKinds2CardList == [],
        PlayerFourColorCard,
        HandSideHeNumber
    }.


%% @todo   玩家打出手牌
player_away_card (PlayerRegisteredName) ->
    PlayerFourColorCard     = get_player_four_color_card(PlayerRegisteredName),
    {
        _HandCardHeNumber, 
        HandSingleCardList, 
        HandKinds2CardList, 
        HandDoubleCardList,
        _HandToSideCardList
    } = db_four_color:get_handle_of_hand_card_by_record(PlayerFourColorCard),
    PlayerHandCardList      = PlayerFourColorCard #player_four_color_card.hand_card_list,
    PlayerKnowCardList      = PlayerHandCardList ++ get_side_and_ming_card_list(),
    PlayerAwayCard          = if
        HandSingleCardList =/= [] ->
            select_single_hand_card(
                HandSingleCardList,
                PlayerKnowCardList 
            );
        HandKinds2CardList =/= [] ->
            select_kinds2_hand_card(
                HandKinds2CardList,
                PlayerKnowCardList 
            );
        true ->
            lists:nth(
                lib_misc:random_number(length(HandDoubleCardList)), 
                HandDoubleCardList
            )
    end,
    ?DEBUG("------ ~p:~p ------~n~p ===> ~p~n", [?MODULE, player_away_card, 
        PlayerRegisteredName, PlayerAwayCard]),
    player_away_card_update(PlayerRegisteredName, PlayerAwayCard),
    {away_card, PlayerRegisteredName, PlayerAwayCard}.


%% @todo   玩家打出手牌变更数据
player_away_card_update (PlayerRegisteredName, PlayerAwayCard) ->
    PlayerFourColorCard     = get_player_four_color_card(PlayerRegisteredName),
    PlayerHandCardList      = PlayerFourColorCard #player_four_color_card.hand_card_list,
    PlayerAwayCardList      = PlayerFourColorCard #player_four_color_card.away_card_list,
    PlayerEachHandCardList  = get_player_each_hand_card_list(
        PlayerAwayCard, 
        PlayerFourColorCard
    ),
    check_player_away_card(PlayerAwayCard, PlayerEachHandCardList),
    NewPlayerFourColorCard  = get_player_four_color_card_del_away(
        PlayerAwayCard,
        PlayerFourColorCard #player_four_color_card{
            hand_card_list  = PlayerHandCardList -- [PlayerAwayCard],
            away_card_list  = [PlayerAwayCard | PlayerAwayCardList]
        },
        PlayerEachHandCardList -- [PlayerAwayCard]
    ),
    update_player_four_color_card(NewPlayerFourColorCard).


%% @todo   检查玩家出牌
check_player_away_card (#four_color_card{style = ?CARD_STYLE_JIANG}, _PlayerEachHandCardList) ->
    exit(no_jiang);
check_player_away_card (PlayerAwayCard, PlayerEachHandCardList) ->
    SameCardNumber      = length([
        PlayerEachHandCard
        ||
        PlayerEachHandCard <- PlayerEachHandCardList,
        PlayerEachHandCard #four_color_card.color_style == PlayerAwayCard #four_color_card.color_style

    ]),
    if
        SameCardNumber == 1 orelse
        SameCardNumber == 2 ->
            ok;
        SameCardNumber == 3 ->
            exit(no_thrice);
        SameCardNumber == 4 ->
            exit(no_four);
        true ->
            exit(away_card_error)
    end.

%% @todo   选择单个的卡牌
select_single_hand_card ([], _PlayerKnowCardList) ->
    [];
select_single_hand_card (HandSingleCardList, PlayerKnowCardList) ->
    select_single_hand_card_by_know_card(
        HandSingleCardList,
        PlayerKnowCardList, 
        []
    ).
select_single_hand_card_by_know_card ([], _PlayerKnowCardList, Return) ->
    [{HandSingleCard, _} | _] = lists:keysort(2, Return),
    HandSingleCard;
select_single_hand_card_by_know_card (
    [HandSingleCard | HandSingleCardList],
    PlayerKnowCardList,
    Return
) ->
    SameCardNumber      = length([
        PlayerKnowCard
        ||
        PlayerKnowCard <- PlayerKnowCardList,
        PlayerKnowCard #four_color_card.color_style == HandSingleCard #four_color_card.color_style

    ]),
    select_single_hand_card_by_know_card(
        HandSingleCardList,
        PlayerKnowCardList,
        [{HandSingleCard, ?SAME_STYLE_NUMBER_MAX - SameCardNumber} | Return]
    ).

%% @todo   选择成配对的卡牌组合
select_kinds2_hand_card ([], _PlayerKnowCardList) ->
    [];
select_kinds2_hand_card (HandKinds2CardList, PlayerKnowCardList) ->
    select_kinds2_hand_card_by_know_card(
        HandKinds2CardList,
        PlayerKnowCardList, 
        []
    ).

select_kinds2_hand_card_by_know_card ([], _PlayerKnowCardList, Return) ->
    [{HandKinds2Card, _} | _] = lists:keysort(2, Return),
    HandKinds2Card;
select_kinds2_hand_card_by_know_card (
    [[] | HandKinds2CardList], 
    PlayerKnowCardList,
    Return
) ->
    select_kinds2_hand_card_by_know_card(HandKinds2CardList, PlayerKnowCardList, Return);
select_kinds2_hand_card_by_know_card (
    [[HandMatchCard_1, HandMatchCard_2] | HandKinds2CardList], 
    PlayerKnowCardList,
    Return
) ->
    {
        MatchNumber, 
        StyleNumber_1, 
        StyleNumber_2
    } = select_kinds2_hand_card_by_know_card_3(
        HandMatchCard_1 #four_color_card.color_style,
        HandMatchCard_2 #four_color_card.color_style,
        PlayerKnowCardList
    ),
    select_kinds2_hand_card_by_know_card(
        HandKinds2CardList, 
        PlayerKnowCardList, 
        [
            {HandMatchCard_1, {MatchNumber, StyleNumber_1}},
            {HandMatchCard_2, {MatchNumber, StyleNumber_2}} 
            | 
            Return
        ]
    ).

select_kinds2_hand_card_by_know_card_3 (
    {CardColor, ?CARD_STYLE_SHI  }, 
    {CardColor, ?CARD_STYLE_XIANG}, 
    PlayerKnowCardList
) ->
    select_kinds2_hand_card_by_know_card_5(
        {{CardColor, ?CARD_STYLE_JIANG}, {CardColor, ?CARD_STYLE_JIANG}}, 
        {CardColor,  ?CARD_STYLE_SHI  }, 
        {CardColor,  ?CARD_STYLE_XIANG}, 
        {?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_3 (
    {CardColor, ?CARD_STYLE_MA   }, 
    {CardColor, ?CARD_STYLE_PAO  }, 
    PlayerKnowCardList
) ->
    select_kinds2_hand_card_by_know_card_5(
        {{CardColor, ?CARD_STYLE_CHE  }, {CardColor, ?CARD_STYLE_CHE  }}, 
        {CardColor,  ?CARD_STYLE_MA   }, 
        {CardColor,  ?CARD_STYLE_PAO  }, 
        {?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_3 (
    {CardColor, ?CARD_STYLE_CHE  }, 
    {CardColor, ?CARD_STYLE_PAO  }, 
    PlayerKnowCardList
) ->
    select_kinds2_hand_card_by_know_card_5(
        {{CardColor, ?CARD_STYLE_MA   }, {CardColor, ?CARD_STYLE_MA   }}, 
        {CardColor,  ?CARD_STYLE_CHE  }, 
        {CardColor,  ?CARD_STYLE_PAO  }, 
        {?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_3 (
    {CardColor, ?CARD_STYLE_CHE  }, 
    {CardColor, ?CARD_STYLE_MA   }, 
    PlayerKnowCardList
) ->
    select_kinds2_hand_card_by_know_card_5(
        {{CardColor, ?CARD_STYLE_PAO  }, {CardColor, ?CARD_STYLE_PAO  }}, 
        {CardColor,  ?CARD_STYLE_CHE  }, 
        {CardColor,  ?CARD_STYLE_MA   }, 
        {?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_3 (
    {?CARD_COLOR_GREEN, ?CARD_STYLE_BING}, 
    {?CARD_COLOR_RED,   ?CARD_STYLE_BING}, 
    PlayerKnowCardList
) ->
    select_kinds2_hand_card_by_know_card_5(
        {{?CARD_COLOR_WHITE, ?CARD_STYLE_BING}, {?CARD_COLOR_YELLOW, ?CARD_STYLE_BING}}, 
        {?CARD_COLOR_GREEN,  ?CARD_STYLE_BING}, 
        {?CARD_COLOR_RED,    ?CARD_STYLE_BING}, 
        {?SAME_STYLE_NUMBER_MAX * 2, ?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_3 (
    {?CARD_COLOR_GREEN, ?CARD_STYLE_BING}, 
    {?CARD_COLOR_WHITE, ?CARD_STYLE_BING}, 
    PlayerKnowCardList
) ->
    select_kinds2_hand_card_by_know_card_5(
        {{?CARD_COLOR_RED,   ?CARD_STYLE_BING}, {?CARD_COLOR_YELLOW, ?CARD_STYLE_BING}}, 
        {?CARD_COLOR_GREEN,  ?CARD_STYLE_BING}, 
        {?CARD_COLOR_WHITE,  ?CARD_STYLE_BING}, 
        {?SAME_STYLE_NUMBER_MAX * 2, ?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_3 (
    {?CARD_COLOR_GREEN,  ?CARD_STYLE_BING}, 
    {?CARD_COLOR_YELLOW, ?CARD_STYLE_BING}, 
    PlayerKnowCardList
) ->
    select_kinds2_hand_card_by_know_card_5(
        {{?CARD_COLOR_RED,   ?CARD_STYLE_BING}, {?CARD_COLOR_WHITE, ?CARD_STYLE_BING}}, 
        {?CARD_COLOR_GREEN,  ?CARD_STYLE_BING}, 
        {?CARD_COLOR_YELLOW, ?CARD_STYLE_BING}, 
        {?SAME_STYLE_NUMBER_MAX * 2, ?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_3 (
    {?CARD_COLOR_RED,   ?CARD_STYLE_BING}, 
    {?CARD_COLOR_WHITE, ?CARD_STYLE_BING}, 
    PlayerKnowCardList
) ->
    select_kinds2_hand_card_by_know_card_5(
        {{?CARD_COLOR_GREEN, ?CARD_STYLE_BING}, {?CARD_COLOR_YELLOW, ?CARD_STYLE_BING}}, 
        {?CARD_COLOR_RED,    ?CARD_STYLE_BING}, 
        {?CARD_COLOR_WHITE,  ?CARD_STYLE_BING}, 
        {?SAME_STYLE_NUMBER_MAX * 2, ?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_3 (
    {?CARD_COLOR_RED,    ?CARD_STYLE_BING}, 
    {?CARD_COLOR_YELLOW, ?CARD_STYLE_BING}, 
    PlayerKnowCardList
) ->
    select_kinds2_hand_card_by_know_card_5(
        {{?CARD_COLOR_GREEN, ?CARD_STYLE_BING}, {?CARD_COLOR_WHITE, ?CARD_STYLE_BING}}, 
        {?CARD_COLOR_RED,    ?CARD_STYLE_BING}, 
        {?CARD_COLOR_YELLOW, ?CARD_STYLE_BING}, 
        {?SAME_STYLE_NUMBER_MAX * 2, ?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_3 (
    {?CARD_COLOR_WHITE,  ?CARD_STYLE_BING}, 
    {?CARD_COLOR_YELLOW, ?CARD_STYLE_BING}, 
    PlayerKnowCardList
) ->
    select_kinds2_hand_card_by_know_card_5(
        {{?CARD_COLOR_GREEN, ?CARD_STYLE_BING}, {?CARD_COLOR_RED, ?CARD_STYLE_BING}}, 
        {?CARD_COLOR_WHITE,  ?CARD_STYLE_BING}, 
        {?CARD_COLOR_YELLOW, ?CARD_STYLE_BING}, 
        {?SAME_STYLE_NUMBER_MAX * 2, ?SAME_STYLE_NUMBER_MAX, ?SAME_STYLE_NUMBER_MAX},
        PlayerKnowCardList
    ).

select_kinds2_hand_card_by_know_card_5 (
    _CardColorStyleMatch, 
    _CardColorStyle_1, 
    _CardColorStyle_2,
    Return, 
    []
) -> 
    Return;
select_kinds2_hand_card_by_know_card_5 (
    {CardColorStyleMatch_1, CardColorStyleMatch_2}, 
    CardColorStyle_1, 
    CardColorStyle_2, 
    {MatchNumber, StyleNumber_1, StyleNumber_2},
    [#four_color_card{color_style = CardColorStyleMatch_1} | PlayerKnowCardList]
) -> 
    select_kinds2_hand_card_by_know_card_5 (
        {CardColorStyleMatch_1, CardColorStyleMatch_2}, 
        CardColorStyle_1, 
        CardColorStyle_2, 
        {MatchNumber - 1, StyleNumber_1, StyleNumber_2},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_5 (
    {CardColorStyleMatch_1, CardColorStyleMatch_2}, 
    CardColorStyle_1, 
    CardColorStyle_2, 
    {MatchNumber, StyleNumber_1, StyleNumber_2},
    [#four_color_card{color_style = CardColorStyleMatch_2} | PlayerKnowCardList]
) -> 
    select_kinds2_hand_card_by_know_card_5 (
        {CardColorStyleMatch_1, CardColorStyleMatch_2}, 
        CardColorStyle_1, 
        CardColorStyle_2, 
        {MatchNumber - 1, StyleNumber_1, StyleNumber_2},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_5 (
    CardColorStyleMatch, 
    CardColorStyle_1, 
    CardColorStyle_2, 
    {MatchNumber, StyleNumber_1, StyleNumber_2},
    [#four_color_card{color_style = CardColorStyle_1} | PlayerKnowCardList]
) -> 
    select_kinds2_hand_card_by_know_card_5 (
        CardColorStyleMatch, 
        CardColorStyle_1, 
        CardColorStyle_2, 
        {MatchNumber, StyleNumber_1 - 1, StyleNumber_2},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_5 (
    CardColorStyleMatch, 
    CardColorStyle_1, 
    CardColorStyle_2, 
    {MatchNumber, StyleNumber_1, StyleNumber_2},
    [#four_color_card{color_style = CardColorStyle_2} | PlayerKnowCardList]
) -> 
    select_kinds2_hand_card_by_know_card_5 (
        CardColorStyleMatch, 
        CardColorStyle_1, 
        CardColorStyle_2, 
        {MatchNumber, StyleNumber_1, StyleNumber_2 - 1},
        PlayerKnowCardList
    );
select_kinds2_hand_card_by_know_card_5 (
    CardColorStyleMatch, 
    CardColorStyle_1, 
    CardColorStyle_2, 
    {MatchNumber, StyleNumber_1, StyleNumber_2},
    [_PlayerKnowCard | PlayerKnowCardList]
) -> 
    select_kinds2_hand_card_by_know_card_5 (
        CardColorStyleMatch, 
        CardColorStyle_1, 
        CardColorStyle_2, 
        {MatchNumber, StyleNumber_1, StyleNumber_2},
        PlayerKnowCardList
    ).


%% @todo   玩家是否需要打出去或摸出来的卡牌
player_isneed_away_or_pump_card ({
    TodoType, 
    0, 
    FirstPlayerRegisteredName, 
    AwayOrPumpCard
}) ->
    NextTodoType                = db_four_color:get_next_todo_type(TodoType),
    PlayerNumber                = db_four_color:get_player_number_by_todo_type(NextTodoType),
    NextPlayerRegisteredName    = db_four_color:get_next_player_by_todo_type(
        NextTodoType, 
        FirstPlayerRegisteredName
    ),
    Msg                         = case NextTodoType of
        pump_card ->
            ?FOUR_COLOR_SRV ! {
                noneed_away_or_pump_card,
                FirstPlayerRegisteredName, 
                AwayOrPumpCard
            },
            {NextTodoType, NextPlayerRegisteredName};
        _ ->
            {
                isneed_away_or_pump_card,
                NextPlayerRegisteredName,
                {
                    NextTodoType,
                    PlayerNumber,
                    FirstPlayerRegisteredName,
                    AwayOrPumpCard
                }
            }
    end,
    ?FOUR_COLOR_AUTO_SRV ! Msg;
player_isneed_away_or_pump_card ({
    TodoType,
    PlayerNumber,
    FirstPlayerRegisteredName,
    AwayOrPumpCard
}) ->
    PlayerRegisteredName    = get_player_registered_name(),
    PlayerFourColorCard     = get_player_four_color_card(PlayerRegisteredName),
    PlayerEachHandCardList  = get_player_each_hand_card_list(
        AwayOrPumpCard,
        PlayerFourColorCard
    ),
    case player_isneed_away_or_pump_card_4(
        case TodoType of
            pump_card_finish_hucard ->
                away_card_finish_hucard;
            pump_card_decree_thrice ->
                away_card_decree_thrice;
            pump_card_decree_double ->
                away_card_decree_double;
            pump_card_eating_double  ->
                away_card_eating_double;
            pump_card_eating_single  ->
                away_card_eating_single;
            _ ->
                TodoType
        end,
        PlayerEachHandCardList,
        PlayerFourColorCard,
        AwayOrPumpCard
    ) of
        {true, HuCardPlayerFourColorCard, CardHeNumber} ->
            update_player_four_color_card(HuCardPlayerFourColorCard),
            ?FOUR_COLOR_SRV ! {hucard, PlayerRegisteredName, CardHeNumber};
        {ToSideType, BecomeSideCardList} ->
            PlayerHandCardList      = PlayerFourColorCard #player_four_color_card.hand_card_list,
            PlayerSideCardList      = PlayerFourColorCard #player_four_color_card.side_card_list,
            NewAwayOrPumpCard       = AwayOrPumpCard #four_color_card{
                final_owner         = PlayerRegisteredName
            },
            PlayerEachSideCardList  = lists:sort([NewAwayOrPumpCard | BecomeSideCardList]),
            NewPlayerFourColorCard  = get_player_four_color_card_del_side(
                AwayOrPumpCard,
                PlayerFourColorCard #player_four_color_card{
                    hand_card_list  = PlayerHandCardList -- BecomeSideCardList,
                    side_card_list  = [PlayerEachSideCardList | PlayerSideCardList]
                },
                PlayerEachHandCardList -- BecomeSideCardList
            ),
            update_player_four_color_card(NewPlayerFourColorCard),
            ?DEBUG("~p ===> ~p~n~p~n", [PlayerRegisteredName, ToSideType, 
                BecomeSideCardList]),
            timer:sleep(1000),
            ?FOUR_COLOR_SRV ! player_away_card(PlayerRegisteredName);
        _ ->
            NextPlayerRegisteredName = db_four_color:get_next_player_registered_name(PlayerRegisteredName),
            Msg                      = {
                TodoType,
                PlayerNumber - 1,
                FirstPlayerRegisteredName,
                AwayOrPumpCard
            },
            ?FOUR_COLOR_AUTO_SRV ! {isneed_away_or_pump_card, NextPlayerRegisteredName, Msg}
    end.

%% @todo   匹配玩家的手牌(出牌配对令开牌)
player_isneed_away_or_pump_card_4 (
    away_card_finish_hucard,
    _PlayerEachHandCardList,
    PlayerFourColorCard,
    AwayOrPumpCard
) ->
    is_player_hucard_2(
        PlayerFourColorCard #player_four_color_card.player_id,
        AwayOrPumpCard
    );
%% @todo   匹配玩家的手牌(出牌配对令开牌)
player_isneed_away_or_pump_card_4 (
    away_card_decree_thrice,
    PlayerEachHandCardList,
    _PlayerFourColorCard,
    #four_color_card{color_style = ColorStyle}
) ->
    {
        _HeNumber, 
        _SingleCardList, 
        _Kinds2CardList, 
        _DoubleCardList,
        ToSideCardList
    } = db_four_color:get_handle_of_each_hand_card(PlayerEachHandCardList),
    lists:keyfind({decree_thrice, ColorStyle}, 1, ToSideCardList);
%% @todo   匹配玩家的手牌(出牌配对令双牌)
player_isneed_away_or_pump_card_4 (
    away_card_decree_double,
    _PlayerCardStyleList,
    _PlayerFourColorCard,
    #four_color_card{style = ?CARD_STYLE_JIANG}
) ->
    false;
player_isneed_away_or_pump_card_4 (
    away_card_decree_double,
    PlayerEachHandCardList,
    _PlayerFourColorCard,
    #four_color_card{color_style = ColorStyle}
) ->
    {
        _HeNumber, 
        _SingleCardList, 
        _Kinds2CardList, 
        _DoubleCardList,
        ToSideCardList
    } = db_four_color:get_handle_of_each_hand_card(PlayerEachHandCardList),
    lists:keyfind({decree_double, ColorStyle}, 1, ToSideCardList);
%% @todo   匹配玩家的手牌(出牌配对吃牌)
player_isneed_away_or_pump_card_4 (
    away_card_eating_double,
    PlayerEachHandCardList,
    _PlayerFourColorCard,
    #four_color_card{color_style = ColorStyle}
) ->
    {
        _HeNumber, 
        _SingleCardList, 
        _Kinds2CardList, 
        _DoubleCardList,
        ToSideCardList
    } = db_four_color:get_handle_of_each_hand_card(PlayerEachHandCardList),
    lists:keyfind({eating_double, ColorStyle}, 1, ToSideCardList);
%% @todo   匹配玩家的手牌(出牌配对令双牌)
player_isneed_away_or_pump_card_4 (
    away_card_eating_single,
    _PlayerCardStyleList,
    _PlayerFourColorCard,
    #four_color_card{style = ?CARD_STYLE_JIANG}
) ->
    false;
%% @todo   匹配玩家的手牌(出牌配对点牌)
player_isneed_away_or_pump_card_4 (
    away_card_eating_single,
    _PlayerCardStyleCardList,
    PlayerFourColorCard,
    #four_color_card{color_style    = ColorStyle}
) ->
    {
        HandHeNumber, 
        HandSingleCardList, 
        HandKinds2CardList, 
        HandDoubleCardList,
        _HandToSideCardList
    } = db_four_color:get_handle_of_hand_card_by_record(PlayerFourColorCard),
    HandKinds2CardListMerge = lists:merge(HandKinds2CardList),
    HandSingleCardListLen   = length(HandSingleCardList),
    HandKinds2CardListLen   = length(HandKinds2CardListMerge),
    HandDoubleCardListLen   = length(HandDoubleCardList),
    HandDoubleCardHeNumber  = HandDoubleCardListLen / 3,
    case lists:keyfind(
        ColorStyle, 
        #four_color_card.color_style, 
        HandSingleCardList
    ) of
        false ->
            case lists:keyfind(
                ColorStyle, 
                #four_color_card.color_style, 
                HandKinds2CardList
            ) of
                false ->
                    false;
                HandKinds2Card ->
                    HandSingleCardHeNumber  = (HandSingleCardListLen + 1) / 2,
                    HandKinds2CardHeNumber  = (HandKinds2CardListLen - 2) / 3,
                    AbleHeNumber            = HandHeNumber 
                        + HandSingleCardHeNumber 
                        + HandKinds2CardHeNumber 
                        + HandDoubleCardHeNumber,
                    if
                        AbleHeNumber >= ?CAN_WIN_HE_NUMBER_MIN ->
                            {{eating_single, ColorStyle}, [HandKinds2Card]};
                        true ->
                            false
                    end
            end;
        HandSingleCard ->
            HandSingleCardHeNumber  = (HandSingleCardListLen - 1) / 2,
            HandKinds2CardHeNumber  = HandKinds2CardListLen       / 3,
            AbleHeNumber            = HandHeNumber 
                + HandSingleCardHeNumber 
                + HandKinds2CardHeNumber 
                + HandDoubleCardHeNumber,
            if
                AbleHeNumber >= ?CAN_WIN_HE_NUMBER_MIN ->
                    {{eating_single, ColorStyle}, [HandSingleCard]};
                true ->
                    false
            end
    end;
%% @todo   匹配玩家的手牌(出牌配对将牌)
player_isneed_away_or_pump_card_4 (
    pump_card_onlyone_jiang,
    _PlayerCardStyleList,
    _PlayerFourColorCard,
    #four_color_card{style = ?CARD_STYLE_JIANG}
) ->
    {onlyone_jiang, []};
player_isneed_away_or_pump_card_4 (_TodoType, _PlayerCardStyleList, _PlayerFourColorCard, _AwayOrPumpCard) ->
    false.

%% @todo   出牌样式配对吃（兵）牌
away_card_eating_double_bing ([], _PlayerCardStyleList) ->
    [];
away_card_eating_double_bing (
    [EachCardStyleEatingList | CardStyleEatingList], 
    PlayerEachHandCardList
) ->
    IsOneOrTwoList = [
        length([
            Card
            ||
            Card = {{CardColor, CardStyle}, _} <- PlayerEachHandCardList,
            {CardColor, CardStyle} == EachCardStyleEating
        ]) == 1 orelse
        length([
            Card
            ||
            Card = {{CardColor, CardStyle}, _} <- PlayerEachHandCardList,
            {CardColor, CardStyle} == EachCardStyleEating
        ]) == 2
        ||
        EachCardStyleEating <- EachCardStyleEatingList
    ],
    case lists:usort(IsOneOrTwoList) of
        [true] ->
            EachCardStyleEatingList;
        _ ->
            away_card_eating_double_bing(CardStyleEatingList, PlayerEachHandCardList)
    end.



%% ==================== 数据处理 ====================
%% @todo   获取庄家进程注册名称
get_banker_registered_name () ->
    ?FOUR_COLOR_PLAYER_SRV_A.


%% @todo   获取玩家进程注册名称
get_player_registered_name () ->
    get_player_registered_name(self()).
get_player_registered_name (Pid) ->
    {registered_name, RegisteredName} = erlang:process_info(Pid, registered_name),
    RegisteredName.


%% @todo   初始化玩家的四色牌数据
init_player_four_color_card (RandomCardList) ->
    PlayerRegisteredName    = get_player_registered_name(),
    PlayerFourColorCard     = sort_hand_card(PlayerRegisteredName, RandomCardList),
    ?DEBUG("------ ~p:~p ------~n", [PlayerRegisteredName, init_player_four_color_card]),
    update_player_four_color_card(PlayerFourColorCard).


%% @todo   变更玩家的四色牌数据
update_player_four_color_card (PlayerFourColorCard) ->
    lib_ets:insert(
        player_four_color_card,
        PlayerFourColorCard,
        replace
    ),
    PlayerFourColorCard.


%% @todo   获取玩家四色牌数据
get_player_four_color_card () ->
    PlayerRegisteredName    = get_player_registered_name(),
    get_player_four_color_card(PlayerRegisteredName).
get_player_four_color_card (PlayerRegisteredName) ->
    [PlayerFourColorCard]   = lib_ets:get(player_four_color_card, PlayerRegisteredName),
    PlayerFourColorCard.


%% @todo   获取玩家四色牌数据扣除打出去的手牌
get_player_four_color_card_del_away (
    PlayerAwayCard,
    PlayerFourColorCard,
    PlayerEachHandCardList
) ->
    get_player_four_color_card_by_change(
        PlayerAwayCard,
        PlayerFourColorCard,
        PlayerEachHandCardList
    ).

%% @todo   获取玩家四色牌数据扣除侧边上的卡牌
get_player_four_color_card_del_side (
    PlayerAwayCard,
    PlayerFourColorCard,
    PlayerEachHandCardList
) ->
    get_player_four_color_card_by_change(
        PlayerAwayCard,
        PlayerFourColorCard,
        PlayerEachHandCardList
    ).

%% @todo   获取玩家四色牌数据扣除侧边上的卡牌
get_player_four_color_card_by_change (
    #four_color_card{style      = ?CARD_STYLE_BING},
    PlayerFourColorCard,
    PlayerEachHandCardList
) ->
    PlayerFourColorCard #player_four_color_card{
        four_color_bing_list    = PlayerEachHandCardList
    };
get_player_four_color_card_by_change (
    #four_color_card{color_style        = {?CARD_COLOR_GREEN, CardStyle}},
    PlayerFourColorCard,
    PlayerEachHandCardList
) ->
    case CardStyle of
        ?CARD_STYLE_JIANG   ->
            PlayerFourColorCard #player_four_color_card{
                green_jiang_shi_xiang   = PlayerEachHandCardList
            };
        ?CARD_STYLE_SHI     ->
            PlayerFourColorCard #player_four_color_card{
                green_jiang_shi_xiang   = PlayerEachHandCardList
            };
        ?CARD_STYLE_XIANG   ->
            PlayerFourColorCard #player_four_color_card{
                green_jiang_shi_xiang   = PlayerEachHandCardList
            };
        _ ->
            PlayerFourColorCard #player_four_color_card{
                green_che_ma_pao        = PlayerEachHandCardList
            }
    end;
get_player_four_color_card_by_change (
    #four_color_card{color_style        = {?CARD_COLOR_RED, CardStyle}},
    PlayerFourColorCard,
    PlayerEachHandCardList
) ->
    case CardStyle of
        ?CARD_STYLE_JIANG   ->
            PlayerFourColorCard #player_four_color_card{
                red_jiang_shi_xiang     = PlayerEachHandCardList
            };
        ?CARD_STYLE_SHI     ->
            PlayerFourColorCard #player_four_color_card{
                red_jiang_shi_xiang     = PlayerEachHandCardList
            };
        ?CARD_STYLE_XIANG   ->
            PlayerFourColorCard #player_four_color_card{
                red_jiang_shi_xiang     = PlayerEachHandCardList
            };
        _ ->
            PlayerFourColorCard #player_four_color_card{
                red_che_ma_pao          = PlayerEachHandCardList
            }
    end;
get_player_four_color_card_by_change (
    #four_color_card{color_style        = {?CARD_COLOR_WHITE, CardStyle}},
    PlayerFourColorCard,
    PlayerEachHandCardList
) ->
    case CardStyle of
        ?CARD_STYLE_JIANG   ->
            PlayerFourColorCard #player_four_color_card{
                white_jiang_shi_xiang   = PlayerEachHandCardList
            };
        ?CARD_STYLE_SHI     ->
            PlayerFourColorCard #player_four_color_card{
                white_jiang_shi_xiang   = PlayerEachHandCardList
            };
        ?CARD_STYLE_XIANG   ->
            PlayerFourColorCard #player_four_color_card{
                white_jiang_shi_xiang   = PlayerEachHandCardList
            };
        _ ->
            PlayerFourColorCard #player_four_color_card{
                white_che_ma_pao        = PlayerEachHandCardList
            }
    end;
get_player_four_color_card_by_change (
    #four_color_card{color_style        = {?CARD_COLOR_YELLOW, CardStyle}},
    PlayerFourColorCard,
    PlayerEachHandCardList
) ->
    case CardStyle of
        ?CARD_STYLE_JIANG   ->
            PlayerFourColorCard #player_four_color_card{
                yellow_jiang_shi_xiang  = PlayerEachHandCardList
            };
        ?CARD_STYLE_SHI     ->
            PlayerFourColorCard #player_four_color_card{
                yellow_jiang_shi_xiang  = PlayerEachHandCardList
            };
        ?CARD_STYLE_XIANG   ->
            PlayerFourColorCard #player_four_color_card{
                yellow_jiang_shi_xiang  = PlayerEachHandCardList
            };
        _ ->
            PlayerFourColorCard #player_four_color_card{
                yellow_che_ma_pao       = PlayerEachHandCardList
            }
    end.


%% @todo   获取玩家四色牌手牌列表
get_player_hand_card_list (PlayerRegisteredName) ->
    PlayerFourColorCard = get_player_four_color_card(PlayerRegisteredName),
    PlayerFourColorCard #player_four_color_card.hand_card_list.

%% @todo   获取玩家四色牌边牌列表
get_player_side_card_list (PlayerRegisteredName) ->
    PlayerFourColorCard = get_player_four_color_card(PlayerRegisteredName),
    PlayerFourColorCard #player_four_color_card.side_card_list.


%% @todo   获取玩家的对应颜色样式手牌列表
get_player_each_hand_card_list (
    #four_color_card{style  = ?CARD_STYLE_BING},
    PlayerFourColorCard
) ->
    PlayerFourColorCard #player_four_color_card.four_color_bing_list;
get_player_each_hand_card_list (
    #four_color_card{color_style    = {?CARD_COLOR_GREEN, CardStyle}},
    PlayerFourColorCard
) ->
    case CardStyle of
        ?CARD_STYLE_JIANG   ->
            PlayerFourColorCard #player_four_color_card.green_jiang_shi_xiang;
        ?CARD_STYLE_SHI     ->
            PlayerFourColorCard #player_four_color_card.green_jiang_shi_xiang;
        ?CARD_STYLE_XIANG   ->
            PlayerFourColorCard #player_four_color_card.green_jiang_shi_xiang;
        _ ->
            PlayerFourColorCard #player_four_color_card.green_che_ma_pao
    end;
get_player_each_hand_card_list (
    #four_color_card{color_style    = {?CARD_COLOR_RED, CardStyle}},
    PlayerFourColorCard
) ->
    case CardStyle of
        ?CARD_STYLE_JIANG   ->
            PlayerFourColorCard #player_four_color_card.red_jiang_shi_xiang;
        ?CARD_STYLE_SHI     ->
            PlayerFourColorCard #player_four_color_card.red_jiang_shi_xiang;
        ?CARD_STYLE_XIANG   ->
            PlayerFourColorCard #player_four_color_card.red_jiang_shi_xiang;
        _ ->
            PlayerFourColorCard #player_four_color_card.red_che_ma_pao
    end;
get_player_each_hand_card_list (
    #four_color_card{color_style    = {?CARD_COLOR_WHITE, CardStyle}},
    PlayerFourColorCard
) ->
    case CardStyle of
        ?CARD_STYLE_JIANG   ->
            PlayerFourColorCard #player_four_color_card.white_jiang_shi_xiang;
        ?CARD_STYLE_SHI     ->
            PlayerFourColorCard #player_four_color_card.white_jiang_shi_xiang;
        ?CARD_STYLE_XIANG   ->
            PlayerFourColorCard #player_four_color_card.white_jiang_shi_xiang;
        _ ->
            PlayerFourColorCard #player_four_color_card.white_che_ma_pao
    end;
get_player_each_hand_card_list (
    #four_color_card{color_style    = {?CARD_COLOR_YELLOW, CardStyle}},
    PlayerFourColorCard
) ->
    case CardStyle of
        ?CARD_STYLE_JIANG   ->
            PlayerFourColorCard #player_four_color_card.yellow_jiang_shi_xiang;
        ?CARD_STYLE_SHI     ->
            PlayerFourColorCard #player_four_color_card.yellow_jiang_shi_xiang;
        ?CARD_STYLE_XIANG   ->
            PlayerFourColorCard #player_four_color_card.yellow_jiang_shi_xiang;
        _ ->
            PlayerFourColorCard #player_four_color_card.yellow_che_ma_pao
    end.


%% @todo   获取玩家侧边上和系统明面上的卡牌列表（包括所有玩家吃牌和打出摸出无用卡牌）
get_side_and_ming_card_list () ->
    AllPlayerSideCardList   = get_all_player_side_card_list(),
    SystemMingCardList      = mod_four_color_srv:get_system_ming_card_list(),
    AllPlayerSideCardList ++ SystemMingCardList.

%% @todo   获取所有玩家侧边上的卡牌列表
get_all_player_side_card_list () ->
    get_all_player_side_card_list_2(?FOUR_COLOR_PLAYER_SRV_LIST, []).
get_all_player_side_card_list_2 ([], AllSideCardList) ->
    AllSideCardList;
get_all_player_side_card_list_2 ([PlayerRegisteredName | PlayerNameList], AllSideCardList) ->
    PlayerSideCardList  = get_player_side_card_list(PlayerRegisteredName),
    get_all_player_side_card_list_2(
        PlayerNameList,
        lists:merge(PlayerSideCardList) ++ AllSideCardList
    ).


%% @todo   设置四色牌的初始所有者
set_four_color_card_first_owner (Owner, FourColorCard) ->
    FourColorCard #four_color_card{first_owner  = Owner}.
set_four_color_card_list_first_owner (_Owner, []) ->
    [];
set_four_color_card_list_first_owner (Owner, FourColorCardList) ->
    [
        set_four_color_card_first_owner(Owner, FourColorCard)
        ||
        FourColorCard <- FourColorCardList
    ].

%% @todo   设置四色牌的最终所有者
set_four_color_card_final_owner (Owner, FourColorCard) ->
    FourColorCard #four_color_card{final_owner  = Owner}.
set_four_color_card_list_final_owner (_Owner, []) ->
    [];
set_four_color_card_list_final_owner (Owner, FourColorCardList) ->
    [
        set_four_color_card_final_owner(Owner, FourColorCard)
        ||
        FourColorCard <- FourColorCardList
    ].
    

a () ->
    CardList = mod_four_color:sort_hand_card(
        lists:sublist(mod_four_color:random_card(), 20)
    ),
    {
        player_away_card(get_banker_registered_name()),
        CardList
    }.






