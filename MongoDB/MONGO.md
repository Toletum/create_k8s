# Mongo StatefulSet
## images
```bash
podman pull alpine:latest
podman pull mongo:8.0
podman tag alpine:latest 192.168.0.130:5000/alpine:latest
podman tag mongo:8.0 192.168.0.130:5000/mongo:8.0
podman push 192.168.0.130:5000/alpine:latest
podman push 192.168.0.130:5000/mongo:8.0
```

## Playbook
```bash
ansible-playbook mongo-rs.yaml --tags copy
ansible-playbook mongo-rs.yaml --tags labels
ansible-playbook mongo-rs.yaml --tags keyfile
ansible-playbook mongo-rs.yaml --tags apply
ansible-playbook mongo-rs.yaml --tags rs
ansible-playbook mongo-rs.yaml --tags adminuser
```

## Test
### node01
```bash
kubectl exec -it mongo-1 -c mongo -- mongosh 'mongodb://admin:admin@node02:27017/?directConnection=false&appName=mongosh+2.5.0&readPreference=primary'
```

### Local
```bash
wget https://downloads.mongodb.com/compass/mongosh-2.5.1-linux-x64.tgz
tar xf mongosh-2.5.1-linux-x64.tgz

./mongosh-2.5.1-linux-x64/bin/mongosh 'mongodb://admin:admin@node02,node03,node04/?replicaSet=rs0&readPreference=secondary'

./mongosh-2.5.1-linux-x64/bin/mongosh "mongodb://admin:admin@node03:27017/?directConnection=true"
```
