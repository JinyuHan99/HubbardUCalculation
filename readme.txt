Scripts for calculating hubbard U value with VASP for metal oxides
Only suitable for single metal oxides
Please read vasp manual carefully before using them so that you understand how to calculate U value. Link:
https://www.vasp.at/wiki/index.php/Calculate_U_for_LSDA%2BU
The VASP manual only considered one atom spot. My scripts have considered all the spots in a bulk oxide and put them in matrix to solve the problem.
Important: One needs to keep increasing the size of the supercell for these calculations until the value of U stops changing.

Before use:
Prepare POSCAR,KPOINTS,vasp_mpi.sh and put them in the same directory with submit.sh, start.sh, calc1_u.sh, calc2_u.sh, calc3_u.sh, data.sh and data.py
Set INCAR details for DFT calculation in the start.sh file, pay attention that MAGMOM should match with the magnetic properties of the material
Set pseudopotential type of POTCAR in start.sh
My sc calculation used the charge and wave of dft calculation, you can also use those of nsc calculation. The results may be slightly different.

Start calculation:
sh start.sh command will copy files into the right directories
If the submit queue has a limit amount of tasks for each submission, you may assign atoms for calculation in submit.sh. For my situation, I submit calculation for 5 spot (5*9=45 tasks) each time.
sh submit.sh will submit your tasks
You can see the atoms that were already submitted for caculation in log.txt.
Each spot(atom) will do dft,nsc and sc calculation so it should appear in log.txt for at least 3 times. Sometimes you need to check whether the calculation has been finished

After calculation:
After finishing all the calculation, you should sh data.sh to get the diagonal elements. Usually they are only slightly different.
The diagonal elements are the U value you need.


