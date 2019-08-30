-module (admin).

%%% @doc    游戏服更新管理
%%% 机器环境
% DEV | SIT | UAT | PUAT | PRO

%%% 各游戏服目录环境
% normal(normal_server) | demo(try_server)

%%% 更新步骤
% 0.进入对应游戏服目录
% cd xxx/normal_or_demo
% 1.关闭游戏服
% bin/xxx stop
% 2.删除配置
% rm releases -rf
% 3.解压新的游戏代码包
% tar zxf normal_xxx.vsn.tar.gz
% 4.启动游戏服
% bin/xxx start
% 5.判断是否启动成功
% bin/xxx ping

-copyright  ("Copyright © 2019 Tools@YiSiXEr").
-author     ("cheongyi").
-date       ({2019, 08, 01}).
-vsn        ("1.0.0").

-export ([
    gen_config/0,               % 生成配置
    get_config_list/1,          % 获取对应目录下的游戏配置
    get_game_config_list/1,     % 获取对应游戏配置
    get_game_mode_config_list/1 % 获取对应模式配置
]).

-define (GEN_CONFIG_FILE_NAME, "gen_config.txt").   % 生成配置文件名
-define (FORMAT_SPACE_NUMBER, 20).  % 格式化空格数
-define (NON_GAME_LIST, ["cowboy", "database", "casino", "niuniu", "r_texa_server"]).
-define (MODE_LIST, ["normal", "normal_server", "demo", "try_server", "try"]).

-define (DIR_BIN,       "bin").         % 可执行文件目录
-define (DIR_RELEASES,  "releases").    % releases目录

-define (SIT_DIR_LIST, [
    "bgf_chess_server", "black_jack",
    "casino", "chudadi", "cowboy",
    "database", "dezhou", "doudizhu",
    "flip_chess",
    "happybonuses",
    "majiang_xz", "mj",
    "niuniu",
    "qyxz",
    "r_dice",
    "r_texa_server",
    "showhand",
    "xinyunshou",
    "zhajinhuaduoren"
]).



%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    根据当前目录生成对应的游戏配置
gen_config () ->
    % {ok, File}          = file:open(?GEN_CONFIG_FILE_NAME, [write]),
    {ok, CurDir}        = file:get_cwd(),
    User                = remove_space_tabs_newline(os:cmd("whoami")),
    io:format("=== Working directory is on ~p ~s===~n", [CurDir, format_space(CurDir)]),
    io:format("=== Login   USER      is    ~p ~s===~n", [User,   format_space(User)]),
    get_config_list(CurDir).
    % file:close(File),
    % ok.


%%% @doc    获取对应目录下的游戏配置
get_config_list (CurDir) ->
    {ok, GameList}   = file:list_dir(CurDir),
    [
        get_game_config_list(filename:join(CurDir, Game))
        ||
        Game <- GameList -- ?NON_GAME_LIST,
        filelib:is_dir(Game)
    ].

%%% @doc    获取对应游戏配置
get_game_config_list (GameDir) ->
    Game            = filename:basename(GameDir),
    {ok, ModeList}  = file:list_dir(GameDir),
    #{Game => [
        get_game_mode_config_list(filename:join(GameDir, Mode))
        ||
        Mode <- ModeList,
        lists:member(Mode, ?MODE_LIST)
    ]}.


%%% @doc    获取对应模式配置
get_game_mode_config_list (GameModeDir) ->
    %% 获取游戏根目录
    Game    = filename:basename(filename:dirname(GameModeDir)),
    Mode    = filename:basename(GameModeDir),
    %% 获取可执行文件
    BinDir  = filename:join(GameModeDir, ?DIR_BIN), % data/game/qyxz/normal/bin
    BinExe  = case filelib:is_file(filename:join(BinDir, Game)) of
        true ->
            filename:join(?DIR_BIN, Game);  % bin/bgf_qyxz_server
        _ ->
            case file:list_dir(BinDir) of
                {ok, ExeList} ->
                    case [
                        ExeFile
                        ||
                        ExeFile <- ExeList,
                            filelib:is_file(filename:join(BinDir, ExeFile)) andalso
                            string:chr(ExeFile, $.) == 0 andalso (
                                string:str(Game,    string:substr(ExeFile, 1, 2)) > 0 orelse
                                string:str(ExeFile, string:substr(Game,    1, 2)) > 0
                            )
                    ] of
                        [TheExeFile | _] ->
                            filename:join(?DIR_BIN, TheExeFile);
                        _ ->
                            "undefined"
                    end;
                _ ->
                    "undefined"
            end
    end,
    %% 获取游戏端口
    ExeDir  = filename:join(GameModeDir, BinExe),
    Port    = case remove_space_tabs_newline(
        os:cmd(ExeDir ++ " eval 'application:get_env(bg_net, ports)'")
    ) of
        "{ok,[" ++ PortEval ->
            hd(string:tokens(PortEval, "]"));
        _ ->
            "undefined"
    end,
    %% 获取最大版本号
    MaxVsn          = case file:list_dir(filename:join(GameModeDir, ?DIR_RELEASES)) of
        {ok, LsRelease} ->
            lists:max([
                Vsn
                ||
                Vsn <- LsRelease,
                string:chr(Vsn, $.) == 2
            ]);
        _ ->
            "undefined"
    end,
    #{Mode => #{
        "bin"  => BinExe,   % 可执行文件 => bin/bgf_qyxz_server
        "port" => Port,     % 游戏端口
        "vsn"  => MaxVsn,   % releases最大版本
        "ping" => remove_space_tabs_newline(os:cmd(ExeDir ++ " ping"))   % 状态
    }}.



%%% ========== ======================================== ====================
%%% Internal   API
%%% ========== ======================================== ====================
%%% @doc    去除空格和换行
remove_space_tabs_newline ("\n")        -> "";
remove_space_tabs_newline (Data) ->
    remove_space_tabs_newline(Data, [" ", "\t", "\n"]).
remove_space_tabs_newline (Data, [RemoveChar | List]) ->
    case Data -- RemoveChar of
        Data ->
            remove_space_tabs_newline(Data, List);
        RemoveData ->
            remove_space_tabs_newline(RemoveData, [RemoveChar | List])
    end;
remove_space_tabs_newline (Data, []) ->
    Data.

%%% @doc    格式化空格
format_space (Fromat) ->
    string:copies(" ", ?FORMAT_SPACE_NUMBER - length(Fromat)).

