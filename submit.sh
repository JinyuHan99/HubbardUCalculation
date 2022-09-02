#!/bin/bash/
#运行此脚本三次，第一次提交dft计算，第二次提交nsc计算，第三次提交sc计算
cat >> log.txt <<!
submit history
!
time=`date`
echo $time >> log.txt
list="10 16" #指定提交计算的位点
site_dir=$(ls -l ./ |grep ^d | awk '{print $9}')


for site in $site_dir
do


for j in $list
do

echo $j
if [[ "$j" == "$site" ]]; then  
  cd ./$site
  sh calc_u.sh
  cd ../
  echo "site $site" >> log.txt
fi


done


done
