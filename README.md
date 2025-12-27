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


# Destroy cluster
./delete.sh
