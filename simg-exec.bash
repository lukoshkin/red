#!/bin/bash
# crutches for singularity

unzip -nqqd project PoreFlow*.zip
cp -n helpers/* examples/
chmod +x project/bin/poremesh

cmd="source .bashrc && $1"
singularity exec --no-home --pwd /home/red \
  -B $PWD/project:/home/red/project \
  -B $PWD/examples:/home/red/project/examples \
  red.simg /bin/bash -c "$cmd"
