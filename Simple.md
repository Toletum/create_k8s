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


ansible-playbook playbook/k8s-master.yaml

scp -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i data/keys root@node01:/etc/kubernetes/admin.conf kubeconfig

alias kubectl='./kubectl --kubeconfig ./kubeconfig'
alias k='./kubectl --kubeconfig ./kubeconfig'

kubectl get nodes

ansible-playbook playbook/k8s-worker.yaml

kubectl get nodes

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

until kubectl top nodes >/dev/null 2>&1; do
  echo "Esperando a que Metrics Server esté listo..."
  sleep 5
done

kubectl top nodes
