#!/bin/bash

NODES=$(awk '/\[nodes\]/{flag=1;next} /\[.*\]/{flag=0} flag && NF' inventory.ini)

for node in ${NODES}; do
  echo "Deleting $node"
  while virsh snapshot-delete $node --current; do
    sleep 0.5
  done
  echo "  Snapshots deleted $node"

  virsh destroy "$node"
  virsh undefine "$node" --remove-all-storage --nvram
done
