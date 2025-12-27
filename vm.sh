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

cloud-localds data/cloud-init-${NODE}.iso data/user-data-${NODE} data/meta-data-${NODE}

rm -f data/user-data-${NODE} data/meta-data-${NODE}
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

while true;
do
  echo "Waiting for IP..."
  ip=$(getIP "$NODE")
  if [ "$ip" != "" ]; then
    break
  fi
  sleep 1
done

ssh-keygen -f "${HOME}/.ssh/known_hosts" -R ${ip} > /dev/null 2>&1

echo "${NODE}: ${ip} OK"

sudo sed -i "/${NODE}$/c\\$ip ${NODE}" /etc/hosts
