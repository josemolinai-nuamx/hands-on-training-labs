# Lab 00 — Instalación del entorno base (k3s single-node)

**Objetivo**: levantar Kubernetes en el host Ubuntu e instalar Longhorn funcional.


## Paso 1 Instalar iscsi  

```bash
sudo apt-get update
sudo apt-get install -y open-iscsi nfs-common

# Iniciar y habilitar el servicio
sudo systemctl enable --now iscsid
sudo systemctl status iscsid   # debe mostrar active (running)

# Verificar que iscsiadm responde
sudo iscsiadm --version
# iscsi-initiator-utils 6.x.x
```


## Paso 2 — Instalar k3s

```bash
curl -sfL https://get.k3s.io | sh -

# Esperar que k3s levante
sudo systemctl status k3s

# Configurar kubeconfig
mkdir -p ~/.kube
# mv ~/.kube/config ~/.kube/k3d-lab # Respaldo de kubeconfig de cluster k3d-lab
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
chmod 600 ~/.kube/config

# Verificar nodo
kubectl get nodes
# NAME       STATUS   ROLES                  AGE   VERSION
# ubuntu     Ready    control-plane,master   1m    v1.33.x
```

## Paso 3 — Instalar Longhorn

```bash
# Agregar repositorio Helm
helm repo add longhorn https://charts.longhorn.io
helm repo update

# Instalar con recursos reducidos para 4 GB RAM
helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace \
  --set defaultSettings.defaultReplicaCount=1 \
  --set longhornManager.resources.requests.cpu=100m \
  --set longhornManager.resources.requests.memory=128Mi \
  --set longhornUI.resources.requests.cpu=50m \
  --set longhornUI.resources.requests.memory=64Mi \
  --set csi.attacher.resources.requests.cpu=50m \
  --set csi.provisioner.resources.requests.cpu=50m \
  --set csi.resizer.resources.requests.cpu=50m

# Esperar que todos los pods estén Running (3-5 min)
kubectl -n longhorn-system rollout status deploy/longhorn-driver-deployer
kubectl -n longhorn-system get pods
```

## Paso 4 — Acceder a la UI de Longhorn

```bash
# En una terminal separada (mantener abierta durante los labs)
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8888:80

# Abrir en el navegador
# http://localhost:8888
```

## Verificación del lab

```bash
# El nodo debe mostrar discos detectados por Longhorn
kubectl -n longhorn-system get nodes.longhorn.io
kubectl -n longhorn-system get disks

# Verificar StorageClass creada automáticamente
kubectl get storageclass
# NAME                 PROVISIONER          RECLAIMPOLICY
# longhorn (default)   driver.longhorn.io   Delete