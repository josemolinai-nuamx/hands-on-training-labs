# Guia de Laboratorio Practico (30 min)

Objetivo: ejecutar un laboratorio de seguridad en Kubernetes con RBAC e Ingress TLS en una VM Ubuntu 20 con Docker, k3d y kubectl.

## Tiempo total
- Duracion total: 30 min
- Perfil: basico-intermedio
- Cluster previo a detener: `lab`
- Cluster nuevo: `lab-seguridad-05`

## 0) Preparacion (0-3 min)
Ejecutar:

```bash
docker --version
k3d version
kubectl version --client
```

Resultado esperado:
- Las 3 herramientas responden correctamente.

## 1) Aislamiento obligatorio de sesiones previas (3-5 min)
Ejecutar:

```bash
k3d cluster stop lab
k3d cluster list
```

Resultado esperado:
- El cluster `lab` queda detenido (`stopped`).

## 2) Crear cluster independiente para este laboratorio (5-8 min)
Ejecutar:

```bash
k3d cluster create lab-seguridad-05 \
  --agents 1 \
  -p "8081:80@loadbalancer" \
  -p "8444:443@loadbalancer"

k3d cluster list
kubectl cluster-info
```

Resultado esperado:
- `lab-seguridad-05` en estado `Running`.
- `kubectl` apuntando al nuevo cluster.

## 3) Instalar Ingress NGINX (8-11 min)
Ejecutar:

```bash
bash manifiestos/install_ingress_nginx.sh
kubectl -n ingress-nginx get deploy,svc
```

Resultado esperado:
- Deployment `ingress-nginx-controller` en estado disponible.
- IngressClass `nginx` creada.

## 4) Despliegue base (11-15 min)
Ejecutar desde la raiz del repo:

```bash
kubectl apply -f manifiestos/namespace.yaml
kubectl apply -f manifiestos/app-demo.yaml
kubectl -n lab-seguridad get pods,svc
```

Resultado esperado:
- Pod `app-demo` en `Running`.
- Service `app-demo` disponible en puerto 80.

## 5) Ejercicio RBAC (15-20 min)
Ejecutar:

```bash
kubectl apply -f manifiestos/rbac.yaml

kubectl auth can-i list pods \
  -n lab-seguridad \
  --as=system:serviceaccount:lab-seguridad:sa-lab-reader

kubectl auth can-i create deployments \
  -n lab-seguridad \
  --as=system:serviceaccount:lab-seguridad:sa-lab-reader
```

Resultado esperado:
- Primera validacion: `yes`.
- Segunda validacion: `no`.

## 6) Ejercicio Ingress + TLS (20-27 min)
1. Crear cert y secret TLS:

```bash
bash manifiestos/tls-secret.sh lab-seguridad demo-tls
```

2. Aplicar Ingress:

```bash
kubectl apply -f manifiestos/ingress.yaml
kubectl -n lab-seguridad get ingress,secret
```

3. Exponer temporalmente el controlador Ingress NGINX para prueba local:

```bash
kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 8445:443
```

4. En otra terminal, probar HTTPS:

```bash
curl -k --resolve demo.local:8445:127.0.0.1 https://demo.local:8445/
```

Resultado esperado:
- Respuesta del servicio: `lab seguridad kubernetes ok`.

## 7) Validacion y cierre (27-30 min)
Validaciones rapidas:

```bash
kubectl -n lab-seguridad get pods,svc,ingress
kubectl -n lab-seguridad describe ingress app-demo-ingress
```

Checklist:
- Usar [checklist_validacion.md](checklist_validacion.md).

Opciones de cierre:

```bash
# detener cluster (conservar estado)
k3d cluster stop lab-seguridad-05

# o eliminar cluster (limpieza total)
k3d cluster delete lab-seguridad-05
```

## Troubleshooting rapido
- Si Ingress no responde:
  - Verificar instalacion: `kubectl -n ingress-nginx get deploy ingress-nginx-controller`.
  - Confirmar que el port-forward al servicio `ingress-nginx-controller` este activo.
  - Revisar `kubectl -n lab-seguridad get ingress`.
- Si TLS falla:
  - Regenerar el secret con `tls-secret.sh`.
  - Reintentar curl usando `--resolve demo.local:8445:127.0.0.1`.
- Si RBAC no da resultados esperados:
  - Verificar ServiceAccount y RoleBinding en namespace `lab-seguridad`.
