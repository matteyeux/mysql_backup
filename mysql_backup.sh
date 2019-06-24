#!/bin/bash
# script to backup MySQL databases;

backup_date=$(date +"%Y%m%d")
TARGET="/var/dump_sql/$backup_date"
DBs="$(mysql -Bse 'show databases')"

mkdir -p $TARGET

echo $backup_date > /var/dump_sql/.lastest_dir

# find directories older than 7 days
# then remove it
find /var/dump_sql -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;
                                                                                                                                                                                                                   
for db in ${DBs[@]}; do
        tables=$(mysql $db -Bse 'show tables')
        
        # check if it is not a system database
        if [[ $db != "lost+found" && $db != "mysql" && $db != "performance_schema" && $db != "information_schema" ]]; then
                # create database directory 
                mkdir -p $TARGET/$db
                echo "$(date +'%d-%m-%y - %H:%M:%S') : backing up $db in $TARGET/$db" >> /var/log/${backup_date}_mysql_dump.log

                for table in ${tables[@]}; do
                        mysqldump $db $table > $TARGET/$db/$table.sql
                        bzip2 $TARGET/$db/$table.sql
                done
        fi
done
echo "done"
