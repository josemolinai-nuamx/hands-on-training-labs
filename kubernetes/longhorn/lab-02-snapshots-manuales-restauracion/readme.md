# Lab 02 — Snapshots manuales y restauración

**Objetivo**: crear un snapshot de un volumen, corromper los datos y restaurar desde el snapshot.

## Paso 1 — Preparar volumen con datos

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lab02-pvc
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
  name: lab02-pod
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
      claimName: lab02-pvc
EOF

kubectl wait pod/lab02-pod --for=condition=Ready --timeout=60s

# Escribir datos originales
kubectl exec lab02-pod -- sh -c "
  echo 'VERSION: v1 - datos originales' > /data/app.txt
  echo 'registro 1' >> /data/app.txt
  echo 'registro 2' >> /data/app.txt
  cat /data/app.txt
"
```

## Paso 2 — Obtener el nombre del volumen Longhorn

```bash
# El volumen Longhorn tiene el mismo nombre que el PV
VOLUME_NAME=$(kubectl get pvc lab02-pvc -o jsonpath='{.spec.volumeName}')
echo "Volumen: $VOLUME_NAME"
```

## Paso 3 — Crear snapshot desde la UI

```
1. Abrir http://localhost:8888
2. Ir a Volume > buscar el volumen $VOLUME_NAME
3. Hacer clic en el volumen > pestaña Snapshots
4. Clic en "Take Snapshot"
5. Anotar el nombre del snapshot creado (snapshot-XXXXXXXXX)
```

## Paso 4 — Crear snapshot via kubectl (recurso CRD)

```bash
cat <<EOF | kubectl apply -f -
apiVersion: longhorn.io/v1beta2
kind: Snapshot
metadata:
  name: snap-lab02-v1
  namespace: longhorn-system
spec:
  volume: ${VOLUME_NAME}
EOF

# Verificar snapshot creado
kubectl -n longhorn-system get snapshots
kubectl -n longhorn-system describe snapshot snap-lab02-v1
```

## Paso 5 — Corromper los datos

```bash
kubectl exec lab02-pod -- sh -c "
  echo 'DATOS CORROMPIDOS - accidente' > /data/app.txt
  echo 'todo perdido' >> /data/app.txt
  cat /data/app.txt
"
```

## Paso 6 — Restaurar desde snapshot (via UI)

```
1. Abrir http://localhost:8888
2. Ir al volumen lab02-pvc
3. Detener el Pod primero (requiere que el volumen esté desconectado)
```

```bash
# Detener el pod para desmontar el volumen
kubectl delete pod lab02-pod

# Desde la UI de Longhorn:
# Volume > seleccionar volumen > Snapshots > 
# buscar snap-lab02-v1 > botón "Revert"

# Recrear el pod después de la restauración
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: lab02-pod
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
      claimName: lab02-pvc
EOF

kubectl wait pod/lab02-pod --for=condition=Ready --timeout=60s

# Verificar restauración
kubectl exec lab02-pod -- cat /data/app.txt
# Debe mostrar: VERSION: v1 - datos originales
```

## Limpieza del lab

```bash
kubectl delete pod lab02-pod
kubectl delete pvc lab02-pvc
kubectl -n longhorn-system delete snapshot snap-lab02-v1
```