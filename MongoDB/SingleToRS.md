# Migracion de Stanalone a ReplicaSet


```
openssl rand -base64 756 > mongodb-keyfile
kubectl create secret generic mongo-key --from-file=mongodb-keyfile
```

```
# Replica 3
kubectl apply -f mongo-migration.yaml

# Borrar el viejo
kubectl delete pod mongodb-0


./mongosh-2.5.1-linux-x64/bin/mongosh --host node03 --port 27017 -u admin -p 123456 --authenticationDatabase admin

```
