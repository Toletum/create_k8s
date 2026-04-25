# Mongo StatefulSet
## Playbook
```bash
ansible-playbook mongo-rs.yaml 
```

## Test
### node01
```bash
kubectl exec -it mongo-1 -c mongo -- mongosh 'mongodb://admin:admin@node02:27017/?directConnection=false&appName=mongosh+2.5.0&readPreference=primary'
```

### Local
```bash
wget https://downloads.mongodb.com/compass/mongosh-2.8.2-linux-x64.tgz
tar xf mongosh-2.8.2-linux-x64.tgz

./mongosh-2.8.2-linux-x64/bin/mongosh 'mongodb://admin:admin@node02,node03,node04/?replicaSet=rs0&readPreference=secondary'

./mongosh-2.8.2-linux-x64/bin/mongosh "mongodb://admin:admin@123456:30017/?directConnection=true"
```
