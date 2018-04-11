#!/bin/bash

# mysql-dump-table.sh

# Description: Dump MySQL table into separate SQL files(zipped).
# Usage: Just config and run
# Author: @hackhq
# Ref : https://gist.github.com/alejandroSuch/6fd49fc09a7a8a5bd8910f0b8ce5b6d4

# SETTING 
MAX_FILES=30
DB_host="localhost"
DB_name="database_name"
DB_user="database_username"
DB_pass="database_password"
BACKUP_DIR="backup_dir"


# COLOR
# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White


[ -n "$BACKUP_DIR" ] || BACKUP_DIR=.
test -d $BACKUP_DIR || mkdir -p $BACKUP_DIR

cd ${BACKUP_DIR}

total_files=$(ls -d */ | wc -l)

# MAKE SUB BACKUP DIR BY DATETIME
current_date=$(date +%Y-%m-%d_%H-%M-%S)
backup_dir=${current_date}

[ -n "$backup_dir" ] || backup_dir=.
test -d $backup_dir || mkdir -p $backup_dir

cd ${backup_dir}

STARTTIME=$(date +%s)

clear
echo "==============================================================="
echo -e "Total Backup Directory: "${Purple}$total_files"/"$MAX_FILES${Color_Off}
echo "==============================================================="
echo "Backing up..."


echo -e "Dumping tables from "${Purple}$DB_name${Color_Off}" to "${Purple}"$BACKUP_DIR/$backup_dir"${Color_Off}
echo "==============================================================="

# CHECK PIGZ IS EXIST
if [ -x	/usr/bin/pigz ]; then
	echo -e ${Cyan}"[Use Pigz]"${Color_Off}
	ZIP_COMMAND=pigz
else
	echo -e ${Yellow}"I recommend to use PIGZ to do compression because it support multi-core processing"${Color_Off}
	echo -e ${Yellow}"To install, run this command: "${White}"yum install pigz -y"${Color_Off}
	echo
	echo -e ${Cyan}"[Use Gzip]"${Color_Off}
	ZIP_COMMAND=gzip
fi

tbl_count=0

for t in $(mysql -NBA -h $DB_host -u $DB_user -p$DB_pass -D $DB_name -e 'show tables') 
do 
    echo -e "DUMPING TABLE: "${Green}$DB_name.$t${Color_Off}
    mysqldump -h $DB_host -u $DB_user -p$DB_pass $DB_name $t | ${ZIP_COMMAND} > $DB_name.$t.sql.gz
    tbl_count=$(( tbl_count + 1 ))
done

ENDTIME=$(date +%s)

echo 
echo -e "Done! Takes "${Green}"$(($ENDTIME - $STARTTIME))"${Color_Off}" seconds to complete."
echo "==============================================================="
echo -e "+ Backup Directory: "${Green}$backup_dir${Color_Off}
echo -e ${Green}$tbl_count${Color_Off}" tables dumped from database "${Green}$DB_name${Color_Off}
echo "==============================================================="

cd ..

# DELETE OLD BACKUP FILES
i=1
for f in $(ls -td */); do
	if [ $i -gt $MAX_FILES ]; then
		rm -rf $f
		echo -e "- Deleted Backup Directory: "${Red}$f${Color_Off}
	fi
	i=$[$i+1]
done

echo "==============================================================="

