#!/bin/bash

source colors
source config

NODE="$1"
shift

ssh-keygen -f '/home/toletum/.ssh/known_hosts' -R "${NODE}"
ssh -o StrictHostKeyChecking=no -i data/keys -t root@${NODE} $*
