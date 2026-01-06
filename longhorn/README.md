# Longhorn con Helm
## Añadir el repositorio
helm repo add longhorn https://charts.longhorn.io
helm repo update

## Instalar en su propio namespace
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace

# Longhorn con kubectl
## Check pre-install

curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/scripts/environment_check.sh | bash
