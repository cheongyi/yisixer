#!/bin/sh
php main.php clone trunk
php main.php cloneback localhost
rm -rf template_data.clone.php
