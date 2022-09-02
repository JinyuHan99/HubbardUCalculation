#!/bin/bash/
#只适用于单金属氧化物
#使用前请详细阅读vasp手册https://www.vasp.at/wiki/index.php/Calculate_U_for_LSDA%2BU
#需提前准备的文件为POSCAR,KPOINTS,vasp_mpi.sh，与此脚本放在同一目录下
#DFT计算的INCAR在此脚本中设置
#POTCAR赝势类型在此脚本中设置
#MAGMOM设置应与材料性质匹配（顺磁性，抗磁性等）
#运行此脚本将复制计算文件到各目录下
#Important: One needs to keep increasing the size of the supercell for these calculations until the value of U stops changing.




#检查赝势总目录
pseu=/share/home/zxchen/source/POTENTIALS/potpaw_PBE.54/
#指定赝势类型(填后缀sv,pv,d等，若无后缀则输入0)
tpseu=0

#---------------------------------------------------------------------------------
#运行内容
#---------------------------------------------------------------------------------

#指定金属种类和超胞中的金属原子数目
tmet=`sed -n '6,6p' ./POSCAR | awk 'END{print $1}'`
nmet=`sed -n '7,7p' ./POSCAR | awk 'END{print $1}'`
#指定氧原子数目
noxy=`sed -n '7,7p' ./POSCAR | awk 'END{print $2}'`

#构建DFT计算的INCAR，<<表示输入定向，！表示换行
cat > INCAR.DFT <<!
SYSTEM       = NiO AFM 
PREC         = A
EDIFF        = 1E-6
#AMIX         = 0.2
#BMIX         = 0.000001
#AMIX_MAG     = 0.2
#BMIX_MAG     = 0.000001
#NELM         = 150
ISMEAR       = 0
SIGMA        = 0.2
ISPIN        = 2
MAGMOM       = 2.0 -1.0  1.0 -1.0  1.0 \\
              -1.0  1.0 -1.0  1.0 -1.0 \\
               1.0 -1.0  1.0 -1.0  1.0 \\
              -1.0  1.0 -1.0  1.0 -1.0 \\
            16*0.0
LORBIT       = 11
LMAXMIX      = 4 # for d-electrons, set to 6 when you're dealing with f-electrons
!


#判断赝势后缀
if [ $tpseu == 0 ];then
  tmet_pseu=$tmet
else
  tmet_pseu=${tmet}_${tpseu}
fi
#echo $tmet_pseu

#根据金属原子数目创建文件夹并处理POSCAR,POTCAR,KPOINTS
for i in $(seq 1 $nmet)
do

  if [ ! -d $i ]; then
      mkdir "$i"
  fi
  
  nmet_i=`echo "$nmet-$i" | bc`
  ii=`echo "$i-1" | bc`
  
  cp ./POSCAR ./$i/
  cp ./KPOINTS ./$i/
  cp ./vasp_mpi.sh ./$i/  
  cp ./INCAR.DFT ./$i/
  
  if [ $i = 1 ];then
        sed -i '6c   '$tmet' '$tmet' O' ./$i/POSCAR
        sed -i '7c   1 '$nmet_i' '$noxy'' ./$i/POSCAR
        #cat ./$i/POSCAR
        cat $pseu/$tmet_pseu/POTCAR $pseu/$tmet_pseu/POTCAR $pseu/O/POTCAR > ./$i/POTCAR
        cp ./calc1_u.sh ./$i/calc_u.sh
        #grep 'TITEL' ./$i/POTCAR
  fi
  
  if [ $i = $nmet ];then
        sed -i '6c   '$tmet' '$tmet' O' ./$i/POSCAR
        sed -i '7c   '$ii' 1 '$noxy'' ./$i/POSCAR
        #cat ./$i/POSCAR
        cat $pseu/$tmet_pseu/POTCAR $pseu/$tmet_pseu/POTCAR $pseu/O/POTCAR > ./$i/POTCAR
        cp ./calc3_u.sh ./$i/calc_u.sh
        #grep 'TITEL' ./$i/POTCAR
  fi
      
  if [ $i != 1 ] && [ $i != $nmet ];then
        sed -i '6c   '$tmet' '$tmet' '$tmet' O' ./$i/POSCAR
        sed -i '7c   '$ii' 1 '$nmet_i' '$noxy'' ./$i/POSCAR
        #cat ./$i/POSCAR  
        cat $pseu/$tmet_pseu/POTCAR $pseu/$tmet_pseu/POTCAR $pseu/$tmet_pseu/POTCAR  $pseu/O/POTCAR > ./$i/POTCAR
        cp ./calc2_u.sh ./$i/calc_u.sh
        #grep 'TITEL' ./$i/POTCAR  
  fi  
done


