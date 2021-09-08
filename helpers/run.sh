#!/bin/bash
#SBATCH -p mem
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --mem=50G

example=small
nproc=$(sed -rn 's;^#SBATCH -n ([0-9]+);\1;p' $0)
sflow=/home/red/project/src/poreflow/build/sFlow

module load mpi/openmpi-3.1.4
current_time=$(date +%s)
echo '>>> running the script: started >>>'


mpirun -n $nproc singularity exec \
  --no-home --pwd /home/red \
  -B "$PWD"/project:/home/red/project \
  -B "$PWD"/examples:/home/red/project/examples \
  red.simg /bin/bash -c \
  "cd project/examples/$example && $sflow pore.apr pore.ini"


echo '<<< running the script: finished <<<'
elapsed_time=$(( $(date +%s) - $current_time ))
echo "elapsed time : rounded up to $elapsed_time integral seconds"
