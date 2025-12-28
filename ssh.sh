#!/bin/bash

source colors
source config

NODE="$1"
shift


IP=$(echo "$NODES"|grep ${NODE}|cut -d";" -f2)

echo "Ssh to $NODE -> $IP"
ssh-keygen -f '/home/toletum/.ssh/known_hosts' -R "${IP}" > /dev/null 2>&1
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i data/keys -t root@${IP} $*
