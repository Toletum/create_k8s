#!/bin/bash

NODES=$(awk '/\[nodes\]/{flag=1;next} /\[.*\]/{flag=0} flag && NF' inventory.ini)


for node in $NODES; do
    if virsh list --all | grep -q "\<$node\>"; then
            echo "El nodo '$node' ya existe/está listo."
            continue
    fi
    {
      echo "$node"
      ./vm.sh $node
    }&
done && wait
