# Lab 01 — Aprovisionamiento de volúmenes y persistencia

**Objetivo**: crear un PVC con Longhorn, escribir datos, destruir el Pod y verificar que los datos sobreviven.

## Paso 1 — Crear StorageClass personalizada

```bash
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn-custom
provisioner: driver.longhorn.io
parameters:
  numberOfReplicas: "1"
  staleReplicaTimeout: "2880"
  fromBackup: ""
allowVolumeExpansion: true
reclaimPolicy: Retain
volumeBindingMode: Immediate
EOF

kubectl get storageclass longhorn-custom
```

## Paso 2 — Crear PVC

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lab01-pvc
  namespace: default
spec:
  storageClassName: longhorn-custom
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Esperar estado Bound
kubectl get pvc lab01-pvc -w
# NAME       STATUS   VOLUME                                     CAPACITY
# lab01-pvc  Bound    pvc-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx   1Gi
```

## Paso 3 — Montar el volumen y escribir datos

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: lab01-writer
  namespace: default
spec:
  containers:
  - name: writer
    image: busybox:1.36
    command: ["sh", "-c", "while true; do sleep 3600; done"]
    volumeMounts:
    - mountPath: /data
      name: storage
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: lab01-pvc
EOF

kubectl wait pod/lab01-writer --for=condition=Ready --timeout=60s

# Escribir datos de prueba
kubectl exec lab01-writer -- sh -c "
  echo 'Dato escrito por lab01-writer' > /data/test.txt
  echo \$(date) >> /data/test.txt
  cat /data/test.txt
"
```

## Paso 4 — Destruir el Pod y verificar persistencia

```bash
# Eliminar el Pod
kubectl delete pod lab01-writer

# Crear un nuevo Pod con el mismo PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: lab01-reader
  namespace: default
spec:
  containers:
  - name: reader
    image: busybox:1.36
    command: ["sh", "-c", "while true; do sleep 3600; done"]
    volumeMounts:
    - mountPath: /data
      name: storage
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: lab01-pvc
EOF

kubectl wait pod/lab01-reader --for=condition=Ready --timeout=60s

# Verificar que los datos persisten
kubectl exec lab01-reader -- cat /data/test.txt
# Debe mostrar el texto escrito por lab01-writer
```

## Limpieza del lab

```bash
kubectl delete pod lab01-reader
kubectl delete pvc lab01-pvc
kubectl delete storageclass longhorn-custom
```

---