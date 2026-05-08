#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================
# Instalación de kube-prometheus-stack en k3d / k3s
# Ubuntu 24 - VM 4 CPU / 8 GB RAM
#
# Componentes incluidos:
# - Prometheus Operator
# - Prometheus recolectando métricas
# - Grafana con datasource Prometheus
# - kube-state-metrics
# - node-exporter
# - cAdvisor vía kubelet metrics
#
# Chart:
# - prometheus-community/kube-prometheus-stack
# ============================================================

NAMESPACE="monitoring"
RELEASE_NAME="kube-prometheus-stack"
CHART_REPO_NAME="prometheus-community"
CHART_REPO_URL="https://prometheus-community.github.io/helm-charts"

# Última versión verificada al 2026-05-08.
# Puedes dejarlo vacío para instalar la última disponible desde el repo Helm.
CHART_VERSION="${CHART_VERSION:-84.5.0}"

VALUES_FILE="/tmp/kube-prometheus-stack-k3d-values.yaml"

echo "==> Validando herramientas requeridas..."

if ! command -v kubectl >/dev/null 2>&1; then
  echo "ERROR: kubectl no está instalado o no está en PATH."
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "==> Helm no encontrado. Instalando Helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo "==> Validando acceso al cluster Kubernetes..."

if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "ERROR: kubectl no puede acceder al cluster."
  echo "Verifica tu contexto con:"
  echo "  kubectl config current-context"
  echo "  kubectl get nodes"
  exit 1
fi

echo "==> Contexto actual:"
kubectl config current-context

echo "==> Nodos disponibles:"
kubectl get nodes -o wide

echo "==> Creando namespace ${NAMESPACE}..."
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

echo "==> Agregando repositorio Helm ${CHART_REPO_NAME}..."
helm repo add "${CHART_REPO_NAME}" "${CHART_REPO_URL}" >/dev/null 2>&1 || true
helm repo update

echo "==> Generando archivo de valores para ambiente k3d/k3s..."

cat > "${VALUES_FILE}" <<'EOF'
# ============================================================
# Valores optimizados para laboratorio k3d / k3s
# VM: 4 CPU / 8 GB RAM
# ============================================================

fullnameOverride: kube-prometheus-stack

# ------------------------------------------------------------
# CRDs
# ------------------------------------------------------------
crds:
  enabled: true

# ------------------------------------------------------------
# Prometheus Operator
# ------------------------------------------------------------
prometheusOperator:
  enabled: true

  admissionWebhooks:
    enabled: true
    patch:
      enabled: true

  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi

# ------------------------------------------------------------
# Prometheus
# ------------------------------------------------------------
prometheus:
  enabled: true

  service:
    type: ClusterIP

  prometheusSpec:
    replicas: 1

    # Retención razonable para laboratorio local.
    retention: 15d
    retentionSize: 8GB

    # Intervalos adecuados para capacitación/laboratorio.
    scrapeInterval: 30s
    evaluationInterval: 30s

    # Recursos ajustados para VM pequeña.
    resources:
      requests:
        cpu: 300m
        memory: 1Gi
      limits:
        cpu: 1500m
        memory: 3Gi

    # Persistencia desactivada por defecto para evitar dependencia de StorageClass.
    # Si tu k3d tiene StorageClass funcional, puedes habilitar storageSpec.
    storageSpec: {}

    # Permite descubrir ServiceMonitor/PodMonitor en todos los namespaces.
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    ruleSelectorNilUsesHelmValues: false
    probeSelectorNilUsesHelmValues: false

    serviceMonitorNamespaceSelector: {}
    podMonitorNamespaceSelector: {}
    ruleNamespaceSelector: {}
    probeNamespaceSelector: {}

# ------------------------------------------------------------
# Alertmanager
# ------------------------------------------------------------
alertmanager:
  enabled: true

  service:
    type: ClusterIP

  alertmanagerSpec:
    replicas: 1
    retention: 120h
    storage: {}

    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 300m
        memory: 512Mi

# ------------------------------------------------------------
# Grafana
# ------------------------------------------------------------
grafana:
  enabled: true

  adminUser: admin
  adminPassword: admin

  service:
    type: ClusterIP

  defaultDashboardsEnabled: true
  defaultDashboardsTimezone: browser

  # Datasource Prometheus queda configurado automáticamente por el chart.
  sidecar:
    dashboards:
      enabled: true
      searchNamespace: ALL

    datasources:
      enabled: true
      defaultDatasourceEnabled: true

  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 700m
      memory: 768Mi

  persistence:
    enabled: false

# ------------------------------------------------------------
# kube-state-metrics
# ------------------------------------------------------------
kubeStateMetrics:
  enabled: true

kube-state-metrics:
  resources:
    requests:
      cpu: 50m
      memory: 128Mi
    limits:
      cpu: 300m
      memory: 512Mi

# ------------------------------------------------------------
# node-exporter
# ------------------------------------------------------------
nodeExporter:
  enabled: true

prometheus-node-exporter:
  hostRootFsMount:
    enabled: true

  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 250m
      memory: 256Mi

# ------------------------------------------------------------
# kubelet / cAdvisor
# ------------------------------------------------------------
# En Kubernetes, las métricas de cAdvisor normalmente se exponen
# a través del kubelet. kube-prometheus-stack crea los ServiceMonitor
# necesarios para recolectarlas.
kubelet:
  enabled: true

  serviceMonitor:
    enabled: true

    # cAdvisor metrics.
    cAdvisor: true

    # Probes metrics.
    probes: true

    # Resource metrics.
    resource: true

# ------------------------------------------------------------
# Componentes particulares de k3s/k3d
# ------------------------------------------------------------
# En k3s/k3d, scheduler, controller-manager y etcd no siempre están
# expuestos como componentes independientes scrapeables igual que en
# clusters kubeadm. Para evitar targets DOWN falsos, se deshabilitan.
kubeEtcd:
  enabled: false

kubeControllerManager:
  enabled: false

kubeScheduler:
  enabled: false

# kube-proxy puede no existir como DaemonSet tradicional en k3s,
# dependiendo de la configuración del cluster.
kubeProxy:
  enabled: false

# ------------------------------------------------------------
# CoreDNS
# ------------------------------------------------------------
coreDns:
  enabled: true

# ------------------------------------------------------------
# API Server
# ------------------------------------------------------------
kubeApiServer:
  enabled: true

# ------------------------------------------------------------
# Reglas y dashboards por defecto
# ------------------------------------------------------------
defaultRules:
  create: true

  rules:
    alertmanager: true
    etcd: false
    configReloaders: true
    general: true
    k8sContainerCpuUsageSecondsTotal: true
    k8sContainerMemoryCache: true
    k8sContainerMemoryRss: true
    k8sContainerMemorySwap: true
    k8sContainerResource: true
    k8sContainerMemoryWorkingSetBytes: true
    k8sPodOwner: true
    kubeApiserverAvailability: true
    kubeApiserverBurnrate: true
    kubeApiserverHistogram: true
    kubeApiserverSlos: true
    kubeControllerManager: false
    kubelet: true
    kubeProxy: false
    kubePrometheusGeneral: true
    kubePrometheusNodeRecording: true
    kubernetesApps: true
    kubernetesResources: true
    kubernetesStorage: true
    kubernetesSystem: true
    kubeSchedulerAlerting: false
    kubeSchedulerRecording: false
    kubeStateMetrics: true
    network: true
    node: true
    nodeExporterAlerting: true
    nodeExporterRecording: true
    prometheus: true
    prometheusOperator: true

EOF

echo "==> Instalando/actualizando ${RELEASE_NAME}..."

if [[ -n "${CHART_VERSION}" ]]; then
  helm upgrade --install "${RELEASE_NAME}" "${CHART_REPO_NAME}/kube-prometheus-stack" \
    --namespace "${NAMESPACE}" \
    --version "${CHART_VERSION}" \
    --values "${VALUES_FILE}" \
    --wait \
    --timeout 15m
else
  helm upgrade --install "${RELEASE_NAME}" "${CHART_REPO_NAME}/kube-prometheus-stack" \
    --namespace "${NAMESPACE}" \
    --values "${VALUES_FILE}" \
    --wait \
    --timeout 15m
fi

echo "==> Esperando despliegues principales..."

kubectl -n "${NAMESPACE}" rollout status deployment/kube-prometheus-stack-operator --timeout=180s || true
kubectl -n "${NAMESPACE}" rollout status deployment/kube-prometheus-stack-grafana --timeout=180s || true
kubectl -n "${NAMESPACE}" rollout status deployment/kube-prometheus-stack-kube-state-metrics --timeout=180s || true

echo "==> Estado de pods en namespace ${NAMESPACE}:"
kubectl -n "${NAMESPACE}" get pods -o wide

echo
echo "==> Services instalados:"
kubectl -n "${NAMESPACE}" get svc

echo
echo "==> ServiceMonitors instalados:"
kubectl -n "${NAMESPACE}" get servicemonitor

echo
echo "==> Validación rápida de componentes esperados..."

echo "- Prometheus:"
kubectl -n "${NAMESPACE}" get prometheus

echo "- Alertmanager:"
kubectl -n "${NAMESPACE}" get alertmanager

echo "- Grafana:"
kubectl -n "${NAMESPACE}" get deployment kube-prometheus-stack-grafana

echo "- kube-state-metrics:"
kubectl -n "${NAMESPACE}" get deployment kube-prometheus-stack-kube-state-metrics

echo "- node-exporter:"
kubectl -n "${NAMESPACE}" get daemonset kube-prometheus-stack-prometheus-node-exporter

echo
echo "============================================================"
echo "Instalación finalizada."
echo "============================================================"
echo
echo "Acceso a Grafana:"
echo "  kubectl -n ${NAMESPACE} port-forward svc/kube-prometheus-stack-grafana 3000:80"
echo
echo "  URL:      http://localhost:3000"
echo "  Usuario: admin"
echo "  Clave:   admin"
echo
echo "Acceso a Prometheus:"
echo "  kubectl -n ${NAMESPACE} port-forward svc/kube-prometheus-stack-prometheus 9090:9090"
echo
echo "  URL: http://localhost:9090"
echo
echo "Acceso a Alertmanager:"
echo "  kubectl -n ${NAMESPACE} port-forward svc/kube-prometheus-stack-alertmanager 9093:9093"
echo
echo "  URL: http://localhost:9093"
echo
echo "Archivo de valores usado:"
echo "  ${VALUES_FILE}"
echo
echo "Para revisar targets en Prometheus:"
echo "  http://localhost:9090/targets"
echo
echo "Consultas PromQL básicas de validación:"
echo "  up"
echo "  kube_node_info"
echo "  kube_pod_info"
echo "  node_cpu_seconds_total"
echo "  container_cpu_usage_seconds_total"
echo "  container_memory_working_set_bytes"
echo
