#!/bin/bash

NODES=$(awk '/^\[nodes\]/{f=1; next} /^\[/{f=0} f' inventory.ini)

for NODE in ${NODES}; do
  virsh destroy "$NODE"
  virsh undefine "$NODE" --remove-all-storage
done
