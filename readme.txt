#ֻ�����ڵ�����������
#ʹ��ǰ����ϸ�Ķ�vasp�ֲ�https://www.vasp.at/wiki/index.php/Calculate_U_for_LSDA%2BU
#Important: One needs to keep increasing the size of the supercell for these calculations until the value of U stops changing.
#
#
#����ǰ׼�����ļ�ΪPOSCAR,KPOINTS,vasp_mpi.sh����submit.sh,start.sh,calc1_u.sh,calc2_u.sh,calc3_u.sh,data.sh,data.py�ű�����ͬһĿ¼��
#DFT�����INCAR��start.sh������,ע��MAGMOM����Ӧ���������ƥ�䣨˳���ԣ������Եȣ�
#POTCAR����������start.sh������
#
#
#-----��ʼ����---------------------------------------------------------------------
#����start.sh�������Ƽ����ļ�����Ŀ¼��
#��submit.sh��ָ��ԭ��λ�������submit.sh�ύ���㣬��log.txt�鿴���ύ��ԭ��λ�㣬ÿ��λ�������dft,nsc,sc���㣬��������log,txt���ظ������������ϣ���ʱ��Ҫ�ֶ�����Ƿ���ɼ���
#�����ύ��ҵ�����ƣ�ÿ������ύ5��ԭ��λ��(5*9=45����ҵ)�ļ���
#���м�����ɺ�����data.sh,�õ�u����ĶԽ�Ԫ��Ϊ����ȡ��Uֵ
#scʹ����dft��charge��wave�����޸�ʹ��nsc��
#

