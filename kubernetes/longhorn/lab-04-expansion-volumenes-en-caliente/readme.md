# Lab 04 — Expansión de volumen en caliente

**Objetivo**: expandir un PVC sin downtime mientras la aplicación sigue corriendo.

## Paso 1 — Crear volumen pequeño

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lab04-pvc
spec:
  storageClassName: longhorn
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 512Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: lab04-pod
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do df -h /data; sleep 10; done"]
    volumeMounts:
    - mountPath: /data
      name: vol
  volumes:
  - name: vol
    persistentVolumeClaim:
      claimName: lab04-pvc
EOF

kubectl wait pod/lab04-pod --for=condition=Ready --timeout=60s

# Ver tamaño inicial
kubectl exec lab04-pod -- df -h /data
# Filesystem      Size  Used Avail  Use% Mounted on
# /dev/longhorn   488M   24K  452M   1%  /data
```

## Paso 2 — Expandir el PVC en caliente

```bash
# Expandir de 512Mi a 2Gi sin detener el pod
kubectl patch pvc lab04-pvc \
  --type merge \
  -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'

# Monitorear la expansión
kubectl get pvc lab04-pvc -w
# STATUS cambia a: Resizing > FileSystemResizePending > Bound

# Verificar en el pod (puede tardar 30-60 seg)
kubectl exec lab04-pod -- df -h /data
# Filesystem      Size  Used Avail  Use% Mounted on
# /dev/longhorn   2.0G   28K  1.9G   1%  /data
```

## Paso 3 — Verificar en la UI de Longhorn

```
1. Abrir http://localhost:8888
2. Ir a Volume > seleccionar el volumen de lab04-pvc
3. El tamaño debe mostrar 2 GB
4. El estado debe ser Healthy
```

## Limpieza del lab

```bash
kubectl delete pod lab04-pod
kubectl delete pvc lab04-pvc
```