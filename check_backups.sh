#!/bin/bash
# script to backup MySQL databases;
# check log in /var/log/${backup_date}mysql_dump.log

TARGET="/var/dump_sql/$(cat /var/dump_sql/.lastest_dir)"
DBs="$(mysql -Bse 'show databases')"

for db in ${DBs[@]}; do
	tables=$(mysql $db -Bse 'show tables')
	# check if it is not a system database
	if [[ $db != "lost+found" && $db != "mysql" && $db != "performance_schema" && $db != "information_schema" ]]; then
		if [[ ! -d "$TARGET/$db" ]]; then
			echo "failed"
		else
			for table in ${tables[@]}; do
				if [[ ! -f "$TARGET/$db/$table.sql.bz2" ]]; then
					echo "failed for $TARGET/$db/$table.sql.bz2"
				fi
			done
		fi
	fi
done
