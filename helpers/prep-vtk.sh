#!/bin/bash

SVTKDIR=$1
EXAMPLE=$2
N=$3
M=$4

RANGE=0

if [[ $N -gt 1 ]]
then
  top=$(ls $EXAMPLE/pipeout_un*_P001.bin 2> /dev/null | wc -w)
  [[ $top -gt 1 ]] && RANGE="1-$top"
else
  top=$(ls $EXAMPLE/pipeout_un*.bin 2> /dev/null | wc -w)
  [[ $top -gt 1 ]] && RANGE="1-$top"
fi

[[ -n $M ]] && RANGE=$M
[[ -f $EXAMPLE/sFlowToVtk.ini ]] || cp $SVTKDIR/../sFlowToVtk.ini $EXAMPLE

grep -q 'parallel[ ]\?=.*' $EXAMPLE/sFlowToVtk.ini \
  && sed -ri "s;parallel[ ]?=.*;parallel = $N;" $EXAMPLE/sFlowToVtk.ini \
  || echo "parallel = $N" > $EXAMPLE/sFlowToVtk.ini

grep -q 'unstationary[ ]\?=.*' $EXAMPLE/sFlowToVtk.ini \
  && sed -ri "s;unstationary[ ]?=.*;unstationary = $RANGE;" $EXAMPLE/sFlowToVtk.ini \
  || echo "unstationary = $RANGE" > $EXAMPLE/sFlowToVtk.ini

