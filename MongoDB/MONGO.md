# Mongo StatefulSet 1
## Playbook
```bash
ansible-playbook mongo.yaml
```

## Test
### node01
```bash
kubectl exec -it mongodb-0 -c mongo -- mongosh 'mongodb://admin:123456@localhost:27017/?directConnection=true'
```

### Local
```bash
wget https://downloads.mongodb.com/compass/mongosh-2.5.1-linux-x64.tgz
tar xf mongosh-2.5.1-linux-x64.tgz

./mongosh-2.5.1-linux-x64/bin/mongosh "mongodb://admin:admin@123456:30017/?directConnection=true"
```


