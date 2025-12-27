#!/bin/bash

NODES=$(grep -v "^#" inventory.ini | awk '/^\[nodes\]/{f=1; next} /^\[/{f=0} f')

for NODE in ${NODES}; do
    echo "Creando snapshot para: $NODE..."

    STATUS=$(virsh domstate "$NODE")
    if [ "$STATUS" = "running" ]; then
        echo "Apagando $NODE de forma segura..."
        virsh shutdown "$NODE"

        # Esperar a que se apague realmente
        while [ "$(virsh domstate "$NODE")" != "shut off" ]; do
            sleep 2
        done
    fi

    virsh snapshot-create-as --domain "$NODE" \
    --name "pre_k8s_$(date +%F_%H-%M)" \
    --description "Antes de instalar Kubernetes" \
    --disk-only \
    --atomic
done
