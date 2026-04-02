kubectl apply -f https://raw.githubusercontent.com/Altinity/clickhouse-operator/master/deploy/operator/clickhouse-operator-install-bundle.yaml


kubectl apply -f logging/clickhouse-ha-operator.yaml

kubectl exec -it chi-logs-cluster-log-storage-0-0-0 -- clickhouse-client -q "CREATE DATABASE IF NOT EXISTS logs_db ON CLUSTER 'log-storage'"
