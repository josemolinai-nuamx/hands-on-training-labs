# Demo App - Helm Chart

Este repositorio contiene un Helm chart de demostración para practicar operaciones de **Instalacion**, **upgrade** y **rollback** en Kubernetes utilizando **Helm.**

Instala una aplicacion con base a nginx en su version 1.25.0 y permite actualizarla a un version 1.27.0.  

# Árbol de archivos del Helm Chart

```text
demo-app/
├── 📁 templates
│   ├── 📄 _helpers.tpl     # Plantillas auxiliares reutilizables
│   ├── ⚙️ deployment.yaml  # Despliegue de la aplicación
│   └── ⚙️ service.yaml     # Exposición del servicio
├── ⚙️ Chart.yaml           # Metadatos del chart (nombre, versión, etc.)
├── 📝 README.md            # Documentación
└── ⚙️ values.yaml          # Valores configurables por defecto
```

# 1 Instalacion

## Instalar el chart por primera vez (imagen nginx:1.25.0)

```bash
helm install demo-app ./demo-app \
  --namespace demo \
  --create-namespace
```

## Verificar que quedó instalado

```bash
helm list -n demo
kubectl get pods -n demo
```

# 2 Actualizar (Upgrade)

## Opción A — cambiar tag directamente en el comando

```bash
helm upgrade demo-app ./demo-app \
  --namespace demo \
  --set image.tag="1.27.0"
```

## Opción B — editar values.yaml y luego upgradear

### En values.yaml cambiar:  tag: "1.27.0"

```bash
helm upgrade demo-app ./demo-app \
  --namespace demo \
  -f values.yaml
```

# 3 Verificar

## Ver historial de revisiones del release

```bash
helm history demo-app -n demo
```

## Verificar la imagen corriendo en el pod

```bash
kubectl describe pod -n demo \
  -l app.kubernetes.io/name=demo-app \
  | grep Image:
```

## Ver los values activos de la revisión actual

```bash
helm get values demo-app -n demo
```

# 4 Rollback

## Ver revisiones disponibles

```bash
helm history demo-app -n demo
```

## Rollback a la revisión anterior (revision 1 = install inicial)

```bash
helm rollback demo-app 1 -n demo
```

### Confirmar que volvió a nginx:1.25.0

```bash
kubectl describe pod -n demo \
  -l app.kubernetes.io/name=demo-app \
  | grep Image:
```

## Historial ahora mostrará revisión 3 (rollback)

```bash
helm history demo-app -n demo
```

# 📝 Notas adicionales

- El chart utiliza plantillas auxiliares (_helpers.tpl) para generar nombres y etiquetas consistentes.
- La aplicación se despliega con un solo pod (por defecto) y expone el puerto 80.
- Los recursos solicitados y límites están configurados para entornos de desarrollo (50m/64Mi de request, 100m/128Mi de límite).

# 📌 Requisitos

- Kubernetes 1.19+
- Helm 3.0+