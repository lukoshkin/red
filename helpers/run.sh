#!/bin/bash
#SBATCH -p mem
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --mem=50G
#SBATCH --time=1-0

example=small
prefix=/home/red/project
sflow=$prefix/src/poreflow/build/sFlow
nproc=$(sed -rn 's;^#SBATCH -n ([0-9]+);\1;p' $0)

module load mpi/openmpi-3.1.4

current_time=$(date +%s)
echo '>>> running the script: started >>>'


mpirun -n $nproc singularity exec \
  -B "$PWD/project:$prefix" \
  -B "$PWD/examples:$prefix/examples" \
  --no-home --pwd "$prefix/examples/$example" \
  red.simg $sflow pore.apr pore.ini


echo '<<< running the script: finished <<<'
elapsed_time=$(( $(date +%s) - $current_time ))
echo "elapsed time : rounded up to $elapsed_time integral seconds"
