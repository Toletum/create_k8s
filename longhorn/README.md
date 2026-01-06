# Longhorn
## Check pre-install
```
ansible-playbook playbook/longhorn.yaml

curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/scripts/environment_check.sh | bash
```


# Longhorn con Helm
## Añadir el repositorio
```
helm repo add longhorn https://charts.longhorn.io
helm repo update
```

## Instalar en su propio namespace
```
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
```

# Longhorn con kubectl
```
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/deploy/longhorn.yaml
kubectl -n longhorn-system get pods

kubectl -n longhorn-system patch svc longhorn-frontend -p '{"spec": {"type": "NodePort"}}'

kubectl get svc -n longhorn-system longhorn-frontend

```
