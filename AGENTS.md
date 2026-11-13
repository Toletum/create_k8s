# create_k8s

Scripts y playbooks de Ansible/Bash para aprovisionar VMs Ubuntu con KVM/libvirt y desplegar un clúster k3s. La configuración activa usa `node01` como servidor k3s y `node02`–`node04` como agentes. No hay un flujo kubeadm activo en la raíz.

## Alcance de la revisión
- Analizar y modificar solo archivos activos fuera de directorios llamados `OLD`; ignorar por completo `OLD/` y `playbook/OLD/` (no leer ni usar su contenido).
- `venv/` y `data/` son directorios locales generados; no inspeccionar sus contenidos para entender o modificar el código del proyecto.
- La guía vigente en la raíz es `README.md`. `Storage.MD` está vacío.

## Estructura activa
- `README.md`: preparación del host, imagen cloud, VMs y flujo de instalación de k3s.
- `inventory.ini`: inventario Ansible; grupo `[nodes]` con `node01`–`node04`, usuario `root` y clave `data/keys`.
- `ansible.cfg`: usa `inventory.ini`, desactiva la comprobación de host keys y fija `forks=10`.
- `playbook/vm.yaml`: crea una VM, imagen y configuración cloud-init con `virt-install` y `cloud-localds`.
- `playbook/vms.yaml`: lanza `vm.yaml` en paralelo para los nodos del inventario.
- `playbook/hosts.yaml`: resuelve nombres de nodos y agrega sus IP a `/etc/hosts` de los nodos.
- `playbook/update.yaml`: actualiza paquetes y reinicia cuando el sistema lo solicita.
- `playbook/k3s.yaml`: instala k3s en `node01`, une los agentes y copia `kubeconfig` al proyecto.
- `templates/`: plantillas cloud-init; la red asigna IP estática tomada de DNS, interfaz `ens2` y gateway `192.168.122.1`.
- `Traefik/Traefik.yaml`: configuración del dashboard de Traefik y su `IngressRoute`.
- `longhorn/`: guía de despliegue de Longhorn y ejemplo de aplicación lighttpd con PVC compartido.
- `start.sh`, `stop.sh`, `delete.sh`, `ssh.sh`, `copy.sh`: operaciones de VMs y acceso remoto.
- `.gitignore`: excluye `venv/`, `data/`, `kubeconfig`, binarios `kubectl`/`helm` y artefactos.

## Flujo y comandos
Ejecutar comandos desde la raíz: los scripts y playbooks dependen de rutas relativas al proyecto.

La guía documenta este flujo de Ansible:
```bash
ansible-playbook playbook/vms.yaml
ansible-playbook playbook/hosts.yaml
ansible-playbook playbook/update.yaml
ansible-playbook playbook/k3s.yaml
export KUBECONFIG="$PWD/kubeconfig"
kubectl get nodes
```
`README.md` también propone aplicar la etiqueta worker a `node02`–`node04` e instalar Traefik con `ansible-playbook Traefik/Traefik.yaml`.


- `./start.sh`: inicia los dominios listados en `[nodes]` y espera a que responda SSH.
- `./stop.sh`: apaga los nodos por SSH y espera su estado `shut off` en libvirt.
- `./delete.sh`: elimina snapshots, destruye los dominios y borra sus discos con `virsh undefine --remove-all-storage --nvram`.
- `./ssh.sh <nodo> <comando>`: ejecuta un comando SSH como `root`.
- `./copy.sh <nodo> <archivo-remoto> <destino-local>`: copia un archivo desde el nodo a la máquina local.

No existen en la raíz `up.sh`, `snap.sh` ni los playbooks kubeadm citados en documentación antigua; no documentarlos como comandos disponibles.

## Requisitos y configuración
- Host Linux con KVM/libvirt, `virsh`, `virt-install`, `cloud-localds` y `qemu-img`; la guía de instalación de paquetes usa comandos de Arch Linux.
- Python/Ansible y dependencias usadas por los playbooks. `vm.yaml` llama al lookup `community.general.dig`; `Traefik/Traefik.yaml` usa `kubernetes.core.k8s`. No hay un archivo de requirements que fije estas colecciones.
- Preparación de datos según `README.md`: imagen Ubuntu en `data/ubuntu24.img`, clave SSH `data/keys` y `data/keys.pub`, y plantilla `data/TEMPLATE.qcow2`.
- Los nombres `node01`–`node04` deben resolver desde el host (la guía muestra entradas en `/etc/hosts`). `vm.yaml` usa la red `virbr0`, gateway `192.168.122.1` y los valores IP de la resolución DNS.
- `inventory.ini` define usuario, clave y `ansible_python_interpreter`; añade o cambia nodos allí solo si también se actualizan los scripts/playbooks que actualmente tienen nodos fijados en su lógica.
- `ssh.sh` y `copy.sh` usan la ruta fija `/home/toletum/.ssh/known_hosts`; varios comandos desactivan la validación de host keys.
- No versionar claves, imágenes, logs, `kubeconfig` ni binarios descargados. `kubeconfig` contiene credenciales de acceso al clúster.

## Reglas para cambios y operaciones
- Antes de editar, revisar solo archivos fuera de `OLD/`; no recuperar ni reactivar instrucciones de esas carpetas.
- Conservar las rutas relativas y el inventario como fuente de nodos; las operaciones deben ejecutarse desde la raíz.
- No ejecutar comandos que creen, reconfiguren o eliminen VMs/clúster sin autorización explícita. Confirmar especialmente antes de `delete.sh`, `playbook/vm.yaml` o `playbook/vms.yaml`: `delete.sh` borra discos y `vm.yaml` copia la imagen plantilla sobre el disco de destino con `force: yes`.
- No ejecutar `delete.sh` como parte de una verificación: es irreversible y no pide confirmación.
- No exponer claves ni kubeconfig en logs, documentación o control de versiones.

## Estado conocido y validación
- No hay suite de tests; la ejecución real requiere un host libvirt y VMs, no disponibles para validación ordinaria.
- `start.sh` y `stop.sh` esperan indefinidamente a SSH/virsh si un nodo no alcanza el estado esperado.
- `Traefik/Traefik.yaml` habilita el dashboard de Traefik con `--api.insecure=true`; el ejemplo publica la ruta por HTTP sin autenticación.
- La instalación de k3s usa el instalador remoto `https://get.k3s.io` sin fijar versión.
- `Traefik/Traefik.yaml` notifica el handler `Verificar despliegue`, pero no define ese handler; además requiere la colección `kubernetes.core`.
- `longhorn/README.md` referencia `playbook/longhorn.yaml`, que no está presente entre los playbooks activos.
- Para validaciones locales, usar `bash -n` sobre los scripts y `ansible-playbook --syntax-check` sobre los playbooks; no ejecutar playbooks reales como sustituto de una prueba de sintaxis.
- Estado del clúster y compatibilidad actual de las versiones/URLs: no verificados.
