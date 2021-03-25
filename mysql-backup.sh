#!/usr/bin/env sh
read -p "mysqldump login command (without -e, eg: docker exec -it mysql mysqldump -uroot -p'12345678'): " mysqlcommand
read -p "Database name: " dbname
eval "$mysqlcommand "\""${dbname}"\"" -R -e --triggers --single-transaction > "\""database_${dbname}_backup.sql"\"" "
