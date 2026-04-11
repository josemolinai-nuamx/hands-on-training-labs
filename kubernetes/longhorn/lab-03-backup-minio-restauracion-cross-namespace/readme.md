# Lab 03 — Backup a MinIO y restauración cross-namespace

**Objetivo**: configurar MinIO como BackupTarget, hacer backup de un volumen y restaurarlo en un namespace diferente.

## Paso 1 — Desplegar MinIO en el cluster

```bash
kubectl create namespace minio

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pvc
  namespace: minio
spec:
  storageClassName: longhorn
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 2Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio
  namespace: minio
spec:
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
      - name: minio
        image: minio/minio:latest
        args: ["server", "/data", "--console-address", ":9001"]
        env:
        - name: MINIO_ROOT_USER
          value: "minioadmin"
        - name: MINIO_ROOT_PASSWORD
          value: "minioadmin"
        ports:
        - containerPort: 9000
        - containerPort: 9001
        volumeMounts:
        - mountPath: /data
          name: storage
      volumes:
      - name: storage
        persistentVolumeClaim:
          claimName: minio-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: minio
  namespace: minio
spec:
  selector:
    app: minio
  ports:
  - name: api
    port: 9000
    targetPort: 9000
  - name: console
    port: 9001
    targetPort: 9001
EOF

kubectl -n minio rollout status deploy/minio
```

## Paso 2 — Crear bucket en MinIO

```bash
# Port-forward a la consola de MinIO
kubectl -n minio port-forward svc/minio 9001:9001 &

# Instalar cliente mc
curl -fsSL https://dl.min.io/client/mc/release/linux-amd64/mc \
  -o /usr/local/bin/mc
sudo chmod +x /usr/local/bin/mc

# Configurar cliente y crear bucket
mc alias set local http://localhost:9000 minioadmin minioadmin
mc mb local/longhorn-backups
mc ls local/
```

## Paso 3 — Crear Secret con credenciales para Longhorn

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: minio-secret
  namespace: longhorn-system
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: minioadmin
  AWS_SECRET_ACCESS_KEY: minioadmin
  AWS_ENDPOINTS: http://minio.minio.svc.cluster.local:9000
  AWS_CERT: ""
EOF
```

## Paso 4 — Configurar BackupTarget en Longhorn

```bash
# Obtener IP del servicio MinIO
MINIO_IP=$(kubectl -n minio get svc minio -o jsonpath='{.spec.clusterIP}')

# Configurar el backup target
kubectl -n longhorn-system patch settings.longhorn.io backup-target \
  --type merge \
  -p '{"spec":{"value":"s3://longhorn-backups@us-east-1/"}}'

kubectl -n longhorn-system patch settings.longhorn.io backup-target-credential-secret \
  --type merge \
  -p '{"spec":{"value":"minio-secret"}}'

# Verificar en la UI: Settings > General > Backup Target
# Debe mostrar: s3://longhorn-backups@us-east-1/
```

## Paso 5 — Crear volumen con datos y hacer backup

```bash
kubectl create namespace app-prod

cat <<EOF | kubectl apply -n app-prod -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  storageClassName: longhorn
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do sleep 3600; done"]
    volumeMounts:
    - mountPath: /data
      name: vol
  volumes:
  - name: vol
    persistentVolumeClaim:
      claimName: app-pvc
EOF

kubectl -n app-prod wait pod/app-pod --for=condition=Ready --timeout=60s

# Escribir datos
kubectl -n app-prod exec app-pod -- sh -c "
  echo 'Base de datos de producción - v1.0' > /data/db.txt
  date >> /data/db.txt
  for i in \$(seq 1 10); do echo \"registro \$i\" >> /data/db.txt; done
  cat /data/db.txt
"
```

## Paso 6 — Ejecutar backup

```bash
VOLUME_NAME=$(kubectl -n app-prod get pvc app-pvc -o jsonpath='{.spec.volumeName}')

# Crear backup via CRD
cat <<EOF | kubectl apply -f -
apiVersion: longhorn.io/v1beta2
kind: Backup
metadata:
  name: backup-app-v1
  namespace: longhorn-system
spec:
  snapshotName: ""
  volume: ${VOLUME_NAME}
EOF

# Monitorear el backup
kubectl -n longhorn-system get backups -w
# Esperar estado: Completed
```

## Paso 7 — Restaurar en namespace diferente

```bash
kubectl create namespace app-restore

# Desde la UI de Longhorn:
# Backup > seleccionar backup-app-v1 > "Restore Latest Backup"
# Nombre del nuevo volumen: restored-volume
# Namespace destino: app-restore

# Alternativamente via CRD:
BACKUP_URL=$(kubectl -n longhorn-system get backups backup-app-v1 \
  -o jsonpath='{.status.url}')

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: restored-pvc
  namespace: app-restore
  annotations:
    longhorn.io/volume-scheduling-error: ""
spec:
  storageClassName: longhorn
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 1Gi
  dataSource:
    name: backup-app-v1
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
EOF

# Verificar datos restaurados
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: restore-pod
  namespace: app-restore
spec:
  containers:
  - name: reader
    image: busybox:1.36
    command: ["sh", "-c", "while true; do sleep 3600; done"]
    volumeMounts:
    - mountPath: /data
      name: vol
  volumes:
  - name: vol
    persistentVolumeClaim:
      claimName: restored-pvc
EOF

kubectl -n app-restore wait pod/restore-pod --for=condition=Ready --timeout=90s
kubectl -n app-restore exec restore-pod -- cat /data/db.txt
```

## Limpieza del lab

```bash
kubectl delete namespace app-prod app-restore minio
kubectl -n longhorn-system delete backup backup-app-v1
```
