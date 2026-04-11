# Laboratorio Kubernetes Local

## Entorno de referencia

- **Host**: Ubuntu 24.04 virtualizado en VirtualBox
- **CPU**: 2 vCPU
- **RAM**: 4 GB
- **Herramienta**: k3s directo en host (single-node) o k3d con iscsi del host
- **Longhorn**: v1.7.x

---

## Prerequisitos comunes

Ejecutar en el host Ubuntu antes de cualquier laboratorio:

```bash
# Dependencias del sistema
sudo apt-get update
sudo apt-get install -y \
  open-iscsi \
  nfs-common \
  curl \
  wget \
  git \
  apt-transport-https \
  ca-certificates

# Activar iscsid
sudo systemctl enable --now iscsid
sudo systemctl status iscsid

# Verificar iscsiadm
sudo iscsiadm --version

# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Instalar Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verificar versiones
kubectl version --client
helm version
```


## Referencia rápida de comandos

```bash
# Ver todos los recursos Longhorn
kubectl -n longhorn-system get volumes
kubectl -n longhorn-system get replicas
kubectl -n longhorn-system get snapshots
kubectl -n longhorn-system get backups
kubectl -n longhorn-system get recurringjobs
kubectl -n longhorn-system get nodes.longhorn.io
kubectl -n longhorn-system get settings

# Ver logs del manager
kubectl -n longhorn-system logs -l app=longhorn-manager --tail=50

# Estado de salud rápido
kubectl -n longhorn-system get volumes.longhorn.io \
  -o custom-columns='VOL:.metadata.name,ESTADO:.status.state,SALUD:.status.robustness'

# Forzar sincronización de settings
kubectl -n longhorn-system rollout restart deploy/longhorn-driver-deployer

# Eliminar volumen atascado en Deleting
kubectl -n longhorn-system patch volumes.longhorn.io <nombre> \
  --type merge -p '{"metadata":{"finalizers":[]}}'

# UI de Longhorn
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8888:80
```

---

## Resolución de problemas frecuentes

### iscsiadm no encontrado en nodos k3d

```bash
# Verificar que el host tiene iscsiadm
sudo iscsiadm --version

# Montar el binario en los nodos al crear el cluster
k3d cluster create mi-cluster \
  --volume /usr/sbin/iscsiadm:/usr/sbin/iscsiadm@all
```

### Volumen atascado en estado Attaching

```bash
# Ver qué nodo tiene el volumen
kubectl -n longhorn-system get volumes.longhorn.io <nombre> \
  -o jsonpath='{.status.currentNodeID}'

# Forzar detach
kubectl -n longhorn-system patch volumes.longhorn.io <nombre> \
  --type merge -p '{"spec":{"nodeID":""}}'
```

### Pod en Pending por PVC no disponible

```bash
# Ver eventos del PVC
kubectl describe pvc <nombre>

# Ver eventos del pod
kubectl describe pod <nombre>

# Verificar que el StorageClass existe
kubectl get storageclass
```

### Longhorn UI no carga

```bash
# Verificar que el frontend está corriendo
kubectl -n longhorn-system get deploy longhorn-ui

# Reiniciar el port-forward
pkill -f "port-forward svc/longhorn-frontend"
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8888:80 &
```