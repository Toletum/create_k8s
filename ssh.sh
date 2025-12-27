#!/bin/bash

source colors
source config

NODE="$1"
shift

ip=$(virsh domifaddr "$NODE" | awk '/vnet/ {print $4}' | cut -d'/' -f1)

ssh -i data/keys -t root@${ip} $*
