#!/bin/bash
#统计2022年1，2,3月的raw zone数据大小

sumDirFile=/home/datalake/liyuan/tongji/rj.txt

#cat ${cpDirFile}| while read sumDirFile
sum_B=0
sum_K=0
sum_M=0

while read sumFile
do
  #echo $sumFile
  temp=`echo $sumFile | awk '{print $2}'`
  #当单位为Byte
  if [ $temp != "K" ] && [ $temp != "M" ]; then
     temp_B=`echo $sumFile | awk  '{print $1}'`
     #sum_B=`expr $sum_B + $temp_B`
      sum_B=`echo "$sum_B + $temp_B"|bc`
  fi

  #当单位为KB
  if [ $temp == "K" ];then
     temp_K=`echo $sumFile | awk  '{print $1}'`
     #sum_K=`expr $sum_K + $temp_K`
      sum_K=`echo "$sum_K + $temp_K"|bc`
  fi

  #当单位为M
  if [ $temp == "M" ];then
     temp_M=`echo $sumFile | awk  '{print $1}'`
     #sum_M=`expr $sum_M + $temp_M`
     sum_M=`echo "$sum_M + $temp_M"|bc`
  fi
done < $sumDirFile

#sum_B=`echo "scale=2; $sum_B / 1232896"|bc`
#sum_K=`echo "scale=2; $sum_K / 1024"|bc`

echo "byte=$sum_B" >> r1.txt
echo "kb=$sum_K" >> r1.txt
echo "mb=$sum_M" >> r1.txt

exit
