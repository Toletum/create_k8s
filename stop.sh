#!/bin/bash

NODES=$(awk '/\[nodes\]/{flag=1;next} /\[.*\]/{flag=0} flag && NF' inventory.ini)

echo "Shutdown nodes..."
for NODE in $NODES; do
    ./ssh.sh $NODE shutdown -h now
done


echo "Waiting for nodes..."
for NODE in $NODES; do
    while [ "$(virsh domstate "$NODE")" != "shut off" ]; do
        sleep 2
    done
done
