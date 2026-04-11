# Lab 06 — Volumen ReadWriteMany (RWX) compartido entre múltiples Pods

**Objetivo**: crear un volumen compartido accesible por varios Pods simultáneamente.

> **Nota**: RWX en Longhorn usa un share-manager basado en NFS. Requiere que `nfs-common` esté instalado en el host (ya incluido en los prerequisitos).

## Paso 1 — Verificar soporte RWX

```bash
# Verificar que el share-manager pod corre
kubectl -n longhorn-system get pods | grep share-manager

# Si no hay pods de share-manager, habilitar RWX
kubectl -n longhorn-system patch settings.longhorn.io \
  allow-volume-creation-with-degraded-availability \
  --type merge -p '{"spec":{"value":"true"}}'
```

## Paso 2 — Crear PVC con acceso RWX

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lab06-rwx-pvc
spec:
  storageClassName: longhorn
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
EOF

kubectl get pvc lab06-rwx-pvc -w
# Esperar STATUS: Bound
```

## Paso 3 — Desplegar múltiples Pods usando el mismo volumen

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab06-writers
spec:
  replicas: 3
  selector:
    matchLabels:
      app: lab06-writer
  template:
    metadata:
      labels:
        app: lab06-writer
    spec:
      containers:
      - name: writer
        image: busybox:1.36
        command:
        - sh
        - -c
        - |
          while true; do
            echo "\$(hostname): \$(date)" >> /shared/log.txt
            sleep 5
          done
        volumeMounts:
        - mountPath: /shared
          name: shared-vol
      volumes:
      - name: shared-vol
        persistentVolumeClaim:
          claimName: lab06-rwx-pvc
EOF

kubectl rollout status deploy/lab06-writers
```

## Paso 4 — Verificar escritura concurrente

```bash
# Los 3 pods deben estar escribiendo en el mismo archivo
kubectl get pods -l app=lab06-writer

# Leer el archivo desde cualquier pod
POD=$(kubectl get pods -l app=lab06-writer -o name | head -1)
kubectl exec $POD -- tail -20 /shared/log.txt

# Los 3 hostnames distintos deben aparecer entrelazados
# lab06-writers-xxx-aaa: Fri Apr ...
# lab06-writers-xxx-bbb: Fri Apr ...
# lab06-writers-xxx-ccc: Fri Apr ...
```

## Limpieza del lab

```bash
kubectl delete deploy lab06-writers
kubectl delete pvc lab06-rwx-pvc
```