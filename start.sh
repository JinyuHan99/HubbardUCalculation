#!/bin/bash/
#ֻ�����ڵ�����������
#ʹ��ǰ����ϸ�Ķ�vasp�ֲ�https://www.vasp.at/wiki/index.php/Calculate_U_for_LSDA%2BU
#����ǰ׼�����ļ�ΪPOSCAR,KPOINTS,vasp_mpi.sh����˽ű�����ͬһĿ¼��
#DFT�����INCAR�ڴ˽ű�������
#POTCAR���������ڴ˽ű�������
#MAGMOM����Ӧ���������ƥ�䣨˳���ԣ������Եȣ�
#���д˽ű������Ƽ����ļ�����Ŀ¼��
#Important: One needs to keep increasing the size of the supercell for these calculations until the value of U stops changing.




#���������Ŀ¼
pseu=/share/home/zxchen/source/POTENTIALS/potpaw_PBE.54/
#ָ����������(���׺sv,pv,d�ȣ����޺�׺������0)
tpseu=0

#---------------------------------------------------------------------------------
#��������
#---------------------------------------------------------------------------------

#ָ����������ͳ����еĽ���ԭ����Ŀ
tmet=`sed -n '6,6p' ./POSCAR | awk 'END{print $1}'`
nmet=`sed -n '7,7p' ./POSCAR | awk 'END{print $1}'`
#ָ����ԭ����Ŀ
noxy=`sed -n '7,7p' ./POSCAR | awk 'END{print $2}'`

#����DFT�����INCAR��<<��ʾ���붨�򣬣���ʾ����
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


#�ж����ƺ�׺
if [ $tpseu == 0 ];then
  tmet_pseu=$tmet
else
  tmet_pseu=${tmet}_${tpseu}
fi
#echo $tmet_pseu

#���ݽ���ԭ����Ŀ�����ļ��в�����POSCAR,POTCAR,KPOINTS
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


