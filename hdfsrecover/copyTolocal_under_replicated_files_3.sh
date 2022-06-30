#!/bin/bash
# copy the under relicated file from hdfs

#传入参数即要拷贝的副本数不足的文件名
under_replicated_file_name=$1
#从hdfs拷贝出的文件名的位置
dirFilePath=/home/datalake/liyuan/hdfsrecover/underReFileStore

if [ -z "${under_replicated_file_name}" ];then
    echo "Pls input file path"
    exit 
fi

echo "开始拷贝"
cat ${under_replicated_file_name}| while read sourceFilePath
do
  if [ -z $sourceFilePath ]; then
    continue
  fi
  #从hdfs拷贝至本地
  hadoop fs -copyToLocal $sourceFilePath $dirFilePath
done
echo "拷贝结束！！！"
