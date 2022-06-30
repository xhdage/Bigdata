#!/bin/bash
#hadoop distcp数据迁移

#检测是否有distcp任务正在运行
checkCommad=`yarn application -list | grep "distcp" | head -n 1 | awk '{print $2}'`

if [ -z "$checkCommad" ]; then
  echo "当前没有拷贝任务，开始执行distcp：$(date)"
  #执行启动distcp命令
  sudo -u hdfs hadoop distcp -i -p -skipcrccheck -async -filters pattern_2021-12.txt -log /ec-log/2021/12/ -m 20 -bandwidth 50 /raw/json /raw-with-ec/
  echo "启动完成!"
  exit
else
  echo "目前有正在执行的拷贝任务，不允许执行当前任务。"
  exit
fi
