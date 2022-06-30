#!/bin/bash
#to fix under replicated files

#副本不足的文件名
underReplicateFilePath=/home/datalake/liyuan/hdfsrecover/under_replicated_files

#输出检测日期
echo "开始检测日期：$(date)" >> /home/datalake/liyuan/hdfsrecover/under_replicated_files_history

#分为三步
#第一步:检测是否存在副本不足的文件，存在则记录下这些文件
echo "第一步：查找副本不足文件" >> /home/datalake/liyuan/hdfsrecover/under_replicated_files_history
bash /home/datalake/liyuan/hdfsrecover/get_under_replicated_files_1.sh

#第二步:对记录下的副本不足的文件尝试进行修复，分为租约和手工修改理论副本数量为3
echo "第二步：尝试修复副本不足的文件" >> /home/datalake/liyuan/hdfsrecover/under_replicated_files_history
bash /home/datalake/liyuan/hdfsrecover/recover_under_replicated_files_2.sh $underReplicateFilePath

#第三步:第二步可能无法修复，为避免副本不足的块的丢失带来的文件损坏，需要拷贝文件至本地
echo "第三步：拷贝副本不足的文件至本地" >> /home/datalake/liyuan/hdfsrecover/under_replicated_files_history
bash /home/datalake/liyuan/hdfsrecover/copyTolocal_under_replicated_files_3.sh $underReplicateFilePath

echo "检测结束！" >> /home/datalake/liyuan/hdfsrecover/under_replicated_files_history
