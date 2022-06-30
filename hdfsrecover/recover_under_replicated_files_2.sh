#!/bin/bash
# recover under replicated files.you need to pass in a parameter,the file name to be repaired

#传入参数即要恢复的副本数不足的文件名
under_replicated_file_name=$1
filePath=$2
if [ -z "${under_replicated_file_name}" ];then
    echo "Pls input file path"
    exit 1
fi

cat ${under_replicated_file_name}| while read line
do
  if [ -z $line ]; then
    continue
  fi
  #回收文件租约
  hdfs debug recoverLease -path $line -retries 10
  #手动设置每个文件副本数为3
  sudo -u hdfs hdfs dfs -setrep 3 $line
done
