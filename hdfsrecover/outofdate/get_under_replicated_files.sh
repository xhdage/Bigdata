#!/bin/bash
#get under replicated files

#检测文件路径
checkPath=/raw/json
#保存副本不足文件的块
filePath=/home/datalake/liyuan/hdfsrecover/under_replicated_files
#保存副本数不足文件历史记录的文件
filePathHistory=/home/datalake/liyuan/hdfsrecover/under_replicated_files_history
#检测文件副本数命令
jugeUnderReFile=`hdfs fsck $checkPath | grep 'Under replicated' | awk -F':' '{print $1}'`
#临时文件路径
tmpFilePath=/home/datalake/liyuan/hdfsrecover/tmpUnderReFile

#判断保存副本不足文件的块是否存在,否即立即执行检测，是则将以前的副本不足记录移至其他文件保存，然后执行检测
if [ ! -f "$filePath" ]; then
        echo "第一次开始检测"
        if [ -z "$jugeUnderReFile" ]; then
             echo "文件副本数充足"
             exit
        else
             echo "存在副本数不足！！！"
             echo $jugeUnderReFile > $tmpFilePath
             awk '{for(i=1;i<=NF;i++) print $i}' $tmpFilePath > $filePath
             echo "save under replicated file"
             echo $(date) >> $filePathHistory
             cat $filePath  >> $filePathHistory
             echo "save under replicated to history file"
             exit
        fi
else         
        echo "再次开始检测"
        if [ -z "$jugeUnderReFile" ]; then
             echo "文件副本数充足"
             exit
        else
             echo "存在副本数不足！！！"
             echo $jugeUnderReFile > $tmpFilePath
             awk '{for(i=1;i<=NF;i++) print $i}' $tmpFilePath > $filePath
             echo "save under replicated file"
             echo $(date) >> $filePathHistory
             cat  $filePath >> $filePathHistory
             echo "save under replicated to history file"       
        exit
        fi
fi
