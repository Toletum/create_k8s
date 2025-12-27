#!/bin/bash

NODES=$(grep -v "^#" inventory.ini | awk '/^\[nodes\]/{f=1; next} /^\[/{f=0} f')

for NODE in ${NODES}; do
  virsh destroy "$NODE"
  virsh undefine "$NODE" --remove-all-storage
done
