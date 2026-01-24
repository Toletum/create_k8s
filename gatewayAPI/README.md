kubectl apply -f gatewayAPI/ns.yaml
kubectl apply -f gatewayAPI/etcd.yaml

kubectl -n apisix exec -it etcd-0 -- etcdctl endpoint health



kubectl apply -f gatewayAPI/config.yaml
