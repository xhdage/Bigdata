#!/bin/bash
#删除/raw/json/下的数据

cpDirFile=/home/datalake/liyuan/raw-with-ec/rawrm/feed_3.txt

cat  ${cpDirFile}| while read rmFile
do
  sudo -u hdfs hadoop fs -rm -r -f -skipTrash $rmFile >> rm_feed_3_log.txt
done
