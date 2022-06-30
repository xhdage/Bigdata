#!/bin/bash

#export  HADOOP_USER_NAME=hdfs
export KAFKA_HEAP_OPTS="-Xmx8G -Xms1G"


# 找出最新的checkpoint

# namenode 地址
namenode=hdfs://master01-dl-nx:8020

# checkpoint目录
checkpointDir=/user/flink/raw-json/checkpoints_rdl

# 主类
mainCls=com.asiainfo_sec.datalake.rawdata.KafkaRawJsonSink

# jar包路径
jarPath=/home/datalake/script/flink/jar/datalake-flink-raw-jar-with-dependencies.jar

# kafka brokers
brokers=52.83.182.132:9094,69.235.153.101:9094,161.189.39.246:9094

# kafka consumer groupId
groupId=flink-raw

# kafka consumer topic
topics=stream00_.*

# json保存路径
dataPath=raw/json

# 检测日志记录位置 
checkFlinkLogPath=/home/datalake/liyuan/flink_new/temp/checkFlinkNew.log

# status
status=-1

read -n1 -t 5 -p "是否第一次运行，如果选择‘y’，将不会从chechpoint指定目录恢复状态.[y/n]等待5s,默认输入'n'" firstRun
firstRun=${firstRun:-n}

if [ "$firstRun" == "y" ];then
        echo "第一次运行脚本" >> $checkFlinkLogPath
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
-ynm RawDataLanding \
-yn 1 \
-yjm 2048m \
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

#记录日志
echo "非第一次运行，执行重启flink操作" >> $checkFlinkLogPath
echo -e "第一步:正在查找最新的checkpointDir......" >> $checkFlinkLogPath

#获得路径/user/flink/raw-json/checkpoints下的文件夹
lastDirs=`hdfs dfs -ls -t $checkpointDir | grep $checkpointDir | awk '{print $8}'`
#临时存放checkpointDir目录下的文件夹路径
lastCheckDirFile=/home/datalake/liyuan/flink_new/temp/lastCheckDirFile
tmpCheckDirFile=/home/datalake/liyuan/flink_new/temp/tmpCheckDirFile
#临时存放chk-xxxx文件路径
lastCheckpointFile=/home/datalake/liyuan/flink_new/temp/lastCheckpointFile
tmpCheckpointFile=/home/datalake/liyuan/flink_new/temp/tmpCheckpointFile
#每次执行前清空
echo -n "" > $lastCheckDirFile
echo -n "" > $tmpCheckDirFile

#开始存放文件路径
echo $lastDirs >> $tmpCheckDirFile
#以空格来分割，按行存储
awk '{for(i=1;i<=NF;i++) print $i}' $tmpCheckDirFile > $lastCheckDirFile
if [ ! -s "$lastCheckDirFile" ]; then
    echo "false, can not start because of no checkpoint file" >> $checkFlinkLogPath
    exit
fi

#依次取出checkpoints路径下的文件，用于判断是否符合启动的条件
cat  ${lastCheckDirFile}| while read lastCheckDir
do
    lastDir=$lastCheckDir
    #获得路径lastDir下的所有chk文件，并保存到文本中
    lastCheckpoints=`hdfs dfs -ls -t $lastDir | grep $lastDir"/chk" | awk '{print $8}'`

    echo -n "" > $tmpCheckpointFile
    echo -n "" > $lastCheckpointFile
    #是否功启动
    startStatus=0
    #存放chk-xxxx文件路径
    echo $lastCheckpoints >> $tmpCheckpointFile
    #以空格分隔并格式化为每行一条chk-xxxx文件路径
    awk '{for(i=1;i<=NF;i++) print $i}' $tmpCheckpointFile > $lastCheckpointFile
    if [ ! -s "$lastCheckpointFile" ]; then
        echo "false, can not find last chk-xxxx" >> $checkFlinkLogPath
        continue
    else 
        #找出最终要恢复的文件路径
        cat ${lastCheckpointFile}| while read lastCheckpoint
        do
            if [ -z "$lastCheckpoint" ]; then
                echo "false, can not find last checkpoint in lastCheckpointFile" >> $checkFlinkLogPath
                break
            else
                echo "lastCheckpoint路径:$lastCheckpoint" >> $checkFlinkLogPath
                echo -e "存在chk文件，开始判断chk文件是否合格(是否存在meta文件和meta文件不为空)! \n" >> $checkFlinkLogPath

                #判断最新checkpointDir中_metadata是否存在且不为空
                echo -e "第二步:正在判断checkpointDir中_metadata是否满足启动要求....." >> $checkFlinkLogPath
                metadata=`hdfs dfs -ls -t $lastCheckpoint | grep $lastCheckpoint"/_metadata" | head -n 1 | awk '{print $8}'`
    
                if [ -z "$metadata" ]; then
                   echo "Failed,the file does not exist" >> $checkFlinkLogPath
                   continue
                fi
    
                hadoop fs -test -s $metadata
                if [ $? -ne 0 ]; then
                   echo "Failed,the file is empty" >> $checkFlinkLogPath
                   continue
                else
                   echo "_metadata路径:$metadata" >> $checkFlinkLogPath
                   echo -e "success \n" >> $checkFlinkLogPath
                fi
    
                lastCkMeta=$metadata
                metaPath=`hadoop fs -ls $lastCkMeta`
                echo -e "last checkpoint file is:\n$metaPath \n" >> $checkFlinkLogPath
    
                #read -t 5 -p "是否将文件 '$namenode/$lastCkMeta'作为恢复文件.[y/n]等待5s,默认输入y." ackCheckDirInput
                echo "将会从文件$namenode/$lastCkMeta作为恢复文件！" >> $checkFlinkLogPath
                echo "执行脚本" >> $checkFlinkLogPath
                #export  HADOOP_USER_NAME=hdfs
                bash /home/datalake/liyuan/flink_new/startFlinkNew.sh $lastCkMeta
                echo "自动启动执行完成" >> $checkFlinkLogPath
                startStatus=1
                exit 
            fi
        done
    fi
    if [ $startStatus==1 ];then
        echo "退出" >> $checkFlinkLogPath
        break
    fi
done
#if [ $startStatus == 1 ];then
#    echo "已查找完所有checkpoints路径，无法找到满足条件的文件，自动启动执行失败" >>  $checkFlinkLogPath
#fi
