#!/bin/bash/
#ֻ�����ڵ�����������
#ʹ��ǰ����ϸ�Ķ�vasp�ֲ�https://www.vasp.at/wiki/index.php/Calculate_U_for_LSDA%2BU
#��U�����ڴ˽ű������ã�Ӧ��calc2_u.sh��calc3_u.sh����ͬ


#---------------------------------------------------------------------------------
#�ֶ�ָ������
#---------------------------------------------------------------------------------


#ָ����U�������ͣ�s,p,d��
l=2


#---------------------------------------------------------------------------------
#��������
#---------------------------------------------------------------------------------
#��������Ŀ¼�ֱ�����dft���㣬����Ǣ��Ӧ����Ǣ��Ӧ����
dir=(dft nsc sc)
for i in ${dir[*]}
do
#������ʱ�Ŵ������ļ���
if [ ! -d $i ]; then
    mkdir $i
fi
done


#��vasp��������ļ����Ƶ������ļ�����
echo ./dft/ ./nsc/ ./sc/ | xargs -n 1 cp -v ./{POSCAR,POTCAR,KPOINTS,vasp_mpi.sh,INCAR.DFT}


#�ж�dft_groundstate�Ƿ������ɣ���ɺ�ʼ�������㣬�����ύdft_groundstate����
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
    #dft����groundstate����������
    cp ./dft/OUTCAR  ./dft/OUTCAR.0
    cp ./dft/OSZICAR ./dft/OSZICAR.0
    cp ./dft/WAVECAR ./dft/WAVECAR.0
    cp ./dft/CHGCAR  ./dft/CHGCAR.0
    
    
    #DFT������ɺ���һϵ��LDAUU��LDAUJȡֵ�½��з���Ǣ��Ӧ�������Ǣ��Ӧ����

    list=$(seq -0.20 0.05 0.20) #���ֵ�ķ�Χ��ͬ����ȡ�Ĳ�ͬ����Ҫ������΢������ԽС����Խ׼ȷ������
    
    #����Ǣ��Ӧ����
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
      if [ ! -f $nsc_outcar ] || [ ! -f $nsc_chgcar ] || [ ! -f $nsc_wavecar ]; then
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
          rm -f $a/CHGCAR $a/WAVECAR
          cp ./dft/WAVECAR.0 $a/WAVECAR
          cp ./dft/CHGCAR.0  $a/CHGCAR
          echo "nsc job not finished yet"        
          cd $a/
          bsub < vasp_mpi.sh
          echo "nsc job resubmitted"
          cd ../../
        else
        #����Ǣ��Ӧ��ɺ��ύ��Ǣ��Ӧ����
          b=./sc/_$v
          if [ ! -d $b ]; then
            mkdir $b
            echo  $b | xargs -n 1 cp -v ./sc/{POSCAR,POTCAR,KPOINTS,vasp_mpi.sh,INCAR.DFT}
          fi
          sc_outcar=$b/OUTCAR
          sc_wavecar=$b/CHGCAR
          sc_chgcar=$b/WAVECAR
          cp $b/INCAR.DFT $b/INCAR
          cat >> $b/INCAR <<!
LDAU         = .TRUE.
LDAUTYPE     =  3
LDAUL        =  $l -1 -1
LDAUU        =  $v 0.00 0.00
LDAUJ        =  $v 0.00 0.00
LDAUPRINT    =  2
!
          if [ ! -f $sc_outcar ] || [ ! -f $sc_chgcar ] || [ ! -f $sc_wavecar ]; then

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