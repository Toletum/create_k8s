#!/bin/bash

NODES=$(awk '/\[nodes\]/{flag=1;next} /\[.*\]/{flag=0} flag && NF' inventory.ini)


for node in ${NODES}; do
  echo "Deleting $node"
    for ss in $(virsh snapshot-list $node --name); do
    echo "  Deleting snapshot $ss"
    virsh snapshot-delete $node $ss
  done

  echo "  Destroy"
  virsh destroy "$node"
  echo "  Delete"
  virsh undefine "$node" --remove-all-storage --nvram
done
