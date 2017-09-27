{application, game, [
    {description, "The game server of yisixer."},
    {mod, {game, []}},
    {vsn, "1.0.0"},
    {applications, []},
    {env, [
        {version, "2017092701"},
        {release, "r100"},
        {server_id, "s0"},                  %% 服务器ID
        {socket_server_max_conn, 10000},    %% 游戏Socket服务器最大连接数
        {policy_acceptor, 5},               %% 游戏服务器Acceptor进程数量
        {socket_acceptor, 5},               %% Flash策略文件服务器Acceptor进程数量
        
        {mysql_host, "localhost"},          %% 游戏数据库服务器地址
        {mysql_port, 3306},                 %% 游戏数据库服务器端口
        {mysql_username, "root"},           %% 游戏数据库服务器账号
        {mysql_password, "ybybyb"},         %% 游戏数据库服务器密码
        {mysql_database, "yisixer"},        %% 游戏数据库名称
        {mysql_poolsize, 1},                %% 游戏数据库连接池连接数

        {build_code_db, true},              %% 启动时是否重新生成code_db
        {branch, cn}                        %% 分支标识,cn:内网
    ]}
]}.
