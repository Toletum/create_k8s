#!/bin/bash

source config

echo "Shutdown nodes..."
for line in $NODES; do
    NODE=$(echo $line | cut -d';' -f1)
    ip=$(echo $line | cut -d';' -f2)
    ./ssh.sh $NODE shutdown -h now
done


echo "Waiting for nodes..."
for line in $NODES; do
    NODE=$(echo $line | cut -d';' -f1)
    status=$(virsh domstate "$NODE")
    while [ "$(virsh domstate "$NODE")" != "shut off" ]; do
        sleep 2
    done
done
