#! /bin/bash
DA=`date "+%Y/%m"`
DAT=`date "+%Y-%m-%d"`
CURRENT=/home/bonsai/backups
BASE=/home/bonsai/bonsaierp
# Logs
mkdir -p $CURRENT/logs/$DA

bzip2 -zk $BASE/log/production.log

mv $BASE/log/production.log.bz2 $CURRENT/logs/$DA/$DAT-log.bz2
echo "" > $BASE/log/production.log

# Data
mkdir -p $CURRENT/data/$DA
export PGPASSWORD=''

pg_dump bonsai_prod -U bonsai_data -h localhost|bzip2 > $CURRENT/data/$DA/$DAT-bonsai.bz2
export PGPASSWORD=""
echo | mutt boris@bonsaierp.com -s "Backup del $DAT" -a $CURRENT/data/$DA/$DAT-bonsai.bz2
rm /home/bonsai/sent
