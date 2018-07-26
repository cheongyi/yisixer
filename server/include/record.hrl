%% 客户端连接状态
-record (client_state, {
    sock,           % 套接字
    sender,         % 发送数据进程
    sender_monitor, % 发送数据进程的监控引用
    player_id,          %% 玩家ID（登录后有效）
    nickname,           %% 玩家昵称（登录后有效）
    town_id,            %% 玩家所在城镇ID（进入城镇后有效）
    in_wallows,         %% 是否进入防沉迷(true,false)
    in_act = null,      %% 正在参加的活动
    area_id,
    login_time,
    source,
    scene_id,               % 跨服城镇战区ID
    super_town_id,          % 玩家所在超级城镇ID
    super_town_area_id,     % 超级城镇分线ID
    super_town_group_id,    % 超级城镇组id(跨服世界boss)   
    platform                % 平台名称
}).


%% 在线玩家
-record(online_player, {
    player_id,      %玩家ID
    socket,         %玩家套接字
    process_id,     %玩家进程ID
    vip_level = 0
}).
