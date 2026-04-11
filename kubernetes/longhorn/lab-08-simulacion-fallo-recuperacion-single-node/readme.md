# Lab 08 — Simulación de fallo y recuperación (single-node)

**Objetivo**: simular la pérdida de acceso al disco y observar la recuperación de Longhorn.

> **Nota**: en single-node no se pueden simular fallos de nodo completos. Este lab simula fallos a nivel de volumen individual.

## Paso 1 — Crear volumen de prueba con datos importantes

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lab08-pvc
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
  name: lab08-app
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do date >> /data/log.txt; sleep 2; done"]
    volumeMounts:
    - mountPath: /data
      name: vol
  volumes:
  - name: vol
    persistentVolumeClaim:
      claimName: lab08-pvc
EOF

kubectl wait pod/lab08-app --for=condition=Ready --timeout=60s

# Dejar que escriba datos por 30 segundos
sleep 30
kubectl exec lab08-app -- wc -l /data/log.txt
```

## Paso 2 — Forzar un fallo de réplica manualmente

```bash
VOLUME_NAME=$(kubectl get pvc lab08-pvc -o jsonpath='{.spec.volumeName}')

# Listar réplicas del volumen
kubectl -n longhorn-system get replicas \
  --field-selector spec.volumeName=${VOLUME_NAME}

REPLICA_NAME=$(kubectl -n longhorn-system get replicas \
  --field-selector spec.volumeName=${VOLUME_NAME} \
  -o jsonpath='{.items[0].metadata.name}')

# Forzar fallo de la réplica
kubectl -n longhorn-system patch replicas.longhorn.io ${REPLICA_NAME} \
  --type merge \
  -p '{"spec":{"failedAt":"2024-01-01T00:00:00Z"}}'

# Observar el estado del volumen
kubectl -n longhorn-system get volumes.longhorn.io ${VOLUME_NAME} \
  -o jsonpath='{.status.state}{"\n"}{.status.conditions}'
```

## Paso 3 — Observar auto-recuperación

```bash
# Longhorn detecta la réplica fallida y la reconstruye
# Monitorear el proceso
watch -n2 "kubectl -n longhorn-system get replicas \
  --field-selector spec.volumeName=${VOLUME_NAME} \
  -o custom-columns='NOMBRE:.metadata.name,ESTADO:.status.currentState,FALLO:.spec.failedAt'"

# El pod debe seguir funcionando durante la recuperación
kubectl exec lab08-app -- tail -5 /data/log.txt
```

## Paso 4 — Verificar integridad de datos post-recuperación

```bash
# Contar líneas del log (no debe haber interrupciones grandes)
kubectl exec lab08-app -- wc -l /data/log.txt
kubectl exec lab08-app -- tail -10 /data/log.txt

# Estado final del volumen debe ser Healthy
kubectl -n longhorn-system get volumes.longhorn.io ${VOLUME_NAME} \
  -o jsonpath='{.status.state}'
# Degraded -> Healthy
```

## Limpieza del lab

```bash
kubectl delete pod lab08-app
kubectl delete pvc lab08-pvc
```