#!/bin/bash

NODES=$(awk '/\[nodes\]/{flag=1;next} /\[.*\]/{flag=0} flag && NF' inventory.ini)

MSG="$1"
NAME="$(date +%F_%H-%M-%S)_$MSG"

echo "Snapshot nodes..."
for NODE in $NODES; do
    virsh snapshot-create-as --domain "$NODE" \
    --name "$NAME" \
    --description "snapshot: $MSG" \
    --disk-only \
    --atomic
done
