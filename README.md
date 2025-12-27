# Install k8s in vm

## Image ubuntu.img, keys....

```
mkdir data  
wget -O data/ubuntu24.img https://cloud-images.ubuntu.com/minimal/daily/plucky/current/plucky-minimal-cloudimg-amd64.img
ssh-keygen -t ed25519 -f data/keys -N "" -q
qemu-img convert -f qcow2 -O qcow2 data/ubuntu24.img data/TEMPLATE.qcow2
qemu-img resize data/TEMPLATE.qcow2 +20G
```


## Create nodes
```
./vms.sh
```


## Install ansible
```
python3 -m venv --system-site-packages venv
source venv/bin/activate
pip install ansible
```


## Install k8s
```
ansible-playbook playbook/update.yaml
ansible-playbook playbook/k8s.yaml
```

## Start manager
```
./ssh.sh node01 
```


```
kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Copy: kubeadm join.....

## Start workers
```
./ssh.sh node02 kubeadm join 192.168.122.224:6443 --token ux4c4s.24tl7qv4ewp2hxk2 --discovery-token-ca-cert-hash sha256:4443722b9f9958f0c3e834f8c83bd27a84f5ffdbbb5013a13f96cbb88ba160bb
./ssh.sh node03 kubeadm join 192.168.122.224:6443 --token ux4c4s.24tl7qv4ewp2hxk2 --discovery-token-ca-cert-hash sha256:4443722b9f9958f0c3e834f8c83bd27a84f5ffdbbb5013a13f96cbb88ba160bb
./ssh.sh node04 kubeadm join 192.168.122.224:6443 --token ux4c4s.24tl7qv4ewp2hxk2 --discovery-token-ca-cert-hash sha256:4443722b9f9958f0c3e834f8c83bd27a84f5ffdbbb5013a13f96cbb88ba160bb
```

## Preparing k8s
```
./ssh.sh node01 
```

```
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl get nodes

kubectl get pods -A

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

kubectl top nodes

```

## Hello, World
```
kubectl create deployment hola-k8s --image=k8s.gcr.io/echoserver:1.10
kubectl expose deployment hola-k8s --type=NodePort --port=8080

kubectl get pods
kubectl get svc hola-k8s
```


Host node
```
curl node01:30460
curl node02:30460
curl node03:30460
curl node04:30460
```

```
kubectl delete service hola-k8s
kubectl delete deployment hola-k8s
```

# Local Registry
```
podman run -d -p 5000:5000 --restart=always --name registry registry:2


cat /etc/containers/registries.conf
# Formato V2 Unificado
unqualified-search-registries = ["docker.io", "quay.io"]

[[registry]]
location = "192.168.0.130:5000"
insecure = true
```

```
podman pull alpine
podman tag docker.io/library/alpine 192.168.0.130:5000/mi-alpine-local
podman push 192.168.0.130:5000/mi-alpine-local
```





## Set containerd to local registry

```
ansible-playbook playbook/local.yaml
```

### Test local registry
```
./ssh.sh node01 crictl pull 192.168.0.130:5000/mi-alpine-local
./ssh.sh node02 crictl pull 192.168.0.130:5000/mi-alpine-local
./ssh.sh node03 crictl pull 192.168.0.130:5000/mi-alpine-local
./ssh.sh node04 crictl pull 192.168.0.130:5000/mi-alpine-local


./ssh.sh node01 crictl images
./ssh.sh node02 crictl images
./ssh.sh node03 crictl images
./ssh.sh node04 crictl images
```

### Test local registry in k8s
```
kubectl run prueba-local --image=192.168.0.130:5000/mi-alpine-local -- /bin/sh -c "while true; do echo 'Hola desde el registro local'; sleep 30; done"

kubectl logs prueba-local
```

# Destroy cluster
./delete.sh
