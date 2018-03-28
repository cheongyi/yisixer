#!/bin/sh
ulimit -n 1048576
clear
erlc -o tool/ tool/tool.erl tool/server_protocol.erl tool/api_hrl.erl tool/api_out.erl
php tool/format.php
erl \
-noshell \
-pa tool/ \
-pa server/ebin/ \
-s tool start \
