#!/bin/bash

NODE="$1"
shift


echo "Ssh to $NODE"
ssh-keygen -f '/home/toletum/.ssh/known_hosts' -R "${NODE}" > /dev/null 2>&1
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i data/keys -t root@${NODE} $*
