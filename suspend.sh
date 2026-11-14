#!/bin/bash

NODES=$(awk '/\[nodes\]/{flag=1;next} /\[.*\]/{flag=0} flag && NF' inventory.ini)


for node in ${NODES}; do
    virsh save $node /var/lib/libvirt/save/${node}.save
done

virsh list --all
