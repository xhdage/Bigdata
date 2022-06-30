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

lastCkMeta=$1

echo "执行脚本！"
export  HADOOP_USER_NAME=hdfs

/opt/cloudera/parcels/FLINK/bin/flink run \
-m yarn-cluster \
-ynm RawDataLanding \
-s $namenode/$lastCkMeta \
-yn 1 \
-yjm 2048m \
-ytm 8192m \
-yD taskmanager.memory.off-heap=false \
-yD taskmanager.memory.preallocate=false \
-c $mainCls -d \
$jarPath \
--bootstrap-server $brokers \
--groupId $groupId \
--topic-pattern $topics --base-path $namenode/$dataPath \
--env-parallelism 1 \
--checkpoints-dir $namenode/$checkpointDir
