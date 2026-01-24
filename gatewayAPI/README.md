kubectl apply -f gatewayAPI/ns.yaml
kubectl apply -f gatewayAPI/etcd.yaml

kubectl -n apisix exec -it etcd-0 -- etcdctl endpoint health   --endpoints=http://etcd-headless.apisix.svc.cluster.local:2379
http://etcd-headless.apisix.svc.cluster.local:2379 is healthy: successfully committed proposal: took = 9.055787ms


kubectl apply -f gatewayAPI/config.yaml
kubectl apply -f gatewayAPI/apisix.yaml


kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
