# create_k8s

Scripts y playbooks de Ansible/Bash/libvirt para crear un clúster Kubernetes (kubeadm o k3s) sobre VMs KVM de Ubuntu, con registry local, almacenamiento, gateway (APISIX), HAProxy y ejemplos (MongoDB, Longhorn, lighttpd).

## Visibilidad y rama
- Público (github.com/Toletum/create_k8s). Rama por defecto: `main`.
- Descripción en GitHub: "create_k8s".

## Stack
- Bash, Ansible (playbooks en `playbook/`), libvirt/virsh y qemu-img en el host.
- Plantillas cloud-init (`templates/*.j2`).
- Manifiestos Kubernetes YAML (`apisix/`, `gatewayAPI/`, `http/`, `longhorn/`, `MongoDB/`).
- Herramientas que el README indica descargar: `kubectl`, `helm` (v3.13.1), `ansible` con `community.libvirt`, `dnspython`.
- No hay `requirements.txt`; `VMS.md` lista `pip install ansible dnspython` y `ansible-galaxy collection install community.libvirt`.

## Estructura
- `README.md`: guía principal (registry, VMs, Ansible, kubeadm, flannel, metrics-server, prueba hello-world, destrucción, helm).
- `Simple.md`: guía abreviada de instalación. Solapa con `README.md`.
- `NETWORK.md`: rutas y NAT para acceder a la red 192.168.122.0/24 de las VMs.
- `Storage.MD`: instalación de local-path-provisioner.
- `VMS.md`: dependencias de Ansible.
- `inventory.ini`: grupo `[nodes]` con node01–node04; `ansible_user=root`, clave `./data/keys`.
- `ansible.cfg`: inventario por defecto, `host_key_checking=False`, `forks=10`.
- `up.sh`: crea las VMs, prepara nodos, instala kubeadm, flannel y metrics-server.
- `k3s.sh`: alternativa con k3s (node01 server, resto agentes; configura Traefik).
- `start.sh` / `stop.sh`: arrancan y apagan las VMs, esperando SSH.
- `snap.sh <mensaje>`: snapshot `--disk-only` de cada VM.
- `delete.sh`: borra snapshots, destruye y elimina las VMs con su almacenamiento.
- `ssh.sh <nodo> <cmd>` y `copy.sh <nodo> <origen> <destino>`: SSH/SCP con la clave de `data/keys`.
- `playbook/`: `vm.yaml` (crear VM), `hosts.yaml`, `update.yaml`, `k8s.yaml`, `k8s-master.yaml`, `k8s-worker.yaml`, `local.yaml` (sin Internet), `registry.yaml`, `longhorn.yaml`, `reboot.yaml`.
- `templates/`: `user-data.j2`, `meta-data.j2`, `network-config.j2` para cloud-init.
- `apisix/`, `gatewayAPI/`: APISIX y Gateway API (etcd, ingress, rutas de prueba).
- `http/`: HAProxy y lighttpd de ejemplo.
- `longhorn/`: lighttpd con PVC compartido.
- `MongoDB/`: ReplicaSet de MongoDB en StatefulSet, PV y playbook (no revisados en detalle).

## Comandos
Preparación (desde la raíz; crea `data/`):
```bash
mkdir data
wget -O data/ubuntu24.img <url-de-la-imagen>
ssh-keygen -t ed25519 -f data/keys -N "" -q
qemu-img convert -f qcow2 -O qcow2 data/ubuntu24.img data/TEMPLATE.qcow2
qemu-img resize data/TEMPLATE.qcow2 +20G
python3 -m venv venv && source venv/bin/activate && pip install ansible dnspython
ansible-galaxy collection install community.libvirt
```
Clúster:
```bash
./up.sh                 # crea todo el clúster (kubeadm)
./start.sh | ./stop.sh  # arranca / apaga VMs
./snap.sh "<mensaje>"   # snapshot de las VMs
./delete.sh             # destruye VMs y almacenamiento (irreversible)
./k3s.sh                # alternativa con k3s
```
Playbooks sueltos (orden de `README.md`): `hosts.yaml`, `update.yaml`, `k8s.yaml`, `local.yaml`, `registry.yaml`, `k8s-master.yaml`, `k8s-worker.yaml`.
- Tests: no hay. Verificación manual: `kubectl get nodes`, `kubectl top nodes`.
- Ejecución real no verificada en este entorno.

## Configuración
- `inventory.ini`: nodos, usuario y clave SSH.
- `data/` (ignorado): claves, imágenes y `TEMPLATE.qcow2`.
- `kubeconfig`, `kubectl`, `helm`: generados, ignorados por git.
- Registry local `192.168.0.130:5000` (hardcoded en `README.md` y `NETWORK.md`).
- Rutas absolutas de otro usuario en `ssh.sh` y `copy.sh` (`/home/toletum/.ssh/known_hosts`).
- Sin variables de entorno.

## Convenciones y reglas para agentes
- Ejecutar los scripts desde la raíz: usan `data/keys`, `inventory.ini` y `playbook/` con rutas relativas.
- Los nodos se listan en `inventory.ini`, sección `[nodes]`; los scripts los leen con `awk`. Añadir nodos ahí.
- No versionar `data/`, `kubeconfig` ni binarios (ver `.gitignore`).
- `ssh.sh` y `copy.sh` eliminan la entrada del nodo en `known_hosts` antes de conectar.
- Antes de ejecutar `delete.sh`, `up.sh` o `k3s.sh` confirmar con el usuario: destruyen o recrean VMs.

## Estado
- Sin tests. Hay dos guías solapadas (`README.md` y `Simple.md`) y una antigua (`gatewayAPI/README-OLD.md`).
- **Secreto expuesto en el repo**: `apisix/README.md` (línea 23) y `gatewayAPI/README-OLD.md` (línea 66) contienen una API key literal de APISIX en un `curl`. Redactada aquí. Rotarla y reemplazarla por una variable de entorno o un Secret.
- `k3s.sh` activa el dashboard de Traefik con `--api.insecure=true` (sin autenticación).
- `metrics-server` se instala con `--kubelet-insecure-tls`.
- Las URLs de manifiestos apuntan a `releases/latest` o `master` (sin versión fija); `Storage.MD` usa `master`.
- `delete.sh` elimina almacenamiento sin confirmación.
- `README.md` referencia Kubernetes v1.31.14 y una imagen Ubuntu "plucky" minimal; no verificado que siga disponible.
- Estado del clúster: no verificado.
