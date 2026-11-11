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
sudo usermod -aG libvirt,kvm $USER
newgrp libvirt

sudo setfacl -m u:libvirt-qemu:--x /home/toletum

echo 'export LIBVIRT_DEFAULT_URI="qemu:///system"' >> ~/.bashrc
source ~/.bashrc


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
python3 -m venv --system-site-packages venv && source venv/bin/activate && pip install ansible dnspython gi
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

ip link (find *br0 - --network bridge=virbr0,model=virtio (vm.yaml))

NODES=$(awk '/\[nodes\]/{flag=1;next} /\[.*\]/{flag=0} flag && NF' inventory.ini)
for node in ${NODES}; do
  {
  echo $node
  ansible-playbook playbook/vm.yaml -e "node=${node}" > "data/${node}.log" 2>&1
  } &
done && wait

for node in ${NODES}; do
  cat "data/${node}.log"
done

virsh list
```


## Install k8s
```bash
ansible-playbook playbook/hosts.yaml
ansible-playbook playbook/update.yaml

./ssh.sh node01 "curl -sfL https://get.k3s.io | sh -"

token=$(./ssh.sh node01 cat /var/lib/rancher/k3s/server/node-token)

./ssh.sh node02 "curl -sfL https://get.k3s.io | K3S_URL=https://node01:6443 K3S_TOKEN='${token}' sh -"
./ssh.sh node03 "curl -sfL https://get.k3s.io | K3S_URL=https://node01:6443 K3S_TOKEN='${token}' sh -"
./ssh.sh node04 "curl -sfL https://get.k3s.io | K3S_URL=https://node01:6443 K3S_TOKEN='${token}' sh -"

scp -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i data/keys root@node01:/etc/rancher/k3s/k3s.yaml kubeconfig

sed -i 's/127\.0\.0\.1/node01/g' kubeconfig

alias kubectl="$PWD/kubectl --kubeconfig $PWD/kubeconfig"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl

kubectl label node node02 node03 node04 kubernetes.io/role=worker
```


# Proxy
```bash
cat <<EOF > temp
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    additionalArguments:
      - "--api.dashboard=true"
      - "--api.insecure=true"
EOF

scp -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i data/keys  temp root@node01:/var/lib/rancher/k3s/server/manifests/traefik-config.yaml
```

```bash
cat << 'EOF' | kubectl apply -f -
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-dashboard
  namespace: kube-system
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`node01`)
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
EOF
```

```bash
curl http://node01/dashboard/
```
