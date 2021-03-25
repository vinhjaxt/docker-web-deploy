#!/usr/bin/env sh
read -p "mysql root login command (without -e, eg: docker exec -it mysql mysql -uroot -p'12345678'): " mysqlcommand
read -p "database name: " dbname
read -p "database password: " dbpass
eval "$mysqlcommand -e "\""CREATE USER '${dbname}'@'localhost' IDENTIFIED BY '${dbpass}';"\"""
eval "$mysqlcommand -e "\""CREATE USER '${dbname}'@'%' IDENTIFIED BY '${dbpass}';"\"""
eval "$mysqlcommand -e "\""CREATE DATABASE \\\`${dbname}\\\`;"\"""
eval "$mysqlcommand -e "\""GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbname}'@'localhost';"\"""
eval "$mysqlcommand -e "\""GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbname}'@'%';"\"""
eval "$mysqlcommand -e "\""FLUSH PRIVILEGES;"\"""
