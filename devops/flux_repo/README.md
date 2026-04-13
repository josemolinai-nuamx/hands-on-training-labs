# 📦 Repositorio: hands-on-training-labs

## 🧭 Descripción General

Este repositorio contiene la infraestructura declarativa y la configuración de despliegues automatizados gestionados mediante **FluxCD**.  
Su propósito es centralizar la definición de infraestructura, aplicaciones y entornos (dev, staging, producción), facilitando la observabilidad, trazabilidad y versionamiento completo del estado del clúster Kubernetes.

---

## 🧩 Estructura del Repositorio

```text
```
├── 📁 bases
│   ├── 📁 apps
│   │   └── 📝 Readme.md
│   ├── 📁 infrastructure
│   │   ├── 📁 nginx-ingress
│   │   │   ├── ⚙️ kustomization.yaml
│   │   │   └── ⚙️ namespace.yaml
│   │   ├── 📁 observabilidad
│   │   │   ├── 📁 dashboards
│   │   │   │   ├── ⚙️ container-log.yaml
│   │   │   │   ├── ⚙️ datasources.yaml
│   │   │   │   └── ⚙️ pod-failure.yaml
│   │   │   ├── 📁 fluentd-loki
│   │   │   │   ├── ⚙️ clusterrolebinding.yaml
│   │   │   │   ├── ⚙️ config.yaml
│   │   │   │   ├── ⚙️ daemonset.yaml
│   │   │   │   ├── ⚙️ fluentd-clusterrole.yaml
│   │   │   │   ├── ⚙️ kustomization.yaml
│   │   │   │   └── ⚙️ serviceaccount.yaml
│   │   │   ├── 📁 loki
│   │   │   │   ├── ⚙️ config-yaml.yaml
│   │   │   │   ├── ⚙️ deployment.yaml
│   │   │   │   ├── ⚙️ kustomization.yaml
│   │   │   │   └── ⚙️ service.yaml
│   │   │   ├── 📝 README.md
│   │   │   ├── ⚙️ kustomization.yaml
│   │   │   ├── ⚙️ loki-config.yaml
│   │   │   ├── ⚙️ namespace.yaml
│   │   │   └── ⚙️ release.yaml
│   │   ├── 📁 reposources
│   │   │   ├── 📝 README.md
│   │   │   ├── ⚙️ actions-runner-controller.yaml
│   │   │   ├── ⚙️ appscode.yaml
│   │   │   ├── ⚙️ bitnami.yaml
│   │   │   ├── ⚙️ cloudnative-pg.yaml
│   │   │   ├── ⚙️ external-secrets.yaml
│   │   │   ├── ⚙️ grafana.yaml
│   │   │   ├── ⚙️ harbor.yaml
│   │   │   ├── ⚙️ hashicorp.yaml
│   │   │   ├── ⚙️ ingress-nginx.yaml
│   │   │   ├── ⚙️ jetstack.yaml
│   │   │   ├── ⚙️ jfrog.yaml
│   │   │   ├── ⚙️ kustomization.yaml
│   │   │   └── ⚙️ prometheus-community.yaml
│   │   └── 📝 README.md
│   └── 📝 README.md
├── 📁 overlays
│   ├── 📁 dev
│   │   ├── 📁 apps
│   │   │   └── 📝 Readme.md
│   │   ├── 📁 flux-system
│   │   │   ├── ⚙️ gotk-components.yaml
│   │   │   ├── ⚙️ gotk-sync.yaml
│   │   │   └── ⚙️ kustomization.yaml
│   │   ├── 📁 infrastructure
│   │   │   ├── 📁 nginx-ingress
│   │   │   │   └── ⚙️ kustomization.yaml
│   │   │   ├── 📁 observabilidad
│   │   │   │   ├── 📝 README.md
│   │   │   │   └── ⚙️ kustomization.yaml
│   │   │   ├── 📁 reposources
│   │   │   │   ├── 📝 README.md
│   │   │   │   └── ⚙️ kustomization.yaml
│   │   │   └── 📝 Readme.md
│   │   ├── 📁 kustoms
│   │   │   ├── ⚙️ nginx-ingress-kustomization.yaml
│   │   │   ├── ⚙️ observabilidad-kustomization.yaml
│   │   │   └── ⚙️ reposources-kustomization.yaml
│   │   ├── 📝 README.md
│   │   └── ⚙️ kustomization.yaml
│   ├── 📁 produccion
│   │   ├── 📁 apps
│   │   ├── 📁 infrastructure
│   │   └── 📁 kustoms
│   ├── 📁 staging
│   └── 📝 README.md
├── 📁 pipelines
├── 📁 utils
│   ├── 📁 pods_falla_test
│   │   ├── ⚙️ kustomization.yaml
│   │   ├── ⚙️ namespace.yaml
│   │   ├── ⚙️ test-crashloop-pod.yaml
│   │   ├── ⚙️ test-error-logs-pod.yaml
│   │   ├── ⚙️ test-failed-pod.yaml
│   │   ├── ⚙️ test-failing-deployment.yaml
│   │   ├── ⚙️ test-multi-container-pod.yaml
│   │   └── ⚙️ test-oom-pod.yaml
│   └── 📝 README.md
└── 📝 README.md
```
```
---

## ⚙️ Componentes Principales

### 🧱 Bases (`bases/`)
Contiene las definiciones genéricas reutilizables que sirven como plantillas para los overlays.  
Incluye:
- **`apps/`** → Definiciones base de aplicaciones comunes.
- **`infrastructure/`** → Servicios compartidos como Prometheus, Loki, Fluentd, Repositorios Helm, etc.

### 🧩 Overlays (`overlays/`)
Personalizaciones específicas por entorno (dev, staging, producción).  
Cada overlay aplica configuraciones sobre las bases para ajustar parámetros según el entorno, como recursos, namespaces, y valores de despliegue.

### 🌍 Env (`env/`)
Define la configuración específica que **FluxCD** utiliza para sincronizar los manifests con el clúster.  
Cada entorno contiene un subdirectorio `flux-system` con los manifiestos `gotk-components.yaml`, `gotk-sync.yaml`, y el `kustomization.yaml`.

### 🛠️ Utils (`utils/`)
Incluye herramientas auxiliares:

---

> ⚠️ **Nota:** Toda modificación en `bases/` o `overlays/` debe ser probada en `dev` antes de su promoción a `staging` o `producción`.

---