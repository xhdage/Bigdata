#!/bin/bash
# 判断flink job是否存在，不存在则重启

#检查日志记录路径
checkFlinkLogPath=/home/datalake/liyuan/flink_new/temp/checkFlinkNew.log

echo "========开始检测时间：$(date)========" >> $checkFlinkLogPath
echo -e "判断Flink job是否存在......" >> $checkFlinkLogPath
#检查命令
checkCommad=`yarn application -list | grep "RawDataLanding" | head -n 1 | awk '{print $2}'`
if [ -z "$checkCommad" ]; then
  echo "Flink job失败时间：$(date)" >> $checkFlinkLogPath
  echo "Flink job is bad" >> $checkFlinkLogPath
  echo "开始重启flink job...." >> $checkFlinkLogPath
  #执行启动flink启动脚本
  bash /home/datalake/liyuan/flink_new/flink_job_new_V4.sh
  echo "重启完成!" >> $checkFlinkLogPath
  exit 
else
  echo "Flink jon is ok" >> $checkFlinkLogPath
  exit
fi
