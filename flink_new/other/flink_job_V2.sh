#!/bin/bash

#export  HADOOP_USER_NAME=hdfs
export KAFKA_HEAP_OPTS="-Xmx8G -Xms1G"


# 找出最新的checkpoint

# namenode 地址
namenode=hdfs://master01-dl-nx:8020

# checkpoint目录
checkpointDir=/user/flink/raw-json/checkpoints

# 主类
mainCls=com.asiainfo_sec.datalake.rawdata.KafkaRawJsonSink

# jar包路径
jarPath=/home/datalake/script/flink/jar/datalake-flink-raw-jar-with-dependencies.jar

# kafka brokers
brokers=52.83.52.195:9093,69.230.229.33:9093,69.234.214.237:9093

# kafka consumer groupId
groupId=flink-raw

# kafka consumer topic
topics=stream00_.*

# json保存路径
dataPath=raw/json

# status
status=-1

read -p "是否第一次运行，如果选择‘y’，将不会从chechpoint指定目录恢复状态.[y/n]" firstRun

if [ "$firstRun" == "y" ];then
	read -p "namenode is $namenode.[y/n]" ackNamenode
	if [[ "$ackNamenode" != "y" ]];then
		echo "请修改namenode."
		exit
	fi

	read -p "checkpointDir is $checkpointDir.[y/n]" ackCheckpointDir
	if [[ "$ackCheckpointDir" != "y" ]];then
		echo "请修改checkpointDir."
		exit
	fi
	status=1
elif [ "$firstRun" == "" ] || [ "$firstRun" != "n" ];then
	echo "输入信息错误,退出"
	exit
fi


if [ $status == 1 ];then

echo -e "开始执行提交命令。\n"

/opt/cloudera/parcels/FLINK/bin/flink run \
-m yarn-cluster \
-yn 1 \
-yjm 1024m \
-ytm 8192m \
-yD taskmanager.memory.off-heap=true \
-yD taskmanager.memory.preallocate=true \
-c $mainCls -d \
$jarPath \
--bootstrap-server $brokers \
--groupId $groupId \
--topic-pattern $topics --base-path $namenode/$dataPath \
--env-parallelism 1 \
--checkpoints-dir $namenode/$checkpointDir

echo "submitted"
exit

fi

echo -e "第一步:正在查找最新的checkpointDir......"
#获得路径/user/flink/raw-json/checkpoints下最新的文件夹
#lastDir=`hdfs dfs -ls -t $checkpointDir | grep $checkpointDir | head -n 1 | awk '{print $8}'`
lastDir=/user/flink/raw-json/checkpoints/dbbaf0a04828f6fdcf4959abaa38587b
#获得路径lastDir下的所有chk文件，并保存到文本中
lastCheckpoints=`hdfs dfs -ls -t $lastDir | grep $lastDir"/chk" | awk '{print $8}'`

lastCheckpointFile=/home/datalake/liyuan/flink/lastCheckpointFile
tmpCheckpointFile=/home/datalake/liyuan/flink/tmpCheckpointFile
echo -n "" > $tmpCheckpointFile
echo $lastCheckpoints >> $tmpCheckpointFile
echo -n "" > $lastCheckpointFile
awk '{for(i=1;i<=NF;i++) print $i}' $tmpCheckpointFile > $lastCheckpointFile
#echo $lastCheckpoints >> $lastCheckpointFile

#lastCheckpoint=`hdfs dfs -ls -t $lastDir | grep $lastDir"/chk" | head -n 1 | awk '{print $8}'`

#最终要恢复的文件路径
lastCkMeta=""
#找出最终要恢复的文件路径
cat ${lastCheckpointFile}| while read lastCheckpoint
do
    if [ -z "$lastCheckpoint" ]; then
	echo "false, can not find last checkpoint"
	exit
    else 
        echo "lastCheckpoint路径:$lastCheckpoint"
	echo -e "存在chk文件，开始判断chk文件是否合格(是否存在meta文件和meta文件不为空)! \n"
        
        #判断最新checkpointDir中_metadata是否存在且不为空
        echo -e "第二步:正在判断checkpointDir中_metadata是否满足启动要求....."
        metadata=`hdfs dfs -ls -t $lastCheckpoint | grep $lastCheckpoint"/_metadata" | head -n 1 | awk '{print $8}'`

        if [ -z "$metadata" ]; then
           echo "Failed,the file does not exist"
           continue
        fi

        hadoop fs -test -s $metadata
        if [ $? -ne 0 ]; then
           echo "Failed,the file is empty"
           continue
        else
           echo "_metadata路径:$metadata" 
           echo -e "success \n"
        fi

        lastCkMeta=$metadata

        metaPath=`hadoop fs -ls $lastCkMeta`
        echo -e "last checkpoint file is:\n$metaPath \n"

        #read -t 5 -p "是否将文件 '$namenode/$lastCkMeta'作为恢复文件.[y/n]等待5s,默认输入y." ackCheckDirInput      
        echo "将会从文件$namenode/$lastCkMeta作为恢复文件！"
        #if [[ "$ackCheckDirInput" != "y" ]];then
	#   echo "选择不从checkpointDir恢复，请修改执行方式，结束！和$ackCheckDirInput"
	#   exit
        #fi

        #read -n1 -t 5 -p "再次确认.[y/n]等待5s,默认输入y." againInput
        
        againInpuy=${againInput:-y}

        #if [[ "$againInput" != "y" ]];then
	#   echo "选择不从checkpointDir恢复，请修改执行方式，结束！"
	#   exit
        #fi
        echo "执行脚本"
        
        break
    fi
done 
