-module (release_check).

%% @doc    打包检查,根据这个模块的beam文件是否存在来判断前面的编译是否失败

-author     ("CHEONGYI").
-date       ({2017, 11, 09}).
-vsn        ("1.0.0").
-copyright  ("Copyright © 2017 YiSiXEr").

-compile (export_all).

% -include("define.hrl").


%%% ========== ======================================== ====================
%%% External   API
%%% ========== ======================================== ====================
%%% @doc    😄祈祷猪神,打包顺利!😄
start () ->
    os:cmd("ls -l ebin/*.beam | wc -l").



%%                             _ooOoo_  
%%                            o8888888o  
%%                            88" . "88  
%%                            (| -_- |)  
%%                             O\ = /O  
%%                         ____/`---'\____  
%%                       .   ' \\| |// `.  
%%                        / \\||| : |||// \  
%%                      / _||||| -:- |||||- \  
%%                        | | \\\ - /// | |  
%%                      | \_| ''\---/'' | |  
%%                       \ .-\__ `-` ___/-. /  
%%                    ___`. .' /--.--\ `. . __  
%%                 ."" '< `.___\_<|>_/___.' >'"".  
%%                | | : `- \`.;`\ _ /`;.`/ - ` : | |  
%%                  \ \ `-. \_ __\ /__ _/ .-` / /  
%%          ======`-.____`-.___\_____/___.-`____.-'======  
%%                             `=---='  
%%   
%%          ............................................. 
%%                    佛祖保佑             永无BUG
