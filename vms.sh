#!/bin/bash

NODES=$(awk '/^\[nodes\]/{f=1; next} /^\[/{f=0} f' inventory.ini)

for node in $NODES; do
    {
    echo $node
    ./vm.sh $node
    }&
done && wait
