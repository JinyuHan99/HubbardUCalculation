#只适用于单金属氧化物
#使用前请详细阅读vasp手册https://www.vasp.at/wiki/index.php/Calculate_U_for_LSDA%2BU
#Important: One needs to keep increasing the size of the supercell for these calculations until the value of U stops changing.
#
#
#需提前准备的文件为POSCAR,KPOINTS,vasp_mpi.sh，与submit.sh,start.sh,calc1_u.sh,calc2_u.sh,calc3_u.sh,data.sh,data.py脚本放在同一目录下
#DFT计算的INCAR在start.sh中设置,注意MAGMOM设置应与材料性质匹配（顺磁性，抗磁性等）
#POTCAR赝势类型在start.sh中设置
#
#
#-----开始计算---------------------------------------------------------------------
#运行start.sh即将复制计算文件到各目录下
#在submit.sh中指定原子位点后，运行submit.sh提交计算，在log.txt查看已提交的原子位点，每个位点需完成dft,nsc,sc计算，故至少在log,txt中重复出现三次以上，有时需要手动检查是否完成计算
#由于提交作业数限制，每次最多提交5个原子位点(5*9=45个作业)的计算
#所有计算完成后运行data.sh,得到u矩阵的对角元即为所需取的U值
#sc使用了dft的charge和wave，可修改使用nsc的
#

