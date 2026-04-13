# Lab 07 — Monitoreo con métricas de Longhorn

**Objetivo**: exponer métricas de Longhorn y consultarlas con kubectl y scripts básicos.

## Paso 1 — Verificar endpoint de métricas

```bash
# Longhorn expone métricas Prometheus en el puerto 9500 del manager
MANAGER_POD=$(kubectl -n longhorn-system get pods \
  -l app=longhorn-manager -o name | head -1)

kubectl -n longhorn-system exec $MANAGER_POD -- \
  wget -qO- http://localhost:9500/metrics | head -40
```

## Paso 2 — Script de monitoreo básico

```bash
cat <<'EOF' > /usr/local/bin/longhorn-status
#!/bin/bash
echo "===== LONGHORN STATUS ====="
echo ""
echo "--- Nodos ---"
kubectl -n longhorn-system get nodes.longhorn.io \
  -o custom-columns='NODO:.metadata.name,ESTADO:.status.conditions[-1].type,DISCOS:.status.diskStatus'

echo ""
echo "--- Volúmenes ---"
kubectl -n longhorn-system get volumes.longhorn.io \
  -o custom-columns='NOMBRE:.metadata.name,ESTADO:.status.state,SALUD:.status.conditions[-1].type,TAMAÑO:.spec.size,REPLICAS:.spec.numberOfReplicas'

echo ""
echo "--- Snapshots recientes ---"
kubectl -n longhorn-system get snapshots \
  -o custom-columns='NOMBRE:.metadata.name,VOLUMEN:.spec.volume,CREADO:.metadata.creationTimestamp' \
  --sort-by='.metadata.creationTimestamp' | tail -10

echo ""
echo "--- Backups ---"
kubectl -n longhorn-system get backups \
  -o custom-columns='NOMBRE:.metadata.name,ESTADO:.status.state,VOLUMEN:.status.volumeName' \
  2>/dev/null || echo "(sin backups configurados)"

echo ""
echo "--- Uso de disco en nodo ---"
kubectl -n longhorn-system get nodes.longhorn.io \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{range .status.diskStatus.*}{.storageAvailable}{" disponible / "}{.storageMaximum}{" total\n"}{end}{end}'
EOF

chmod +x /usr/local/bin/longhorn-status
longhorn-status
```

## Paso 3 — Instalar Prometheus + Grafana (opcional, requiere ~500 MB RAM extra)

```bash
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts
helm repo update

# Instalación mínima
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.resources.requests.memory=256Mi \
  --set prometheus.prometheusSpec.resources.requests.cpu=100m \
  --set grafana.resources.requests.memory=128Mi \
  --set alertmanager.enabled=false \
  --set nodeExporter.enabled=false \
  --set kubeStateMetrics.enabled=true

# Agregar ServiceMonitor para Longhorn
cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: longhorn-prometheus
  namespace: monitoring
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app: longhorn-manager
  namespaceSelector:
    matchNames:
      - longhorn-system
  endpoints:
  - port: manager
    path: /metrics
EOF

# Acceder a Grafana
kubectl -n monitoring port-forward svc/prometheus-grafana 3000:80 &
# http://localhost:3000
# usuario: admin / password: prom-operator
```