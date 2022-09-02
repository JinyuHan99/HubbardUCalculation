#!/bin/bash/

#只适用于单金属氧化物
#使用前请详细阅读vasp手册https://www.vasp.at/wiki/index.php/Calculate_U_for_LSDA%2BU
#需提前准备的文件为POSCAR,POTCAR,KPOINTS,vasp_mpi.sh，与此脚本放在同一目录下
#POSCAR需扩胞并将site 1原子单独处理，POTCAR与之一致
#如：
#  Ni Ni O
#  1 15 16
#INCAR在此脚本中设置
#MAGMOM设置应与材料性质匹配（顺磁性，抗磁性等）
#运行3次，第一次提交dft_groundstate计算，待dft完成后第二次运行提交非自洽响应，待非自洽响应完成后第三次运行提交自洽响应计算
#Important: One needs to keep increasing the size of the supercell for these calculations until the value of U stops changing.

#---------------------------------------------------------------------------------
#运行内容
#---------------------------------------------------------------------------------

#指定加U电子类型（s,p,d）
l=2

#创建三个目录分别用于dft计算，非自洽响应，自洽响应计算
PATH=$PATH:.  #将当前目录放入PATH
dir=(dft nsc sc)
for i in ${dir[*]}
do
#不存在时创建该文件夹
if [ ! -d $i ]; then
    mkdir $i
fi
done


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


#将vasp计算相关文件复制到三个文件夹下
echo ./dft/ ./nsc/ ./sc/ | xargs -n 1 cp -v ./{POSCAR,POTCAR,KPOINTS,vasp_mpi.sh,INCAR.DFT}


#判断dft_groundstate是否计算完成，完成后开始后续计算，否则提交dft_groundstate计算
dft_outcar=./dft/OUTCAR
dft_chgcar=./dft/CHGCAR
dft_wavecar=./dft/WAVECAR
if [ ! -f $dft_outcar ] || [ ! -f $dft_chgcar ] || [ ! -f $dft_wavecar ]; then
  cp ./dft/INCAR.DFT ./dft/INCAR
  rm -f ./dft/CHGCAR ./dft/WAVECAR
  cd ./dft
  echo "dft file missing or not submitted yet"
  bsub < vasp_mpi.sh
  echo "dft job submitted"
  cd ../
else
  if [ `grep -c "General timing and accounting informations for this job" ./dft/OUTCAR ` -ne '1' ];then
    cp ./dft/INCAR.DFT ./dft/INCAR
    rm -f ./dft/CHGCAR ./dft/WAVECAR
    cd ./dft
    echo "dft job not finished"
    bsub < vasp_mpi.sh
  echo "dft job resubmitted"
    cd ../
  else
    #dft——groundstate计算结果保存
    cp ./dft/OUTCAR  ./dft/OUTCAR.0
    cp ./dft/OSZICAR ./dft/OSZICAR.0
    cp ./dft/WAVECAR ./dft/WAVECAR.0
    cp ./dft/CHGCAR  ./dft/CHGCAR.0
    
    
    #DFT计算完成后在一系列LDAUU和LDAUJ取值下进行非自洽响应计算和自洽响应计算

    list=$(seq -0.20 0.05 0.20) #这个值的范围不同的人取的不同，主要是用作微扰项，因此越小可能越准确？？？
    
    #非自洽响应计算
    for v in ${list[*]}
    do
      a=./nsc/_$v
      if [ ! -d $a ]; then
        mkdir $a
        echo  $a | xargs -n 1 cp -v ./nsc/{POSCAR,POTCAR,KPOINTS,vasp_mpi.sh,INCAR.DFT}
      fi
      nsc_outcar=$a/OUTCAR
      nsc_wavecar=$a/CHGCAR
      nsc_chgcar=$a/WAVECAR
      if [ ! -f $nsc_outcar ] || [ ! -f $nsc_chgcar ] || [ ! -f $nsc_wavecar ]; then
        cp $a/INCAR.DFT $a/INCAR
        cat >> $a/INCAR <<!
ICHARG       = 11
LDAU         = .TRUE.
LDAUTYPE     =  3  #The "LDAUTYPE = 1 and 2" are able to do LSAD+U (spin polarized) but "LDAUTYPE = 4" can just do LDA+U; LDAUTYPE = 3 is a hidden feature of vasp.5
LDAUL        =  $l -1 -1
LDAUU        =  $v 0.00 0.00 #for LDAUTYPE=3, LDAUU and LDAUJ denote the shifts acting on the up and down electrons, respectively
LDAUJ        =  $v 0.00 0.00 #LDAUU and LDAUJ should be identical
LDAUPRINT    =  2
!
        rm -f $a/CHGCAR $a/WAVECAR
        cp ./dft/WAVECAR.0 $a/WAVECAR
        cp ./dft/CHGCAR.0  $a/CHGCAR
        echo "nsc file missing or not submitted yet"        
        cd $a/
        bsub < vasp_mpi.sh
        echo "non_selfconsistent job submitted"
        cd ../../
      else
        if [ `grep -c "General timing and accounting informations for this job" $a/OUTCAR ` -ne '1' ];then
          cp $a/INCAR.DFT $a/INCAR
          cat >> $a/INCAR <<!
ICHARG       = 11
LDAU         = .TRUE.
LDAUTYPE     =  3
LDAUL        =  $l -1 -1
LDAUU        =  $v 0.00 0.00
LDAUJ        =  $v 0.00 0.00
LDAUPRINT    =  2
!
          rm -f $a/CHGCAR $a/WAVECAR
          cp ./dft/WAVECAR.0 $a/WAVECAR
          cp ./dft/CHGCAR.0  $a/CHGCAR
          echo "nsc job not finished yet"        
          cd $a/
          bsub < vasp_mpi.sh
          echo "nsc job resubmitted"
          cd ../../
        else
        #非自洽响应完成后提交自洽响应计算
          b=./sc/_$v
          if [ ! -d $b ]; then
            mkdir $b
            echo  $b | xargs -n 1 cp -v ./sc/{POSCAR,POTCAR,KPOINTS,vasp_mpi.sh,INCAR.DFT}
          fi
          sc_outcar=$b/OUTCAR
          sc_wavecar=$b/CHGCAR
          sc_chgcar=$b/WAVECAR
          if [ ! -f $sc_outcar ] || [ ! -f $sc_chgcar ] || [ ! -f $sc_wavecar ]; then
            cp $b/INCAR.DFT $b/INCAR
            cat >> $b/INCAR <<!
LDAU         = .TRUE.
LDAUTYPE     =  3
LDAUL        =  $l -1 -1
LDAUU        =  $v 0.00 0.00
LDAUJ        =  $v 0.00 0.00
LDAUPRINT    =  2
!
            rm -f $b/CHGCAR $b/WAVECAR
            cp ./dft/WAVECAR.0 $b/WAVECAR
            cp ./dft/CHGCAR.0  $b/CHGCAR
            echo "sc file missing or not submitted yet"    
            cd $b/
            bsub < vasp_mpi.sh
            echo "sc job submitted"
            cd ../../
          else
            if [ `grep -c "General timing and accounting informations for this job" $b/OUTCAR ` -ne '1' ];then
              cp $b/INCAR.DFT $b/INCAR
              cat >> $b/INCAR <<!
LDAU         = .TRUE.
LDAUTYPE     =  3
LDAUL        =  $l -1 -1
LDAUU        =  $v 0.00 0.00
LDAUJ        =  $v 0.00 0.00
LDAUPRINT    =  2
!
              rm -f $b/CHGCAR $b/WAVECAR
              cp ./dft/WAVECAR.0 $b/WAVECAR
              cp ./dft/CHGCAR.0  $b/CHGCAR
              echo "sc job not finished yet"    
              cd $b/
              bsub < vasp_mpi.sh
              echo "sc job resubmitted"
              cd ../../              
            fi            
          fi                  
        fi        
      fi   
    done
  fi
fi