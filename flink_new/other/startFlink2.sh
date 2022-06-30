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

#log
checkFlinkLogPath=/home/datalake/liyuan/flink/checkFlink.log

lastCkMeta=$1

echo "执行脚本！"
#export  HADOOP_USER_NAME=hdfs
echo $lastCkMeta >> $checkFlinkLogPath
