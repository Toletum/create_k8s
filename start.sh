#!/bin/bash

source config

echo "Starting vm's..."
for line in $NODES; do
    NODE=$(echo $line | cut -d';' -f1)
    virsh start "$NODE"
done


echo "Waiting for linux to start..."
for line in $NODES; do
    NODE=$(echo $line | cut -d';' -f1)
    ip=$(echo $line | cut -d';' -f2)
    until ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i data/keys root@${ip} "update" > /dev/null 2>&1; do
        sleep 2
    done
done
