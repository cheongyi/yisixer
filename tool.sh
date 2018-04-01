#!/bin/sh
ulimit -n 1048576
clear
erlc -o tool/ tool/*.erl 
php tool/format.php
erl \
-noshell \
-pa tool/ \
-pa server/ebin/ \
-s tool start \
