#!/bin/sh
ulimit -n 1024
clear
cd tool
erlc -o ../server/ebin/ *.erl
php tool.php $1