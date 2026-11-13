# Kubectl

## Crear NS
kubectl apply -f apisix/ns.yaml

## Crear Etcd
kubectl apply -f apisix/etcd-ha.yaml
kubectl -n apisix get pods
### Etcd Cluster
kubectl exec -it etcd-0 -n apisix -- etcdctl endpoint status --write-out=table --endpoints=etcd-0.etcd:2379,etcd-1.etcd:2379,etcd-2.etcd:2379

## Crear APISIX

kubectl apply -f apisix/apisix.yaml
kubectl -n apisix get pods

## Crear Route

kubectl apply -f apisix/EchoServer.yaml

curl "http://node02:9180/apisix/admin/routes/1" \
-H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" \
-X PUT -d '
{
  "uri": "/echo",
  "plugins": {
    "proxy-rewrite": {
      "headers": {
        "set": {
          "X-Server-Interal": "K3S"
        }
      }
    },
    "response-rewrite": {
      "headers": {
        "set": {
          "X-Server-ID": "Toletum"
        }
      }
    }
  },
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "echo-service.default.svc.cluster.local:8080": 1
    }
  }
}'


curl -i http://node02:8080/echo
curl -i http://node03:8080/echo
curl -i http://node04:8080/echo


http://node03:30180/ui

# Clean
kubectl delete -f apisix/apisix.yaml
kubectl delete -f apisix/etcd.yaml
kubectl delete -f apisix/ns.yaml
