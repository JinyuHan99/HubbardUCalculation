#!/bin/bash
#此脚本用于整理输出u计算的数据
#需注意ladul的值，确定是d还是f电子加了u，应更改相应的打印列数


#从POSCAR中读取金属原子总数
nmet=`sed -n '7,7p' ./POSCAR | awk 'END{print $1}'`

echo -n "v", > data_nsc.csv
echo -n "v", > data_sc.csv

for i in $(seq 1 1 $nmet)
do
for j in $(seq 1 1 $nmet)
do
echo -n "nsc$i-$j", >> data_nsc.csv
echo -n "sc$i-$j", >> data_sc.csv
done
done

echo "" >> data_nsc.csv
echo "" >> data_sc.csv


v_list=$(ls -l 1/nsc/ |grep ^d | awk '{print $9}')


for v in $v_list
do
echo $v
v_val=`echo $v | sed 's/_//g'`

echo -n "$v_val", >> data_nsc.csv
echo -n "$v_val", >> data_sc.csv

for i in $(seq 1 1 $nmet)
do
#echo $i
for j in $(seq 1 1 $nmet)
do
#echo $j
  row=`echo "$j+3" | bc`
  nsc_ij=`grep 'total charge' -A $row $i/nsc/$v/OUTCAR | tail -1 | awk 'END{print $4}'`
  sc_ij=`grep 'total charge' -A $row $i/sc/$v/OUTCAR | tail -1 | awk 'END{print $4}'` 
  echo -n "$nsc_ij", >> data_nsc.csv
  echo -n "$sc_ij", >> data_sc.csv  
done
done
echo "" >> data_nsc.csv
echo "" >> data_sc.csv
done


cat data_nsc.csv
cat data_sc.csv

python data.py

