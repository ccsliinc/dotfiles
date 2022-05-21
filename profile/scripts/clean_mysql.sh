#!/usr/bin/env bash 
MYSQL_USER=admin
MYSQL_PASS=`cat /etc/psa/.psa.shadow`
MYSQL_SERVICE=mariadb
MYSQL=$(which mysql)
if [ $? == 1 ]; then
  echo "MySQL is not installed."
  exit 1
fi
MYSQL_DUMP=$(which mysqldump)
if [ $? == 1 ]; then
  echo "Unable to execute mysqldump."
  exit 1
fi
if test $1; then
  if [[ "$1" != "-k" ]]; then
    echo "Invalid switch $1."
    echo "Usage: $0 [-k]"
    echo "Use the -k switch to keep backups instead of restoring the databases"
    exit 1
  fi
fi
MYSQLD=$(pidof mysqld)
if [ -z "$MYSQLD" ]; then
  sudo service $MYSQL_SERVICE start
fi
if ! $MYSQL -u$MYSQL_USER -p$MYSQL_PASS  -e ';' 2> /dev/null; then
  read -sp "Enter the MySQL $MYSQL_USER password: " MYSQL_PASS
  if ! $MYSQL -u$MYSQL_USER -p$MYSQL_PASS  -e ';' 2> /dev/null; then
    echo "Invalid password."
    exit 1
  fi
fi
DBS="$($MYSQL -u$MYSQL_USER -p$MYSQL_PASS -e 'show databases' | awk '{print $1}' | grep -v '^Database')"
SAVE_DBS="information_schema mysql performance_schema"
SIZE_BEFORE=$(du /var/lib/mysql/ibdata1 | cut -d$'\t' -f1)
echo "Size Before : $SIZE_BEFORE"
for DB in $DBS; do
  DROP=1
  for SAVE_DB in $SAVE_DBS; do
    if [ $SAVE_DB == $DB ]; then
      DROP=0
      break
    fi
  done
  if [ $DROP == 1 ]; then
    echo "Dumping $DB database..."
    $MYSQL_DUMP -u$MYSQL_USER -p$MYSQL_PASS $DB | gzip > $DB.sql.gz
    if [ -f $DB.sql.gz ]; then
      echo "Database $DB backed up successfully."
      echo "Dropping $DB database..."
      $MYSQL -u$MYSQL_USER -p$MYSQL_PASS -e "drop database \`$DB\`"
    else
      echo "Backup of database $DB failed."
      exit 1
    fi
  fi
done
sudo service $MYSQL_SERVICE stop
sudo rm -f /var/lib/mysql/ib*
sudo service $MYSQL_SERVICE start
if ! test $1; then
  if [[ "$DBS" != "$SAVE_DBS" ]]; then
    for DB in $DBS; do
      if [ -f $DB.sql.gz ]; then
        echo "Restoring database $DB..."
        gunzip $DB.sql.gz
        $MYSQL -u$MYSQL_USER -p$MYSQL_PASS -e "create database if not exists \`$DB\`"
        $MYSQL -u$MYSQL_USER -p$MYSQL_PASS $DB < $DB.sql
        if [ $? == 0 ]; then
          echo "Database $DB restored successfully."
          rm -f $DB.sql
        else
          echo "Restore of database $DB failed."
        fi
      fi
    done
  fi
fi
SIZE_AFTER=$(du /var/lib/mysql/ibdata1 | cut -d$'\t' -f1)
SIZE_SAVED=$(($SIZE_BEFORE-$SIZE_AFTER))
echo "Shrunk /var/lib/mysql/ibdata1 and recovered $SIZE_SAVED kilobytes."

#for f in ./*.sql.gz; do
#   FILENAME=${f##*/}
#   DB=${FILENAME::-7}
#
#   gunzip $DB.sql.gz
#   mysql -uadmin -p`cat /etc/psa/.psa.shadow` -e "create database if not exists \`$DB\`"
#   mysql -uadmin -p`cat /etc/psa/.psa.shadow` $DB < $DB.sql
#   mv $DB.sql completed/$DB.sql
#
#   # do some stuff here with "$f"
#   # remember to quote it or spaces may misbehave
#done