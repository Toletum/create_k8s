#!/bin/bash

NODE="$1"
FILE="$2"


ssh-keygen -f '/home/toletum/.ssh/known_hosts' -R "${NODE}" > /dev/null 2>&1
scp -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i data/keys "$FILE" root@${NODE}:
 
