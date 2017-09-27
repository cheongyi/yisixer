#!/bin/sh
# 符号#!用来告诉系统它后面的参数是用来执行该文件的程序,我们使用/bin/sh来执行程序.

# 变量赋值
PROJECT_DIR=~/Desktop
PROJECT_NAME=yisixer

# 创建项目总文件夹目录
cd $PROJECT_DIR
mkdir -p $PROJECT_NAME
cd ./$PROJECT_NAME
touch .README.txt


############################################################
# 创建客户端文件夹目录
mkdir -p client
cd ./client
    touch .README_client.txt
    cd ..


# 创建数据库文件夹目录
mkdir -p database
cd ./database
    mkdir -p backup
    mkdir -p changes
    mkdir -p changes_log
    mkdir -p update
    touch .README_database.txt
    touch conf.php
    touch main.php
    cd ..


# 创建服务端文件夹目录
mkdir -p server
cd ./server
    mkdir -p ebin                           # 用于存放编译好的beam文件
    cd ./ebin
        touch Emakefile                     # erlang的编译相关参数
        touch game.app                      # erlang的game应用application相关参数
        cd ..

    mkdir -p include                        # 用于存放hrl头文件
    cd ./include
        mkdir -p api
        cd ./api
            touch api_test.hrl
            cd ..
        mkdir -p gen
        touch define.hrl                    # 头文件   宏定义
        touch emysql.hrl                    # 头文件   Erlang MySQL数据库
        touch record.hrl                    # 头文件   记录
        cd ..

    mkdir -p log                            # 用于存放log日志文件,可按照日期区分

    mkdir -p protocol                       # 用于存放通讯协议文件
    cd ./protocol
        touch 000_test.txt
        cd ..

    mkdir -p src                            # 用于存放erl源文件
    cd ./src
        mkdir -p api                        # API接口,与客户端交互
        cd ./api
            touch api_test.erl
            cd ..
        mkdir -p gen                        # 工具生成的源文件
        cd ./gen
            mkdir -p api_out
            cd ./api_out
                touch api_tets_out.erl
                cd ..
			mkdir -p code_db
            cd ..
        # mkdir -p kernel                     # 核心源文件
        mkdir -p lib                        # 公用库函数源文件
        mkdir -p mod                        # MOD模块,逻辑处理
        cd ./mod
            touch mod_test.erl
            cd ..
        mkdir -p process                    # 进程相关源文件
        cd ./process
            mkdir -p test
            cd ./test
                touch test_sup.erl
                touch test_srv.erl
                cd ..
            cd ..
        mkdir -p system                     # 系统相关源文件
        cd ./system
            touch game.erl
            cd ..
        # mkdir -p template                   # 模板文件
        cd ..
    touch .README_server.txt
    touch build.sh
    chmod +x ./build.sh
    touch start.sh
    chmod +x ./start.sh
    cd ..


# 创建站点文件夹目录
mkdir -p server_web
cd ./server_web
    touch .README_web.txt
    cd ..


# 创建工具文件夹目录
mkdir -p tool
cd ./tool
    touch .README_tool.txt
    cd ..




