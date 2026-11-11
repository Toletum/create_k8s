# 

## Virsh Packages
sudo pacman -S libvirt qemu-desktop virt-manager dnsmasq openbsd-netcat cloud-image-utils python-gobject
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt,kvm $USER
newgrp libvirt


virsh -c qemu:///system uri

## Image ubuntu.img, keys....

```bash
mkdir data  
wget -O data/ubuntu24.img https://cloud-images.ubuntu.com/minimal/daily/resolute/current/resolute-minimal-cloudimg-amd64.img
ssh-keygen -t ed25519 -f data/keys -N "" -q
qemu-img convert -f qcow2 -O qcow2 data/ubuntu24.img data/TEMPLATE.qcow2
qemu-img resize data/TEMPLATE.qcow2 +20G
```

## Install ansible
```bash
python3 -m venv --system-site-packages venv && source venv/bin/activate && pip install ansible dnspython gi
```

## Create nodes
```bash

cat <<EOF | sudo tee -a /etc/hosts
# JCS
192.168.0.180 node01
192.168.0.181 node02
192.168.0.182 node03
192.168.0.183 node04
# JCS
EOF


NODES=$(awk '/\[nodes\]/{flag=1;next} /\[.*\]/{flag=0} flag && NF' inventory.ini)
for node in ${NODES}; do
  {
  echo $node
  ansible-playbook playbook/vm.yaml -e "node=${node}" > "data/${node}.log" 2>&1
  } &
done && wait
