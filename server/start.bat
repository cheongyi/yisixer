@echo off

cls

werl                                ^
-boot           start_sasl          ^
-name           farm@192.168.2.169  ^
-pa             ebin                ^
-s              game start          ^
-setcookie      the_14x2_cookie     ^
-env            ERL_MAX_ETS_TABLES  65535 ^
-game                               ^
    gateway_node    'gw@127.0.0.1'  ^
    policy_server   'false'         ^
    server_port     '1428'          ^
    mysql_host      '"127.0.0.1"'   ^
    mysql_port      '3306'          ^
    mysql_username  '"root"'        ^
    mysql_password  '"ybybyb"'      ^
    mysql_database  '"farm"'        ^
    version         '"2017052001"'  ^
    build_code_db   'true'

pause