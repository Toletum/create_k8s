# 1. Añadir el repositorio
helm repo add longhorn https://charts.longhorn.io
helm repo update

# 2. Instalar en su propio namespace
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace

