#!/bin/bash
#删除/raw-with-ec/json/feed=*/*/2021-*/*.json下的指定文件

#日期
datetime=2021-10-*
#保存要删除文件的路径，比如2020-01，代表删除2020年1月份的数据。
dateFilePath1=/home/datalake/liyuan/raw-with-ec
dateFilePath2=rawrm_2021
dateFilePath3=rawrm_2021_10

feedPath=feed2_2021_10

dateFilePath=$dateFilePath1/$dateFilePath2/$dateFilePath3/${feedPath}.txt
#temp目录，临时目录
tempFile1=$dateFilePath1/$dateFilePath2/$dateFilePath3/temp2.txt
tempFile2=$dateFilePath1/$dateFilePath2/$dateFilePath3/temp2_1.txt
#删除日志
logPath=$dateFilePath1/$dateFilePath2/$dateFilePath3/${feedPath}_log.txt

#将/raw-with-ec/json/feed=*/*/2021-*/*.json所有的2020-01文件保存到temp.txt中
sudo -u hdfs hadoop fs -du -s -h /raw-with-ec/json/feed=*/*/$datetime/*.json >> $tempFile1
#截取/raw到具体年份
cut -d '/' -f 2,3,4,5,6 $tempFile1 >> $tempFile2
#行首添加字符串“/”
sed -i 's/^/\//g' $tempFile2
#更改/raw-with-ec为/raw/json
sed 's/raw-with-ec/raw/' $tempFile2 >> $dateFilePath

cat  ${dateFilePath}| while read rmFile
do
  sudo -u hdfs hadoop fs -rm -r -f -skipTrash $rmFile >> $logPath
done
