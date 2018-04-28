#!/bin/sh
ulimit -n 1024
clear
rm -rf server/include/api/*.hrl server/src/gen/api_out/*.erl server/src/gen/*.erl ebin/*.beam
cd tool
erlc -o ../server/ebin/ *.erl
php tool.php $1