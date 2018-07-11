-module (mod_four_color_srv).

-author     ("CHEONGYI").

-compile (export_all).
-export ([
    proc_away_or_pump_card_to_ming/2,       % 处理玩家打出去或摸出来的卡牌成为系统明牌

    init_four_color_card_data/0             % 初始化四色牌数据
]).

-include ("define.hrl").
-include ("record.hrl").



%% ==================== 逻辑处理 ====================
%% @todo   处理玩家打出去或摸出来的卡牌成为系统明牌
proc_away_or_pump_card_to_ming (PlayerRegisteredName, AwayOrPumpCard) ->
    SystemFourColorCard     = get_system_four_color_card(?FOUR_COLOR_SRV),
    NewAwayOrPumpCard       = AwayOrPumpCard #four_color_card{
        from_player         = PlayerRegisteredName,
        final_owner         = ?FOUR_COLOR_SRV
    },
    OldMingCardList         = SystemFourColorCard #system_four_color_card.ming_card_list,
    Sequence                = length(OldMingCardList) + 1,
    NewSystemFourColorCard  = get_system_four_color_card_add_to_ming(
        NewAwayOrPumpCard,
        Sequence,
        SystemFourColorCard #system_four_color_card{
            ming_card_list  = [
                NewAwayOrPumpCard
                |
                OldMingCardList
            ]
        }
    ),
    ?DEBUG("------ ~p:~p ------~n~p ============> (~p)~p~n", [?MODULE, away_or_pump_card_noneed,
        ?FOUR_COLOR_SRV, Sequence, NewAwayOrPumpCard]),
    update_system_four_color_card(NewSystemFourColorCard).


%% @todo   处理摸牌
proc_pump_card (PlayerRegisteredName) ->
    SystemFourColorCard     = get_system_four_color_card(?FOUR_COLOR_SRV),
    SystemDarkCardList      = SystemFourColorCard #system_four_color_card.dark_card_list,
    SystemDarkCardListLen   = length(SystemDarkCardList),
    if
        SystemDarkCardListLen > ?CRAD_COLOR_NUMBER_MAX ->
            [
                PlayerPumpCard
                |
                NewSystemDarkCardList
            ]                       = SystemDarkCardList,
            SystemDarkCardInfoList  = SystemFourColorCard #system_four_color_card.dark_card_info_list,
            Sequence                = length(SystemDarkCardInfoList) + 1,
            NewPlayerPumpCard       = PlayerPumpCard #four_color_card{
                from_player         = PlayerRegisteredName
            },
            NewSystemFourColorCard  = SystemFourColorCard #system_four_color_card{
                dark_card_list      = NewSystemDarkCardList,
                dark_card_info_list = [
                    {Sequence, NewPlayerPumpCard}
                    |
                    SystemDarkCardInfoList
                ]
            },
            ?DEBUG("------ ~p:~p ------~n~p ===> (~p)~p~n", [?MODULE, proc_pump_card,
                PlayerRegisteredName, Sequence, NewPlayerPumpCard]),
            update_system_four_color_card(NewSystemFourColorCard),
            TodoType                = pump_card_finish_hucard,
            Msg                     = {
                TodoType, 
                db_four_color:get_player_number_by_todo_type(TodoType), 
                PlayerRegisteredName,
                NewPlayerPumpCard
            },
            ?FOUR_COLOR_AUTO_SRV ! {isneed_away_or_pump_card, PlayerRegisteredName, Msg};
        true ->
            [
                begin
                    PlayerFourColorCard     = mod_four_color:get_player_four_color_card(EachPlayerRegisteredName),
                    {
                        HandCardHeNumber, 
                        HandSingleCardList, 
                        HandKinds2CardList, 
                        _HandDoubleCardList,
                        _HandToSideCardList
                    } = db_four_color:get_hucard_of_hand_card_by_record(PlayerFourColorCard),
                    ?DEBUG("------ ~p(~p) ------~n~p~n~p~n", [
                        EachPlayerRegisteredName, HandCardHeNumber, HandSingleCardList, HandKinds2CardList])
                end
                ||
                EachPlayerRegisteredName <- ?FOUR_COLOR_PLAYER_SRV_LIST
            ],
            ?FOUR_COLOR_SRV ! {lost_gambling}
    end.



%% ==================== 数据处理 ====================
%% @todo   初始化四色牌数据
init_four_color_card_data () ->
    RandomCardList  = mod_four_color:random_card(),
    {
        RandomCardListToA,
        RandomCardListToB,
        RandomCardListToC,
        RandomCardListToD,
        RandomCardListEnd
    } = mod_four_color:distribute_card(RandomCardList),
    ?FOUR_COLOR_PLAYER_SRV_A ! {distribute_card_to_player, RandomCardListToA},
    ?FOUR_COLOR_PLAYER_SRV_B ! {distribute_card_to_player, RandomCardListToB},
    ?FOUR_COLOR_PLAYER_SRV_C ! {distribute_card_to_player, RandomCardListToC},
    ?FOUR_COLOR_PLAYER_SRV_D ! {distribute_card_to_player, RandomCardListToD},
    init_system_four_color_card(
        #system_four_color_card{
            owner           = ?FOUR_COLOR_SRV,
            dark_card_list  = mod_four_color:set_four_color_card_list_first_owner(
                ?FOUR_COLOR_SRV,
                RandomCardListEnd
            )
        }
    ).


%% @todo   获取系统的四色牌数据
get_system_four_color_card (Owner) ->
    case lib_ets:get(system_four_color_card, Owner) of
        [] ->
            init_system_four_color_card(#system_four_color_card{owner = Owner});
        [SystemFourColorCard] ->
            SystemFourColorCard
    end.

%% @todo   初始化系统的四色牌数据
init_system_four_color_card (SystemFourColorCard) ->
    update_system_four_color_card(SystemFourColorCard).

%% @todo   变更系统的四色牌数据
update_system_four_color_card (SystemFourColorCard) ->
    lib_ets:insert(
        system_four_color_card,
        SystemFourColorCard,
        replace
    ),
    SystemFourColorCard.


%% @todo   获取系统明牌列表（包括玩家手牌打出和暗牌摸出）
get_system_ming_card_list () ->
    SystemFourColorCard = get_system_four_color_card(?FOUR_COLOR_SRV),
    SystemFourColorCard #system_four_color_card.ming_card_list.


%% @todo   获取系统四色牌数据增加明牌
get_system_four_color_card_add_to_ming (
    AwayOrPumpCard      = #four_color_card{from_player  = ?FOUR_COLOR_PLAYER_SRV_A},
    Sequence,
    SystemFourColorCard
) ->
    SystemFourColorCard #system_four_color_card{
        ming_card_info_list_a   = [
            {Sequence, AwayOrPumpCard}
            |
            SystemFourColorCard #system_four_color_card.ming_card_info_list_a
        ]
    };
get_system_four_color_card_add_to_ming (
    AwayOrPumpCard      = #four_color_card{from_player  = ?FOUR_COLOR_PLAYER_SRV_B},
    Sequence,
    SystemFourColorCard
) ->
    SystemFourColorCard #system_four_color_card{
        ming_card_info_list_b   = [
            {Sequence, AwayOrPumpCard}
            |
            SystemFourColorCard #system_four_color_card.ming_card_info_list_b
        ]
    };
get_system_four_color_card_add_to_ming (
    AwayOrPumpCard      = #four_color_card{from_player  = ?FOUR_COLOR_PLAYER_SRV_C},
    Sequence,
    SystemFourColorCard
) ->
    SystemFourColorCard #system_four_color_card{
        ming_card_info_list_c   = [
            {Sequence, AwayOrPumpCard}
            |
            SystemFourColorCard #system_four_color_card.ming_card_info_list_c
        ]
    };
get_system_four_color_card_add_to_ming (
    AwayOrPumpCard      = #four_color_card{from_player  = ?FOUR_COLOR_PLAYER_SRV_D},
    Sequence,
    SystemFourColorCard
) ->
    SystemFourColorCard #system_four_color_card{
        ming_card_info_list_d   = [
            {Sequence, AwayOrPumpCard}
            |
            SystemFourColorCard #system_four_color_card.ming_card_info_list_d
        ]
    }.




