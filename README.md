# k3s

## Virsh Packages
```bash
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ipforward.conf

sudo sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
sudo ufw reload
sudo ufw route allow in on virbr0
sudo ufw allow in on virbr0

sudo pacman -S libvirt qemu-desktop virt-manager dnsmasq openbsd-netcat cloud-image-utils python-gobject dmidecode bind
sudo systemctl enable --now libvirtd
sudo systemctl enable --now virtqemud.service virtqemud.socket
sudo systemctl enable --now virtnetworkd.service virtnetworkd.socket
sudo systemctl enable --now virtstoraged.service virtstoraged.socket
sudo usermod -aG libvirt,kvm $USER
newgrp libvirt

sudo setfacl -m u:libvirt-qemu:--x /home/toletum

echo 'export LIBVIRT_DEFAULT_URI="qemu:///system"' >> ~/.bashrc
source ~/.bashrc

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin



sudo virsh -c qemu:///system net-start default
sudo virsh -c qemu:///system net-autostart default

```


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
python3 -m venv --system-site-packages venv && source venv/bin/activate && pip install ansible dnspython gi pip install kubernetes
```

## Create nodes
```bash
cat <<EOF | sudo tee -a /etc/hosts
# JCS
192.168.122.2 node01
192.168.122.3 node02
192.168.122.4 node03
192.168.122.5 node04
# JCS
EOF

ip link # (find *br0 - --network bridge=virbr0,model=virtio (vm.yaml))
```


## Install k3s
```bash
ansible-playbook playbook/vms.yaml
ansible-playbook playbook/hosts.yaml
ansible-playbook playbook/update.yaml
ansible-playbook playbook/k3s.yaml


export KUBECONFIG=$PWD/kubeconfig

kubectl label node node02 node03 node04 kubernetes.io/role=worker
```


# Local Path Provisioner
```bash
kubectl get StorageClass
```
