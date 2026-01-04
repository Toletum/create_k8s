# Standalone

```
kubectl apply -f mongo.yaml

kubectl exec -ti mongodb-0 -c mongodb -- mongosh  -u admin -p 123456 --eval '
use olddata

db.createCollection("myCol");
db.myCol.insertOne({a:'1'});
db.myCol.find();
'

```


# Migracion de Standalone a ReplicaSet


```
openssl rand -base64 756 > mongodb-keyfile
kubectl create secret generic mongo-key --from-file=mongodb-keyfile
```

```
# Replica 3
kubectl apply -f mongo-migration.yaml

./mongosh-2.5.1-linux-x64/bin/mongosh --host node03 --port 27017 -u admin -p 123456 --authenticationDatabase admin

```


```


kubectl exec -i mongodb-0 -c mongodb -- mongosh -u admin -p 123456
rs.initiate({
        _id: "rs0",
        members: [
                { _id: 0, host: "192.168.122.31:27017" },
                { _id: 1, host: "192.168.122.32:27017" },
                { _id: 2, host: "192.168.122.33:27017" }
        ]
});


rs.status().members.forEach(function(m) {
        let lag = (m.optimeDate - rs.status().members.find(p => p.state === 1).optimeDate);
        print(m.name + " [" + m.stateStr + "] Lag: " + lag + "s");
});



./mongosh-2.5.1-linux-x64/bin/mongosh --host node04 --port 27017 -u admin -p 123456 --authenticationDatabase admin

use olddata;
db.myCol.find()


```
