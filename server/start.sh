#!/bin/sh
if [ $# == 1 ]; then
erl \
+P 100000 \
-boot start_sasl \
-name yisixer@127.0.0.1 \
-pa ebin \
-s game start \
-setcookie the_14x2_cookie \
-env ERL_MAX_ETS_TABLES 65535 \
-game \
    gateway_node            'gw@127.0.0.1' \
    policy_server           'false' \
    server_port             '1428' \
    mysql_host              '"127.0.0.1"' \
    mysql_port              '3306' \
    mysql_username          '"root"' \
    mysql_password          '"wlwlwl"' \
    mysql_database          '"yisixer"' \
    build_code_db           'true' \
    version                 '"2017052001"'
else
erl \
+P 100000 \
-boot start_sasl \
-name yisixer@127.0.0.1 \
-pa ebin \
-s game start \
-setcookie the_14x2_cookie \
-env ERL_MAX_ETS_TABLES 65535 \
-game \
    gateway_node            'gw@127.0.0.1' \
    policy_server           'false' \
    server_port             '1428' \
    mysql_host              '"127.0.0.1"' \
    mysql_port              '3306' \
    mysql_username          '"root"' \
    mysql_password          '"ybybyb"' \
    mysql_database          '"yisixer"' \
    build_code_db           'true' \
    version                 '"2017052001"'
fi



