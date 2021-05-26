#!/bin/bash
#SBATCH -p mem
#SBATCH -J test
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --mem=50G
#SBATCH -o out-test-n8.txt
#SBATCH -e err-test-n8.txt

# (!) Specify the required example (!)
example='microchip-2d-30degree'
nproc=$(sed -rn 's;#SBATCH -n ([0-9]+);\1;p' $0)
npart=$(sed -rn "s;^NPart ([0-9]+).*;\1;p" $example/param.txt)

if [[ $nproc -ne $npart ]]
then
  >&2 echo Number of allocated resources and number of mesh parts are different!
  exit 1
fi

# (!) Check the project dir is consistent (!)
project="$HOME/krasnoyarsk/PoreFlow-017"
sflow="$project/src/poreflow/build/sFlow"
cwd="$project/examples"

module load mpi/openmpi-3.1.4
current_time=$(date +%s)
echo '>>> running the script: started >>>'


mpirun -n $nproc singularity exec --bind "$PWD" red.simg \
  bash "$cwd/exec.sh" "$cwd/$example" "$sflow"


echo '<<< running the script: finished <<<'
elapsed_time=$(( $(date +%s) - $current_time ))
echo "elapsed time : rounded up to $elapsed_time integral seconds"
