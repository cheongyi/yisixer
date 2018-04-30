#!/bin/sh
ulimit -n 1024
clear
rm -rf server/include/api/*.hrl 
rm -rf server/src/api_out/*.erl 
rm -rf server/ebin/api_*_out.beam 
cd tool/PHP
php tool.php $1