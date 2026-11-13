# Install Proxy
```bash
kubectl apply -f kubernetes-crd-definition-v1.yml
kubectl apply -f kubernetes-crd-rbac.yml
kubectl apply -f Traefik/Traefik.yaml
kubectl apply -f Traefik/Dashboard.yaml

BROWSER: http://node01/dashboard/


kubectl delete -f Traefik/Dashboard.yaml
kubectl delete -f Traefik/Traefik.yaml
kubectl delete -f Traefik/kubernetes-crd-rbac.yml
kubectl delete -f Traefik/kubernetes-crd-definition-v1.yml

```
