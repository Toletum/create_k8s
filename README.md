# Local Registry
## Install
```bash
cat <<EOF | sudo tee /etc/containers/registries.conf
# Formato V2 Unificado
unqualified-search-registries = ["docker.io", "quay.io"]

[[registry]]
location = "192.168.0.130:5000"
insecure = true
EOF

podman run -d -p 5000:5000 --restart=always --name registry registry:2
```

### Test
```bash
podman pull alpine
podman tag docker.io/library/alpine 192.168.0.130:5000/mi-alpine-local
podman push 192.168.0.130:5000/mi-alpine-local
```

## Cargar imagenes
```bash
IMAGES=(
  "registry.k8s.io/kube-apiserver:v1.31.14"
  "registry.k8s.io/kube-controller-manager:v1.31.14"
  "registry.k8s.io/kube-scheduler:v1.31.14"
  "registry.k8s.io/kube-proxy:v1.31.14"
  "registry.k8s.io/etcd:3.5.24-0"
  "registry.k8s.io/pause:3.10"
  "registry.k8s.io/pause:3.8"
  "ghcr.io/flannel-io/flannel:v0.27.4"
  "ghcr.io/flannel-io/flannel-cni-plugin:v1.8.0-flannel1"
  "registry.k8s.io/coredns/coredns:v1.11.3"
  "registry.k8s.io/metrics-server/metrics-server:v0.8.0"
)

REGISTRY="192.168.0.130:5000"

for img in "${IMAGES[@]}"; do
  NEW_IMG=$(echo "$img" | sed 's|registry.k8s.io|192.168.0.130:5000|g; s|ghcr.io|192.168.0.130:5000|g')
  podman pull $img
  podman tag $img $NEW_IMG
  podman push $NEW_IMG
done
```


# Install k8s in vm

add in /etc/hosts

```
192.168.122.30 node01
192.168.122.31 node02
192.168.122.32 node03
192.168.122.33 node04
```

## Image ubuntu.img, keys....

```bash
mkdir data  
wget -O data/ubuntu24.img https://cloud-images.ubuntu.com/minimal/daily/plucky/current/plucky-minimal-cloudimg-amd64.img
ssh-keygen -t ed25519 -f data/keys -N "" -q
qemu-img convert -f qcow2 -O qcow2 data/ubuntu24.img data/TEMPLATE.qcow2
qemu-img resize data/TEMPLATE.qcow2 +20G
```

## Install ansible
```bash
python3 -m venv --system-site-packages venv
source venv/bin/activate
pip install ansible
```


## Create nodes
```bash

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
ansible-playbook playbook/k8s.yaml

# Check no Internet
ansible-playbook playbook/local.yaml

# Local registry with Internet
ansible-playbook playbook/registry.yaml


# Test
crictl pull 192.168.0.130:5000/mi-alpine-local

```

## Disabled Intenet access
```bash
sudo iptables -L  FORWARD  --line-numbers

# No internet access
sudo iptables -I FORWARD -s node01 -j DROP
sudo iptables -I FORWARD -s node02 -j DROP
sudo iptables -I FORWARD -s node03 -j DROP
sudo iptables -I FORWARD -s node04 -j DROP

# Internet access
sudo iptables -D FORWARD -s node01 -j DROP
sudo iptables -D FORWARD -s node02 -j DROP
sudo iptables -D FORWARD -s node03 -j DROP
sudo iptables -D FORWARD -s node04 -j DROP
```

## Start manager
```bash
ansible-playbook playbook/k8s-manager.yaml

scp -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i data/keys root@node01:/etc/kubernetes/admin.conf kubeconfig

alias kubectl='./kubectl --kubeconfig ./kubeconfig'
alias k='./kubectl --kubeconfig ./kubeconfig'

kubectl get nodes
```
	
## Start workers
```bash
ansible-playbook playbook/k8s-worker.yaml

kubectl get nodes
```

## Preparing k8s
```bash

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

until kubectl top nodes >/dev/null 2>&1; do
  echo "Esperando a que Metrics Server esté listo..."
  sleep 5
done

kubectl top nodes
```

## Hello, World
### Install image local registry
```bash
podman pull k8s.gcr.io/echoserver:1.10
podman tag k8s.gcr.io/echoserver:1.10 192.168.0.130:5000/echoserver:1.10
podman push 192.168.0.130:5000/echoserver:1.10
```

### Deploy
```bash
kubectl create deployment hola-k8s --image=192.168.0.130:5000/echoserver:1.10
kubectl expose deployment hola-k8s --type=NodePort --port=8080

kubectl get pods
kubectl get svc hola-k8s
```
Copy de port: 3xxxx

### curl
```bash
curl node01:31852
curl node02:31852
curl node03:31852
curl node04:31852
```

### Clean tests
```bash
kubectl delete deployment hola-k8s
kubectl delete svc hola-k8s
```

# Destroy cluster
```bash
./delete.sh
```

# Tools
## Helm & kubectl
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
```
