#!/bin/bash
#BSUB -q mpi
#BSUB -n 24
#BSUB -o %J.out
#BSUB -e %J.err
export I_MPI_HYDRA_BOOTSTRAP=lsf
module load intel/2018u4
mpiexec.hydra /share/home/zxchen/VASP5-4/vasp.5.4.4/bin/vasp_std
