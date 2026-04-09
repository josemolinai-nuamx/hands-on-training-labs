#!/usr/bin/env bash
set -Eeuo pipefail

readonly GO_VERSION="${GO_VERSION:-1.25.0}"
readonly NODE_MAJOR="${NODE_MAJOR:-22}"
readonly K3D_CLUSTER_NAME="${K3D_CLUSTER_NAME:-lab}"
readonly K3D_AGENTS="${K3D_AGENTS:-2}"
readonly INSTALL_DEMO_CLUSTER="${INSTALL_DEMO_CLUSTER:-true}"
readonly INSTALL_FLUX_CONTROLLERS="${INSTALL_FLUX_CONTROLLERS:-true}"
readonly BOOTSTRAP_FLUX_GIT="${BOOTSTRAP_FLUX_GIT:-false}"

readonly GIT_PROVIDER="${GIT_PROVIDER:-github}"
readonly GIT_OWNER="${GIT_OWNER:-}"
readonly GIT_REPO="${GIT_REPO:-gitops-lab}"
readonly GIT_BRANCH="${GIT_BRANCH:-main}"

export DEBIAN_FRONTEND=noninteractive

TARGET_USER=""
TARGET_HOME=""
ARCH=""

log() {
  echo
  echo "[$(date +'%F %T')] $*"
}

fail() {
  echo
  echo "ERROR: $*" >&2
  exit 1
}

require_root() {
  [[ "${EUID}" -eq 0 ]] || fail "Ejecuta este script con sudo o como root."
}

detect_target_user() {
  if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    TARGET_USER="${SUDO_USER}"
    TARGET_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"
  else
    TARGET_USER="root"
    TARGET_HOME="/root"
  fi
}

detect_arch() {
  ARCH="$(dpkg --print-architecture)"
}

os_checks() {
  source /etc/os-release
  [[ "${ID}" == "ubuntu" ]] || fail "Este script está diseñado para Ubuntu."
  [[ "${VERSION_ID}" =~ ^24\. ]] || log "Advertencia: probado en Ubuntu 24.x; detectado ${PRETTY_NAME}."
}

apt_base() {
  log "Instalando paquetes base..."
  apt-get update
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg \
    apt-transport-https \
    software-properties-common \
    lsb-release \
    git \
    vim \
    nano \
    jq \
    unzip \
    zip \
    tar \
    make \
    tmux \
    htop \
    tree \
    bash-completion \
    openssl \
    net-tools \
    iproute2 \
    iputils-ping \
    dnsutils \
    socat \
    conntrack
}

install_yq() {
  log "Instalando yq..."
  local yq_arch
  case "${ARCH}" in
    amd64) yq_arch="amd64" ;;
    arm64) yq_arch="arm64" ;;
    *) fail "Arquitectura no soportada para yq: ${ARCH}" ;;
  esac

  curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${yq_arch}" \
    -o /usr/local/bin/yq
  chmod +x /usr/local/bin/yq
}

install_docker() {
  log "Instalando Docker Engine..."
  apt-get remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc || true

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  local codename
  codename="$(. /etc/os-release && echo "${UBUNTU_CODENAME}")"

  cat > /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${codename} stable
EOF

  apt-get update
  apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

  systemctl enable docker
  systemctl restart docker

  usermod -aG docker "${TARGET_USER}" || true
}

install_kubectl() {
  log "Instalando kubectl..."
  local kubectl_arch version
  case "${ARCH}" in
    amd64) kubectl_arch="amd64" ;;
    arm64) kubectl_arch="arm64" ;;
    *) fail "Arquitectura no soportada para kubectl: ${ARCH}" ;;
  esac

  version="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
  curl -fsSL -o /usr/local/bin/kubectl \
    "https://dl.k8s.io/release/${version}/bin/linux/${kubectl_arch}/kubectl"
  chmod +x /usr/local/bin/kubectl
}

install_helm() {
  log "Instalando Helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
}

install_flux() {
  log "Instalando Flux CLI..."
  curl -fsSL https://fluxcd.io/install.sh | bash
  if [[ -x "${TARGET_HOME}/.local/bin/flux" && ! -x /usr/local/bin/flux ]]; then
    ln -sf "${TARGET_HOME}/.local/bin/flux" /usr/local/bin/flux
  fi
}

install_k3d() {
  log "Instalando k3d..."
  curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
}

install_k9s() {
  log "Instalando k9s..."
  wget https://github.com/derailed/k9s/releases/download/v0.50.18/k9s_linux_amd64.deb
  sudo dpkg -i k9s_linux_amd64.deb
}


install_go() {
  log "Instalando Go ${GO_VERSION}..."
  local go_arch tarball
  case "${ARCH}" in
    amd64) go_arch="amd64" ;;
    arm64) go_arch="arm64" ;;
    *) fail "Arquitectura no soportada para Go: ${ARCH}" ;;
  esac

  tarball="go${GO_VERSION}.linux-${go_arch}.tar.gz"

  rm -rf /usr/local/go
  curl -fsSL -o "/tmp/${tarball}" "https://go.dev/dl/${tarball}"
  tar -C /usr/local -xzf "/tmp/${tarball}"
  rm -f "/tmp/${tarball}"

  cat > /etc/profile.d/go.sh <<'EOF'
export PATH=/usr/local/go/bin:$PATH
EOF
  chmod 0644 /etc/profile.d/go.sh
  export PATH="/usr/local/go/bin:${PATH}"
}

install_nodejs() {
  log "Instalando Node.js ${NODE_MAJOR}.x..."
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

  cat > /etc/apt/sources.list.d/nodesource.list <<EOF
deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main
EOF

  apt-get update
  apt-get install -y nodejs
}

configure_sysctl() {
  log "Aplicando sysctl recomendados..."
  cat > /etc/sysctl.d/99-hands-on.conf <<'EOF'
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 1024
vm.max_map_count = 262144
EOF

  sysctl --system >/dev/null
}

configure_shell() {
  log "Configurando shell y completions..."
  mkdir -p "${TARGET_HOME}/.local/bin"
  touch "${TARGET_HOME}/.bashrc"

  grep -q 'source /etc/profile.d/go.sh' "${TARGET_HOME}/.bashrc" 2>/dev/null || \
    echo 'source /etc/profile.d/go.sh' >> "${TARGET_HOME}/.bashrc"

  grep -q 'bash_completion' "${TARGET_HOME}/.bashrc" 2>/dev/null || cat >> "${TARGET_HOME}/.bashrc" <<'EOF'

if [ -f /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
fi
EOF

  command -v kubectl >/dev/null 2>&1 && kubectl completion bash > /etc/bash_completion.d/kubectl || true
  command -v helm >/dev/null 2>&1 && helm completion bash > /etc/bash_completion.d/helm || true
  command -v flux >/dev/null 2>&1 && flux completion bash > /etc/bash_completion.d/flux || true
  command -v k3d >/dev/null 2>&1 && k3d completion bash > /etc/bash_completion.d/k3d || true

  chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/.local" "${TARGET_HOME}/.bashrc" || true
}

create_workspace() {
  log "Creando workspace..."
  mkdir -p "${TARGET_HOME}/hands-on"/{contracts,microservice,k8s,gitops-lab,scripts}
  chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/hands-on"
}

create_k3d_cluster() {
  [[ "${INSTALL_DEMO_CLUSTER}" == "true" ]] || return 0

  log "Creando cluster k3d '${K3D_CLUSTER_NAME}'..."
  su - "${TARGET_USER}" -c "
    export PATH=/usr/local/go/bin:\$PATH
    if ! k3d cluster list | awk 'NR>1 {print \$1}' | grep -qx '${K3D_CLUSTER_NAME}'; then
      k3d cluster create ${K3D_CLUSTER_NAME} \
        --image rancher/k3s:v1.33.1-k3s1 \
        --servers 1 \
        --agents ${K3D_AGENTS} \
        --wait \
        --k3s-arg '--disable=traefik@server:0' \
        --port '8080:80@loadbalancer' \
        --port '8443:443@loadbalancer'
    fi
  "
}

write_gitops_repo_files() {
  log "Creando repo GitOps local..."
  local repo="${TARGET_HOME}/hands-on/gitops-lab"

  mkdir -p "${repo}/apps/nginx-demo/templates"
  mkdir -p "${repo}/clusters/local"

  cat > "${repo}/README.md" <<'EOF'
# gitops-lab

Repositorio local de ejemplo para prácticas GitOps con Flux y Helm.
EOF

  cat > "${repo}/apps/nginx-demo/Chart.yaml" <<'EOF'
apiVersion: v2
name: nginx-demo
description: Helm chart de ejemplo para laboratorio
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF

  cat > "${repo}/apps/nginx-demo/values.yaml" <<'EOF'
replicaCount: 1

image:
  repository: nginx
  tag: "1.27"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
EOF

  cat > "${repo}/apps/nginx-demo/templates/deployment.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-demo
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: nginx-demo
  template:
    metadata:
      labels:
        app: nginx-demo
    spec:
      containers:
        - name: nginx
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: 80
EOF

  cat > "${repo}/apps/nginx-demo/templates/service.yaml" <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: nginx-demo
spec:
  type: {{ .Values.service.type }}
  selector:
    app: nginx-demo
  ports:
    - port: {{ .Values.service.port }}
      targetPort: 80
EOF

  cat > "${repo}/clusters/local/helmrelease-nginx-demo.yaml" <<'EOF'
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: podinfo
  namespace: flux-system
spec:
  interval: 10m
  url: https://stefanprodan.github.io/podinfo
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: podinfo
  namespace: default
spec:
  interval: 10m
  chart:
    spec:
      chart: podinfo
      version: "6.*"
      sourceRef:
        kind: HelmRepository
        name: podinfo
        namespace: flux-system
EOF

  cat > "${repo}/clusters/local/kustomization-local.yaml" <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - helmrelease-nginx-demo.yaml
EOF

  chown -R "${TARGET_USER}:${TARGET_USER}" "${repo}"

  su - "${TARGET_USER}" -c "
    cd '${repo}'
    if [ ! -d .git ]; then
      git init
      git checkout -b ${GIT_BRANCH}
      git config user.name 'Hands On Lab'
      git config user.email 'handson@example.local'
      git add .
      git commit -m 'Initial local GitOps lab'
    fi
  "
}

install_flux_controllers() {
  [[ "${INSTALL_FLUX_CONTROLLERS}" == "true" ]] || return 0

  log "Instalando controladores Flux en el cluster..."
  su - "${TARGET_USER}" -c "
    export PATH=/usr/local/go/bin:\$PATH
    kubectl config use-context k3d-${K3D_CLUSTER_NAME}
    flux check --pre || true
    flux install
    flux check
  "
}

bootstrap_flux_remote_if_requested() {
  [[ "${BOOTSTRAP_FLUX_GIT}" == "true" ]] || return 0

  [[ -n "${GIT_OWNER}" ]] || fail "BOOTSTRAP_FLUX_GIT=true requiere GIT_OWNER."
  log "Bootstrapping Flux a repo Git remoto..."

  if [[ "${GIT_PROVIDER}" == "github" ]]; then
    [[ -n "${GITHUB_TOKEN:-}" ]] || fail "Falta GITHUB_TOKEN."
    su - "${TARGET_USER}" -c "
      export PATH=/usr/local/go/bin:\$PATH
      export GITHUB_TOKEN='${GITHUB_TOKEN}'
      kubectl config use-context k3d-${K3D_CLUSTER_NAME}
      flux bootstrap github \
        --owner='${GIT_OWNER}' \
        --repository='${GIT_REPO}' \
        --branch='${GIT_BRANCH}' \
        --path='clusters/local' \
        --personal
    "
  elif [[ "${GIT_PROVIDER}" == "gitlab" ]]; then
    [[ -n "${GITLAB_TOKEN:-}" ]] || fail "Falta GITLAB_TOKEN."
    su - "${TARGET_USER}" -c "
      export PATH=/usr/local/go/bin:\$PATH
      export GITLAB_TOKEN='${GITLAB_TOKEN}'
      kubectl config use-context k3d-${K3D_CLUSTER_NAME}
      flux bootstrap gitlab \
        --owner='${GIT_OWNER}' \
        --repository='${GIT_REPO}' \
        --branch='${GIT_BRANCH}' \
        --path='clusters/local'
    "
  else
    fail "Proveedor Git no soportado: ${GIT_PROVIDER}"
  fi
}

write_k8s_demo_files() {
  log "Creando manifests Kubernetes demo..."
  local k8s="${TARGET_HOME}/hands-on/k8s"

  cat > "${k8s}/namespace-demo.yaml" <<'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: demo
EOF

  cat > "${k8s}/nginx-deployment.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-demo
  namespace: demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-demo
  template:
    metadata:
      labels:
        app: nginx-demo
    spec:
      containers:
        - name: nginx
          image: nginx:1.27
          ports:
            - containerPort: 80
EOF

  cat > "${k8s}/nginx-service.yaml" <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: nginx-demo
  namespace: demo
spec:
  selector:
    app: nginx-demo
  ports:
    - port: 80
      targetPort: 80
EOF

  chown -R "${TARGET_USER}:${TARGET_USER}" "${k8s}"
}

write_hardhat_project() {
  log "Creando proyecto Hardhat demo..."
  local project="${TARGET_HOME}/hands-on/contracts/helloworld"
  mkdir -p "${project}/contracts" "${project}/scripts"

  cat > "${project}/package.json" <<'EOF'
{
  "name": "helloworld-hardhat",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "hardhat compile",
    "test": "hardhat test"
  },
  "devDependencies": {
    "hardhat": "^3.0.0"
  }
}
EOF

  cat > "${project}/hardhat.config.js" <<'EOF'
export default {
  solidity: "0.8.28"
};
EOF

  cat > "${project}/contracts/HelloWorld.sol" <<'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract HelloWorld {
    string private message;

    constructor(string memory initialMessage) {
        message = initialMessage;
    }

    function setMessage(string memory newMessage) public {
        message = newMessage;
    }

    function getMessage() public view returns (string memory) {
        return message;
    }
}
EOF

  cat > "${project}/scripts/info.js" <<'EOF'
console.log("Proyecto Hardhat listo. Ejecuta:");
console.log("  npm install");
console.log("  npx hardhat compile");
EOF

  chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/hands-on/contracts"

  su - "${TARGET_USER}" -c "
    cd '${project}'
    npm install
  "
}

write_go_microservice() {
  log "Creando microservicio Go demo..."
  local app="${TARGET_HOME}/hands-on/microservice/go-api"
  mkdir -p "${app}"

  cat > "${app}/go.mod" <<'EOF'
module example.com/go-api

go 1.25.0
EOF

  cat > "${app}/main.go" <<'EOF'
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

type HealthResponse struct {
	Status  string `json:"status"`
	Service string `json:"service"`
}

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(HealthResponse{
			Status:  "ok",
			Service: "go-api",
		})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("listening on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, mux))
}
EOF

  cat > "${app}/Dockerfile" <<'EOF'
FROM golang:1.25 AS builder
WORKDIR /app
COPY go.mod ./
COPY main.go ./
ARG TARGETARCH=amd64
RUN CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -o go-api .

FROM gcr.io/distroless/static-debian12
WORKDIR /app
COPY --from=builder /app/go-api /app/go-api
EXPOSE 8080
ENTRYPOINT ["/app/go-api"]
EOF

  cat > "${app}/README.md" <<'EOF'
# go-api

Ejecutar local:
go run main.go

Probar:
curl http://localhost:8080/health

Construir imagen:
docker build -t go-api:dev .
EOF

  chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/hands-on/microservice"

  su - "${TARGET_USER}" -c "
    export PATH=/usr/local/go/bin:\$PATH
    cd '${app}'
    go fmt ./...
    go build ./...
  "
}

write_helper_scripts() {
  log "Creando scripts auxiliares..."
  local scripts="${TARGET_HOME}/hands-on/scripts"

  cat > "${scripts}/use-cluster.sh" <<EOF
#!/usr/bin/env bash
kubectl config use-context k3d-${K3D_CLUSTER_NAME}
kubectl get nodes -o wide
EOF

  cat > "${scripts}/deploy-demo.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
kubectl apply -f ~/hands-on/k8s/namespace-demo.yaml
kubectl apply -f ~/hands-on/k8s/nginx-deployment.yaml
kubectl apply -f ~/hands-on/k8s/nginx-service.yaml
kubectl -n demo get all
EOF

  chmod +x "${scripts}/use-cluster.sh" "${scripts}/deploy-demo.sh"
  chown -R "${TARGET_USER}:${TARGET_USER}" "${scripts}"
}

verify_installation() {
  log "Verificando instalación..."
  echo "---- versions ----"
  docker --version
  docker compose version
  kubectl version --client
  helm version
  flux --version
  k3d version
  k9s version
  go version
  node --version
  npm --version
  jq --version
  yq --version
  echo "------------------"

  log "Prueba Docker..."
  docker run --rm hello-world >/dev/null

  if [[ "${INSTALL_DEMO_CLUSTER}" == "true" ]]; then
    log "Estado del cluster..."
    su - "${TARGET_USER}" -c "
      kubectl config use-context k3d-${K3D_CLUSTER_NAME}
      kubectl get nodes -o wide
      kubectl get ns
    "
  fi
}

print_summary() {
  cat <<EOF

Provisionamiento v2 completado.

Contenido generado:
- ${TARGET_HOME}/hands-on/gitops-lab
- ${TARGET_HOME}/hands-on/contracts/helloworld
- ${TARGET_HOME}/hands-on/microservice/go-api
- ${TARGET_HOME}/hands-on/k8s
- ${TARGET_HOME}/hands-on/scripts

Pasos sugeridos:
1. Reingresar sesión para aplicar grupo docker al usuario ${TARGET_USER}
   o ejecutar temporalmente:
      newgrp docker

2. Seleccionar cluster:
      ~/hands-on/scripts/use-cluster.sh

3. Desplegar demo Kubernetes:
      ~/hands-on/scripts/deploy-demo.sh

4. Revisar proyecto Hardhat:
      cd ~/hands-on/contracts/helloworld
      npx hardhat compile

5. Ejecutar microservicio Go:
      cd ~/hands-on/microservice/go-api
      go run main.go

6. Si deseas bootstrap completo de Flux hacia Git remoto:
      export BOOTSTRAP_FLUX_GIT=true
      export GIT_PROVIDER=github
      export GIT_OWNER=tu_usuario_o_org
      export GIT_REPO=gitops-lab
      export GITHUB_TOKEN=xxxxx
      sudo -E ./bootstrap.sh

EOF
}

main() {
  require_root
  detect_target_user
  detect_arch
  os_checks
  apt_base
  install_yq
  install_docker
  install_kubectl
  install_helm
  install_flux
  install_k3d
  install_k9s
  install_go
  install_nodejs
  configure_sysctl
  configure_shell
  create_workspace
  create_k3d_cluster
  write_gitops_repo_files
  install_flux_controllers
  bootstrap_flux_remote_if_requested
  write_k8s_demo_files
  write_hardhat_project
  write_go_microservice
  write_helper_scripts
  verify_installation
  print_summary
}

main "$@"