python3 -m venv --system-site-packages venv

source venv/bin/activate

pip install ansible


ansible-playbook playbook/update.yaml
ansible-playbook playbook/k8s.yaml


./ssh.sh node01 kubeadm init --pod-network-cidr=10.244.0.0/16

./ssh.sh node02 kubeadm join 192.168.122.23:6443 --token ph4y8b.5zj48x8524sor6px --discovery-token-ca-cert-hash sha256:828b133fedfa64f0d095e544e6608bdef9e11ffe6d40a67ab4672ad932e67ccc
./ssh.sh node03 kubeadm join 192.168.122.23:6443 --token ph4y8b.5zj48x8524sor6px --discovery-token-ca-cert-hash sha256:828b133fedfa64f0d095e544e6608bdef9e11ffe6d40a67ab4672ad932e67ccc
./ssh.sh node04 kubeadm join 192.168.122.23:6443 --token ph4y8b.5zj48x8524sor6px --discovery-token-ca-cert-hash sha256:828b133fedfa64f0d095e544e6608bdef9e11ffe6d40a67ab4672ad932e67ccc


kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
