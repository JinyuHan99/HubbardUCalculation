#!/bin/bash/
#���д˽ű����Σ���һ���ύdft���㣬�ڶ����ύnsc���㣬�������ύsc����
cat >> log.txt <<!
submit history
!
time=`date`
echo $time >> log.txt
list="10 16" #ָ���ύ�����λ��
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
