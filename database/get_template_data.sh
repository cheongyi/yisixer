#!/bin/sh
php main.php clone trunk
php main.php cloneback localhost
rm -rf changes/templete_data.clone.php
