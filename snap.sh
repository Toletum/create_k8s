#!/bin/bash

source config

MSG="$*"

./stop.sh

echo "Snapshot nodes..."
for line in $NODES; do
    NODE=$(echo $line | cut -d';' -f1)
    virsh snapshot-create-as --domain "$NODE" \
    --name "$(date +%F_%H-%M-%S)" \
    --description "snapshot: $MSG" \
    --disk-only \
    --atomic
done
