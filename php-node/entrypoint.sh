#!/bin/sh
touch /home/logs/error.log /home/logs/access.log
chown www-data:www-data /home/logs/ -R
exec docker-php-entrypoint "$@"
