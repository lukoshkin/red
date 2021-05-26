#!/bin/bash

SVTKDIR=$1
EXAMPLE=$2
N=$3

[[ -f $EXAMPLE/sFlowToVtk.ini ]] || cp $SVTKDIR/../sFlowToVtk.ini $EXAMPLE

grep 'parallel[ ]\?=.*' $EXAMPLE/sFlowToVtk.ini \
  && sed -ri "s;parallel[ ]?=.*;parallel = $N;" $EXAMPLE/sFlowToVtk.ini \
  || echo "parallel = $N" > $EXAMPLE/sFlowToVtk.ini
