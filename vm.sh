#!/bin/bash

source config
source colors

NODE="$1"

if [ "$NODE" == "" ]; then
  echo "NODE?"
  exit 1
fi

if [ ! -f data/TEMPLATE.qcow2 ]; then
  echo "TEMPLATE.qcow2?"
  exit 1
fi

IP=$(nslookup ${NODE} | awk '/^Address: / { addr=$2 } END { print addr }')

if [ "$IP" == "" ]; then
  echo "IP? ${NODE} in /etc/hosts"
  exit 1
fi

cp data/TEMPLATE.qcow2 data/${NODE}.qcow2

KEYSPUB=$(cat data/keys.pub)

cat <<EOF > data/meta-data-${NODE}
instance-id: cluster
local-hostname: ${NODE}
EOF

cat <<EOF > data/user-data-${NODE}
#cloud-config
users:
  - name: root
    shell: /bin/bash
    ssh_authorized_keys:
      - ${KEYSPUB}

disable_root: false
EOF

cat <<EOF > data/network-config-${NODE}
version: 2
ethernets:
  ens2:
    dhcp4: false
    addresses:
      - ${IP}/24
    nameservers:
      addresses: [8.8.8.8, 1.1.1.1]
    routes:
      - to: default
        via: 192.168.122.1
EOF

cloud-localds -N data/network-config-${NODE} data/cloud-init-${NODE}.iso data/user-data-${NODE} data/meta-data-${NODE}

rm -f data/user-data-${NODE} data/meta-data-${NODE} data/network-config-${NODE}
rm -f data/node_${NODE}.txt

touch data/node_${NODE}.txt
touch data/${NODE}.qcow2

chmod 664 data/node_${NODE}.txt data/${NODE}.qcow2

/usr/bin/virt-install \
  --name ${NODE} \
  --memory ${MEM} \
  --vcpus ${CPU} \
  --disk path=data/${NODE}.qcow2,format=qcow2 \
  --disk path=data/cloud-init-${NODE}.iso,device=cdrom \
  --os-variant generic \
  --network network=default,model=virtio \
  --import \
  --graphics none \
  --console file,path=/home/toletum/k8s/data/node_${NODE}.txt,target_type=serial > data/${NODE}-VM.txt 2>&1

ssh-keygen -f "${HOME}/.ssh/known_hosts" -R ${NODE} > /dev/null 2>&1


until ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i data/keys root@${NODE} "cloud-init status --wait" > /dev/null 2>&1; do
    sleep 2
done

echo "${NODE}: ${IP} OK"
