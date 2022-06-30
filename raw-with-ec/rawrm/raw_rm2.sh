#!/bin/bash
#删除/raw/json/下的数据

cpDirFile=/home/datalake/liyuan/raw-with-ec/rawrm/feed_2.txt

cat  ${cpDirFile}| while read rmFile
do
  sudo -u hdfs hadoop fs -rm -r -f -skipTrash $rmFile >> rm_feed_2_log.txt
done
