# 🧪 Laboratorio de Fallas en Kubernetes - Monitoreo

Este laboratorio despliega un conjunto de pods y un deployment en el namespace `falla-test`, diseñados intencionalmente para **simular distintos tipos de fallas en Kubernetes**.

El objetivo es validar herramientas de observabilidad como:

* Prometheus (métricas)
* Grafana (dashboards)
* Loki (logs)

---

## 📦 Estructura del Proyecto

Este laboratorio incluye los siguientes recursos: 

* Namespace dedicado: `falla-test`
* Pods con distintos tipos de fallas
* Un deployment con comportamiento inestable
* Casos de uso reales para monitoreo

---

## 🎯 Objetivo del Ejercicio

Permitir al usuario:

* Detectar fallas en pods
* Analizar reinicios (restarts)
* Identificar errores en logs
* Observar consumo de memoria (OOMKilled)
* Validar estado de contenedores múltiples
* Monitorear salud de deployments

---

## 🔍 Descripción de los Recursos

### 1. 🔄 `test-crashloop-pod`

**Tipo de falla:** CrashLoopBackOff

Este pod:

* Inicia correctamente
* Luego falla intencionalmente (`exit 1`)
* Kubernetes lo reinicia automáticamente (`restartPolicy: Always`)

💡 **Qué monitorear:**

* Métrica: `kube_pod_container_status_restarts_total`
* Estado: `CrashLoopBackOff`
* Logs con errores recurrentes

---

### 2. 📝 `test-error-logs-pod`

**Tipo de falla:** Generación de logs con errores

Este pod:

* Emite logs con niveles `ERROR`, `WARNING` y `CRITICAL`
* Termina con error (`exit 1`)
* No se reinicia (`restartPolicy: Never`)

💡 **Qué monitorear:**

* Loki queries (`ERROR`, `CRITICAL`)
* Conteo de logs en el tiempo
* Correlación logs vs métricas

---

### 3. ❌ `test-failed-pod`

**Tipo de falla:** Pod en estado `Failed`

Este pod:

* Falla inmediatamente (`exit 1`)
* No se reinicia

💡 **Qué monitorear:**

* Métrica: `kube_pod_status_phase{phase="Failed"}`
* Conteo de pods fallidos

---

### 4. 📉 `test-failing-deployment`

**Tipo de falla:** Deployment inestable

Este deployment:

* Tiene 2 réplicas
* Funciona por algunos ciclos
* Luego falla intencionalmente

💡 **Qué monitorear:**

* `kube_deployment_status_replicas_available`
* `kube_deployment_status_replicas_unavailable`
* Eventos de reinicio

---

### 5. 🧩 `test-multi-container-pod`

**Tipo de falla:** Contenedor parcial

Este pod tiene:

* Un contenedor funcional (`nginx`)
* Un contenedor que falla inmediatamente

💡 **Qué monitorear:**

* `kube_pod_container_status_ready`
* Estado por contenedor
* Problemas en sidecars

---

### 6. 💀 `test-oom-pod`

**Tipo de falla:** OOMKilled (Out Of Memory)

Este pod:

* Consume más memoria de la permitida
* Supera el límite (`256Mi`)
* Es terminado por el sistema

💡 **Qué monitorear:**

* `container_memory_usage_bytes`
* `container_spec_memory_limit_bytes`
* Evento `OOMKilled`

---

## 📊 Casos de Uso en Grafana

Este laboratorio permite validar dashboards como:

* Conteo de pods fallidos / pendientes
* CrashLoopBackOff detection
* Logs de error por pod
* Uso de memoria y riesgo de OOM
* Estado de deployments
* Análisis de reinicios

---

## 🚀 Despliegue

```bash
kubectl apply -k .
```

---

Usar queries como:

 * `kube_pod_status_phase`
 * `kube_pod_container_status_restarts_total`
 * `container_memory_usage_bytes`
 * Logs con filtros: `ERROR`, `CRITICAL`, `FATAL`

---

## 🎓 Resultado Esperado

Después de desplegar este laboratorio debaria poder:

* ✅ Identificar fallas rápidamente
* ✅ Correlacionar métricas y logs
* ✅ Validar alertas
* ✅ Simular escenarios reales de producción


---

**Este laboratorio está diseñado para simular problemas reales que ocurren en producción.**