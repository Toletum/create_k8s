```bash

kubectl delete pvc -l app=mongo

kubectl apply -f mongoDB/mongo-statefulset-host.yaml

kubectl exec -i mongo-0 -c mongo -- mongosh mongodb://localhost:27017/?directConnection=true \
--username admin --password admin --authenticationDatabase admin --eval '
print(EJSON.stringify(rs.status(), null, 2));
'|jq

```
