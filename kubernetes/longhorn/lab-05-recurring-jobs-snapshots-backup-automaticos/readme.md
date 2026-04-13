# Lab 05 — Recurring jobs: snapshots y backups automáticos

**Objetivo**: configurar jobs periódicos de snapshot y backup con política de retención.

## Paso 1 — Crear volumen de trabajo

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lab05-pvc
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
  name: lab05-pod
spec:
  containers:
  - name: app
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      i=0
      while true; do
        echo "entrada-\$i: \$(date)" >> /data/log.txt
        i=\$((i+1))
        sleep 30
      done
    volumeMounts:
    - mountPath: /data
      name: vol
  volumes:
  - name: vol
    persistentVolumeClaim:
      claimName: lab05-pvc
EOF

kubectl wait pod/lab05-pod --for=condition=Ready --timeout=60s
```

## Paso 2 — Crear RecurringJob de snapshot cada 2 minutos

```bash
cat <<EOF | kubectl apply -f -
apiVersion: longhorn.io/v1beta2
kind: RecurringJob
metadata:
  name: snap-cada-2min
  namespace: longhorn-system
spec:
  cron: "*/2 * * * *"
  task: snapshot
  retain: 5
  concurrency: 1
  labels: {}
EOF

kubectl -n longhorn-system get recurringjobs
```

## Paso 3 — Asociar el RecurringJob al volumen

```bash
VOLUME_NAME=$(kubectl get pvc lab05-pvc -o jsonpath='{.spec.volumeName}')

# Etiquetar el volumen para que el job lo tome
kubectl -n longhorn-system patch volumes.longhorn.io ${VOLUME_NAME} \
  --type merge \
  -p '{"spec":{"recurringJobSelector":[{"name":"snap-cada-2min","isGroup":false}]}}'

# Alternativa desde la UI:
# Volume > seleccionar volumen > Edit > Recurring Jobs > agregar snap-cada-2min
```

## Paso 4 — Observar snapshots automáticos

```bash
# Esperar 4-6 minutos y verificar snapshots creados
kubectl -n longhorn-system get snapshots | grep ${VOLUME_NAME}

# Ver el historial completo en la UI
# Volume > volumen > pestaña Snapshots
# Deben aparecer snapshots con prefijo "snap-cada-2min"
```

## Paso 5 — Crear RecurringJob de backup diario con retención de 7

```bash
cat <<EOF | kubectl apply -f -
apiVersion: longhorn.io/v1beta2
kind: RecurringJob
metadata:
  name: backup-diario
  namespace: longhorn-system
spec:
  cron: "0 2 * * *"
  task: backup
  retain: 7
  concurrency: 1
  labels: {}
EOF

# Para probar inmediatamente sin esperar la medianoche,
# crear un backup manual
cat <<EOF | kubectl apply -f -
apiVersion: longhorn.io/v1beta2
kind: Backup
metadata:
  name: backup-lab05-manual
  namespace: longhorn-system
spec:
  volume: ${VOLUME_NAME}
EOF

kubectl -n longhorn-system get backups -w
```

## Limpieza del lab

```bash
kubectl delete pod lab05-pod
kubectl delete pvc lab05-pvc
kubectl -n longhorn-system delete recurringjob snap-cada-2min backup-diario
kubectl -n longhorn-system delete backup backup-lab05-manual
```
