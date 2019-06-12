#!/bin/bash
# script to backup MySQL databases;
backup_date=$(date +"%Y%m%d")
TARGET="/var/mysql_backups/$backup_date"
DBs="$(mysql -Bse 'show databases')"

mkdir -p $TARGET                                                                                                                                  

# find directories older than 7 days
# then remove it
find /var/dump_sql -type d -mtime +7 #-exec rm {} \;

for db in ${DBs[@]}; do
    tables=$(mysql $db -Bse 'show tables')

    # check if it is not a system database
    if [[ $db != "lost+found" && $db != "mysql" && $db != "performance_schema" && $db != "information_schema" ]]; then
        # create database directory
        mkdir -p $TARGET/$db

        for table in ${tables[@]}; do
            mysqldump $db $table > $TARGET/$db/$table.sql
            bzip2 $TARGET/$db/$table.sql
        done
        echo "backed up $db in $TARGET/$db"
    fi
done





