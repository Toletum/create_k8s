kubectl apply -f gatewayAPI/test-pod.yaml
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml



helm repo add apisix https://apache.github.io/apisix-helm-chart
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Con nodeport
helm install apisix \
  --namespace ingress-apisix \
  --create-namespace \
  --set ingress-controller.enabled=true \
  --set etcd.persistence.enabled=false \
  --set etcd.replicaCount=1 \
  --set gateway.type=NodePort \
  --set ingress-controller.apisix.adminService.namespace=ingress-apisix \
  --set ingress-controller.gatewayProxy.createDefault=true \
  apisix/apisix

# Con hostNetwork

helm install apisix \
  --namespace ingress-apisix \
  --create-namespace \
  --set ingress-controller.enabled=true \
  --set etcd.persistence.enabled=false \
  --set etcd.replicaCount=1 \
  --set ingress-controller.apisix.adminService.namespace=ingress-apisix \
  --set ingress-controller.gatewayProxy.createDefault=true \
  --set gateway.type=ClusterIP \
  --set gateway.http.containerPort=8080 \
  --set gateway.hostNetwork=true \
  --set gateway.dnsPolicy=ClusterFirstWithHostNet \
  --set gateway.service.enabled=false \
  apisix/apisix
  
  
kubectl -n ingress-apisix get pods

kubectl apply -f gatewayAPI/route.yaml

kubectl get svc -n ingress-apisix

curl -i http://node01:32632/echo


# SIN GATEWAY

Local Path Provisioner

helm install apisix apisix/apisix \
  --namespace ingress-apisix \
  --create-namespace \
  --set apisix.hostNetwork=true \
  --set apisix.nodeListen=8080 \
  --set gateway.type=None \
  --set etcd.persistence.enabled=true \
  --set etcd.persistence.storageClass="local-path" \
  --set etcd.persistence.size=8Gi

kubectl get configmap apisix -n ingress-apisix -o jsonpath='{.data.config\.yaml}' | grep -A 5 "admin_key"

curl "http://127.0.0.1:9180/apisix/admin/routes/2" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" \
-X PUT -d '
{
  "uri": "/echo",
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "echo-service.default.svc.cluster.local:8080": 1
    }
  }
}'


# Solo si el upgrade anterior no funcionó:
helm install apisix-dashboard apisix/apisix-dashboard \
  --namespace ingress-apisix \
  --set config.conf.apisix.admin_key=edd1c9f034335f136f87ad84b625c8f1 \
  --set config.conf.etcd.endpoints={apisix-etcd:2379}


## Clean

helm uninstall apisix -n ingress-apisix
kubectl delete ns ingress-apisix


./stop.sh

virsh snapshot-revert node01 2026-01-17_17-23-14_k8s
virsh snapshot-revert node02 2026-01-17_17-23-15_k8s
virsh snapshot-revert node03 2026-01-17_17-23-15_k8s
virsh snapshot-revert node04 2026-01-17_17-23-15_k8s


./start.sh
