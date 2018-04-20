#!/bin/sh
mysql -uroot -p -e "
SELECT concat('delete from ', table_name, ';') AS '--' FROM information_schema.tables WHERE table_schema = '$1';
quit" > delete_all.sql

mysql -uroot -p $1 < delete_all.sql