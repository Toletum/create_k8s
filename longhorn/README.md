# Longhorn
## Check pre-install
```bash
ansible-playbook playbook/longhorn.yaml
```

```bash
node01
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/scripts/environment_check.sh | bash
```


# Longhorn con Helm
## Añadir el repositorio
```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
```

## Instalar en su propio namespace
```bash
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
```

# Longhorn con kubectl
```bash
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/deploy/longhorn.yaml
kubectl -n longhorn-system get pods

kubectl -n longhorn-system patch svc longhorn-frontend -p '{"spec": {"type": "NodePort"}}'

kubectl get svc -n longhorn-system longhorn-frontend
```
