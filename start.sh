#!/bin/bash

NODES=$(awk '/\[nodes\]/{flag=1;next} /\[.*\]/{flag=0} flag && NF' inventory.ini)

echo "Starting vm's..."
for NODE in $NODES; do
    virsh start "$NODE"
done


echo "Waiting for linux to start..."
for NODE in $NODES; do
    until ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i data/keys root@${NODE} "uptime" > /dev/null 2>&1; do
        sleep 2
    done
    echo "$NODE is up & running"
done
