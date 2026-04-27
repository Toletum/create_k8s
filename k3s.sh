#!/bin/bash

NODES=$(awk '/\[nodes\]/{flag=1;next} /\[.*\]/{flag=0} flag && NF' inventory.ini)
for node in ${NODES}; do
  {
  echo $node
  ansible-playbook playbook/vm.yaml -e "node=${node}" > "data/${node}.log" 2>&1
  } &
done && wait

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

kubectl label node node02 node03 node04 kubernetes.io/role=worker


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


cat <<EOF | kubectl apply -f -
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-dashboard
  namespace: kube-system
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`node01`) # Cambia esto por tu dominio o IP
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService

EOF


curl http://node01/dashboard/
