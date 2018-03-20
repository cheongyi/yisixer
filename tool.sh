#!/bin/sh
clear
erlc -o tool/ tool/tool.erl
php tool/format.php
erl \
-noshell \
-pa tool/ \
-s tool start \
