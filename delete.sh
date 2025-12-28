#!/bin/bash

source config

for line in ${NODES}; do
  node=$(echo $line | cut -d';' -f1)
  while virsh snapshot-delete $node --current; > /dev/null 2>&1; do
      sleep 0.5
  done

  virsh destroy "$node"
  virsh undefine "$node" --remove-all-storage --nvram
done
