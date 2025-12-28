#!/bin/bash

NODES=$(awk '/\[nodes\]/{flag=1;next} /\[.*\]/{flag=0} flag && NF' inventory.ini)

MSG="$1"

echo "Snapshot nodes..."
for NODE in $NODES; do
    virsh snapshot-create-as --domain "$NODE" \
    --name "$(date +%F_%H-%M-%S)_$MSG" \
    --description "snapshot: $MSG" \
    --disk-only \
    --atomic
done
