#!/bin/bash
# $1 - path to geom folder

if [[ -f "$1/param.txt" ]]
then
  path2param="$1/param.txt"
elif [[ -f "$1/geom/param.txt" ]]
then
  path2param="$1/geom/param.txt"
else
  echo param.txt not found.
  exit 1
fi

N=$(grep 'NPart' $path2param | tr -s ' ' | cut -d ' ' -f2)

[[ $N -le 1 ]] && { echo $N $1/geom/gcube.out; exit 0; }

for i in $(seq 1 $N)
do
  mesh_parts+=($1/geom/gcube_$(printf "%03d" $i).mesh)
done
echo $N ${mesh_parts[@]}
unset N mesh_parts
