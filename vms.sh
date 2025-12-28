#!/bin/bash

source config


for line in $NODES; do
    node=$(echo $line | cut -d';' -f1)
    ip=$(echo $line | cut -d';' -f2)
    if virsh list --all | grep -q "\<$node\>"; then
            echo "El nodo '$node' ya existe/está listo."
            continue
    fi
    {
      echo "$node:$ip"
      ./vm.sh $node $ip
    }&
done && wait
