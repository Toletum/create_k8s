#!/bin/bash

sudo ls /

NODES=$(grep -v "^#" inventory.ini | awk '/^\[nodes\]/{f=1; next} /^\[/{f=0} f')

for node in $NODES; do
    if virsh list --all | grep -q "\<$node\>"; then
            echo "El nodo '$node' ya existe/está listo."
            continue
    fi
    {
    echo $node
    ./vm.sh $node
    }&
done && wait
