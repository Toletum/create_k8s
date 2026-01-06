# Longhorn

## images

IMAGES="
docker.io/longhornio/longhorn-manager:master-head
docker.io/longhornio/longhorn-engine:master-head
docker.io/longhornio/longhorn-instance-manager:master-head
docker.io/longhornio/longhorn-share-manager:master-head
docker.io/longhornio/backing-image-manager:master-head
docker.io/longhornio/support-bundle-kit:v0.0.55
docker.io/longhornio/csi-attacher:v4.8.1
docker.io/longhornio/csi-provisioner:v5.2.0
docker.io/longhornio/csi-node-driver-registrar:v2.13.0
docker.io/longhornio/csi-resizer:v1.13.2
docker.io/longhornio/csi-snapshotter:v8.2.0
docker.io/longhornio/livenessprobe:v2.15.0
docker.io/longhornio/longhorn-ui:master-head
"

for img in $IMAGES; do
  NEW_IMG=$(echo "$img" | sed 's|docker.io|192.168.0.130:5000|g')
  podman pull $img
  podman tag $img $NEW_IMG
  podman push $NEW_IMG
done


## YAML


## Edit longhorn.yaml

```
/longhorn-driver-deployer

          - --kubelet-root-dir
          - /var/lib/kubelet
```

## Apply
```

kubectl apply -f longhorn.yaml


kubectl -n longhorn-system get pods


kubectl -n longhorn-system patch svc longhorn-frontend -p '{"spec": {"type": "NodePort"}}'

kubectl get svc -n longhorn-system longhorn-frontend

http://node01:31832
```

## Test
```
kubectl apply -f pv-vol.yaml
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f pv-test.yaml

```
