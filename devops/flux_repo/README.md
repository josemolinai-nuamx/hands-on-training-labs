# 📦 Repositorio: bcentral-poc-infra

## 🧭 Descripción General

Este repositorio contiene la infraestructura declarativa y la configuración de despliegues automatizados gestionados mediante **FluxCD**.  
Su propósito es centralizar la definición de infraestructura, aplicaciones y entornos (dev, staging, producción), facilitando la observabilidad, trazabilidad y versionamiento completo del estado del clúster Kubernetes.

---

## 🧩 Estructura del Repositorio

📁 flux_repo
├── 📁 bases
│   ├── 📁 apps
│   │   └── 📝 Readme.md
│   ├── 📁 infrastructure
│   │   ├── 📁 nginx-ingress
│   │   │   ├── ⚙️ kustomization.yaml
│   │   │   └── ⚙️ namespace.yaml
│   │   ├── 📁 postgresql
│   │   │   ├── ⚙️ kustomization.yaml
│   │   │   └── ⚙️ namespace.yaml
│   │   ├── 📁 prometheus
│   │   │   ├── 📁 dashboards
│   │   │   │   ├── ⚙️ container-log.yaml
│   │   │   │   └── ⚙️ datasources.yaml
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
│   │   │   │   ├── ⚙️ grafana-ingress-nginx.yaml
│   │   │   │   ├── ⚙️ grafana-ingress.yaml
│   │   │   │   ├── ⚙️ kustomization.yaml
│   │   │   │   ├── ⚙️ service.yaml
│   │   │   │   └── ⚙️ tls-secret.yaml
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
│   │   ├── 📁 infrastructure
│   │   │   ├── 📁 nginx-ingress
│   │   │   │   └── ⚙️ kustomization.yaml
│   │   │   ├── 📁 postgresql
│   │   │   │   └── ⚙️ kustomization.yaml
│   │   │   ├── 📁 prometheus
│   │   │   │   ├── 📝 README.md
│   │   │   │   └── ⚙️ kustomization.yaml
│   │   │   ├── 📁 reposources
│   │   │   │   ├── 📝 README.md
│   │   │   │   └── ⚙️ kustomization.yaml
│   │   │   └── 📝 Readme.md
│   │   ├── 📁 kustoms
│   │   │   ├── ⚙️ contour-kustomization.yaml
│   │   │   ├── ⚙️ nginx-ingress-kustomization.yaml
│   │   │   ├── ⚙️ postgresql-kustomization.yaml
│   │   │   ├── ⚙️ prometheus-kustomization.yaml
│   │   │   ├── ⚙️ reposources-kustomization.yaml
│   │   │   └── ⚙️ vault-kustomization.yaml
│   │   ├── 📝 README.md
│   │   └── ⚙️ kustomization.yaml
│   ├── 📁 produccion
│   │   ├── 📁 apps
│   │   ├── 📁 infraestructure
│   │   └── 📁 kustoms
│   ├── 📁 staging
│   └── 📝 README.md
├── 📁 pipelines
├── 📁 utils
│   └── 📝 README.md
└── 📝 README.md

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
- **`00-terraform/`** → Estructura IaC para la provisión automática de infraestructura en Azure (AKS, networking, backend de estado, etc.).
  - Contiene módulos reutilizables (`modules/aks`) y definiciones principales (`main.tf`, `variables.tf`, `outputs.tf`).

---

## 🚀 Flujo de Trabajo (GitOps + Terraform)

1. **Terraform** (ubicado en `utils/00-terraform/`) crea y configura los recursos de infraestructura base en Azure, incluyendo el clúster AKS y el almacenamiento del estado remoto.
2. **FluxCD** sincroniza automáticamente los manifests del repositorio con el clúster, aplicando las configuraciones definidas en `env/` y `overlays/`.
3. Las actualizaciones se gestionan mediante **Pull Requests** para mantener control y trazabilidad sobre los cambios en la infraestructura o aplicaciones.

---

## 🔐 Autenticación y Seguridad

- El acceso a los repositorios y despliegues está gestionado mediante tokens personales (PAT) de Azure DevOps.
- Las credenciales y secretos sensibles deben manejarse mediante **External Secrets** o **Vault**, nunca en texto plano.

---

## 📈 Monitoreo y Observabilidad

El módulo `bases/infrastructure/prometheus` implementa un stack de monitoreo que incluye:
- **Prometheus** para métricas.
- **Loki + Fluentd** para logs centralizados.
- **Grafana** (opcional, si se incluye en reposources) para visualización.

---

## 🧾 Referencias

- [GitOps-Despliegue de AKS](https://dev.azure.com/Bcentral-Arquitectura/ETAD/_wiki/wikis/ETAD.wiki/34/GitOps-Despliegue-de-AKS)
- [FluxCD Documentation](https://fluxcd.io/docs/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Kustomize](https://kubectl.docs.kubernetes.io/references/kustomize/)
- [Azure DevOps Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/)

---

> ⚠️ **Nota:** Toda modificación en `bases/` o `overlays/` debe ser probada en `dev` antes de su promoción a `staging` o `producción`.

