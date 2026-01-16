#!/bin/bash

NODE="$1"
FILE="$2"
FILE2="$3"


ssh-keygen -f '/home/toletum/.ssh/known_hosts' -R "${NODE}" > /dev/null 2>&1
scp -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i data/keys root@${NODE}:${FILE} ${FILE2}
 
