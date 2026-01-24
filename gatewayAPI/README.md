kubectl apply -f gatewayAPI/ns.yaml
kubectl apply -f gatewayAPI/etcd.yaml

kubectl apply -f https://raw.githubusercontent.com/apache/apisix-ingress-controller/v1.8.0/samples/deploy/crd/v1/ApisixRoute.yaml
kubectl apply -f https://raw.githubusercontent.com/apache/apisix-ingress-controller/v1.8.0/samples/deploy/crd/v1/ApisixUpstream.yaml
kubectl apply -f https://raw.githubusercontent.com/apache/apisix-ingress-controller/v1.8.0/samples/deploy/crd/v1/ApisixTls.yaml
kubectl apply -f https://raw.githubusercontent.com/apache/apisix-ingress-controller/v1.8.0/samples/deploy/crd/v1/ApisixClusterConfig.yaml
kubectl apply -f https://raw.githubusercontent.com/apache/apisix-ingress-controller/v1.8.0/samples/deploy/crd/v1/ApisixPluginConfig.yaml

kubectl  apply -f gatewayAPI/rbac.yaml
