%% 客户端连接状态
-record (client_state, {
    sock,           % 套接字
    sock_ssl,       % 套接字SSL
    sender,         % 发送数据进程
    sender_monitor, % 发送数据进程的监控引用
    player_id,          %% 玩家ID（登录后有效）
    nickname,           %% 玩家昵称（登录后有效）
    town_id,            %% 玩家所在城镇ID（进入城镇后有效）
    in_wallows,         %% 是否进入防沉迷(true,false)
    in_act = null,      %% 正在参加的活动
    login_time,
    source,
    platform                % 平台名称
}).


%% 在线玩家
-record(online_player, {
    player_id,      %玩家ID
    socket,         %玩家套接字
    process_id,     %玩家进程ID
    vip_level = 0
}).


%%% ========== ======================================== ====================
-record (player_four_color_card, {
    player_id,
    hand_card_list          = [],       % 玩家手里面的卡牌列表[#four_color_card{}...]
    side_card_list          = [],       % 玩家侧边上的卡牌列表[#four_color_card{}...]
    away_card_list          = [],       % 玩家打出去的卡牌列表[#four_color_card{}...]
    four_color_bing_list    = [],       % 玩家的四色兵卡牌列表[#four_color_card{}...]
    green_jiang_shi_xiang   = [],       % 玩家绿将士相卡牌列表[#four_color_card{}...]
    green_che_ma_pao        = [],       % 玩家绿车马炮卡牌列表[#four_color_card{}...]
    red_jiang_shi_xiang     = [],       % 玩家红将士相卡牌列表[#four_color_card{}...]
    red_che_ma_pao          = [],       % 玩家红车马炮卡牌列表[#four_color_card{}...]
    white_jiang_shi_xiang   = [],       % 玩家白将士相卡牌列表[#four_color_card{}...]
    white_che_ma_pao        = [],       % 玩家白车马炮卡牌列表[#four_color_card{}...]
    yellow_jiang_shi_xiang  = [],       % 玩家黄将士相卡牌列表[#four_color_card{}...]
    yellow_che_ma_pao       = []        % 玩家黄车马炮卡牌列表[#four_color_card{}...]
}).
-record (system_four_color_card, {
    owner,
    dark_card_list          = [],       % 系统未摸出的卡牌列表[#four_color_card{}...]
    dark_card_info_list     = [],       % 系统未摸出的卡牌信息列表[{sequence, #four_color_card{}}...]
    ming_card_list          = [],       % 玩家用不了的卡牌列表[#four_color_card{}...]
    ming_card_info_list_a   = [],       % 玩家用不了的卡牌信息列表A[{sequence, #four_color_card{}}...]
    ming_card_info_list_b   = [],       % 玩家用不了的卡牌信息列表B[{sequence, #four_color_card{}}...]
    ming_card_info_list_c   = [],       % 玩家用不了的卡牌信息列表C[{sequence, #four_color_card{}}...]
    ming_card_info_list_d   = []        % 玩家用不了的卡牌信息列表D[{sequence, #four_color_card{}}...]
}).
-record (four_color_card, {
    color_style,                        % {#four_color_card.color, #four_color_card.style}
    color,                              % 卡牌颜色 - 青红白黄
    style,                              % 卡牌样式 - 将士相车马炮兵
    order,                              % 卡牌序号 - 1, 2, 3, 4
    first_owner,                        % 初始所有者
    from_player,                        % 出自的玩家
    final_owner                         % 最终所有者
}).
