# hands-on-training-labs

Repositorio centralizado de recursos para la ejecución de laboratorios prácticos (hands-on) en capacitaciones técnicas.

---

## 📌 Propósito

Este repositorio tiene como objetivo proporcionar un entorno estructurado, reproducible y escalable para la ejecución de ejercicios prácticos durante capacitaciones técnicas.

Está diseñado para:

- Facilitar la ejecución de talleres hands-on de forma guiada
- Estandarizar la entrega de materiales prácticos
- Reducir el tiempo de preparación de entornos
- Permitir la reutilización de laboratorios en distintas capacitaciones
- Simular escenarios reales de operación (entornos productivos simplificados)

---

## 🎯 Alcance

El repositorio incluye recursos organizados por áreas temáticas, tales como:

- Fundamentos (Linux, redes, contenedores)
- DevOps (CI/CD, GitOps, observabilidad)
- Kubernetes (workloads, networking, storage)
- Seguridad (autenticación, autorización, gestión de secretos)
- Blockchain (Hyperledger Fabric, Besu, smart contracts)
- Backend (APIs REST, gRPC, acceso a datos)
- Frontend (React, microfrontends)
- Escenarios integrados end-to-end

---

## 🧱 Estructura del repositorio

```

hands-on-training-labs/
│
├── docs/           # Documentación general
├── shared/         # Recursos reutilizables entre labs
├── bootstrap/      # Scripts de instalación del entorno
│
├── fundamentals/   # Conceptos base
├── devops/         # Automatización y CI/CD
├── kubernetes/     # Laboratorios de Kubernetes
├── security/       # Seguridad aplicada
├── blockchain/     # Redes y contratos blockchain
├── backend/        # Desarrollo backend
├── frontend/       # Desarrollo frontend
│
└── scenarios/      # Casos integrados end-to-end

````

---

## 🚀 Uso del repositorio

### 1. Preparación del entorno

Antes de ejecutar cualquier laboratorio, se debe preparar el entorno utilizando los scripts de bootstrap:

```bash
cd bootstrap
./install.sh
````

Esto instalará herramientas necesarias como:

- Docker
- kubectl
- Helm
- Git
- Otras dependencias según el entorno

También se recomienda ejecutar:

```bash
./verify.sh
```

Para validar que el entorno está correctamente configurado.

---

### 2. Ejecución de laboratorios

Cada laboratorio se encuentra organizado en carpetas independientes:

```md
<area>/<lab>/
```

Ejemplo:

```md
kubernetes/lab-01-basic-deployment/
```

Cada laboratorio contiene:

- `README.md`: descripción general
- `objectives.md`: objetivos del ejercicio
- `prerequisites.md`: requisitos previos
- `steps/`: guía paso a paso
- `solution/`: solución de referencia
- `scripts/` y `manifests/`: recursos técnicos
- `cleanup.sh`: limpieza del entorno

---

### 3. Flujo recomendado

1. Leer los objetivos del laboratorio
2. Revisar los prerrequisitos
3. Ejecutar los pasos en orden
4. Validar resultados
5. Comparar con la solución (opcional)
6. Ejecutar limpieza si corresponde

---

## 🔁 Reutilización y extensibilidad

Este repositorio está diseñado para:

- Agregar nuevos laboratorios sin afectar los existentes
- Reutilizar componentes comunes (`shared/`)
- Integrar nuevos dominios tecnológicos
- Adaptarse a distintos niveles (básico → avanzado)

---

## 🧪 Escenarios integrados

La carpeta `scenarios/` contiene ejercicios que combinan múltiples áreas, permitiendo:

- Simular entornos productivos
- Integrar componentes (API + Kubernetes + seguridad + blockchain)
- Ejecutar prácticas de troubleshooting y operación

---

## ⚙️ Requisitos generales

- Sistema operativo:

  - Linux (Ubuntu recomendado)
  - Windows con WSL2
  - Máquina virtual (VirtualBox / Hyper-V)

- Recursos mínimos sugeridos:

  - 2 CPU
  - 4 GB RAM
  - 20 GB de almacenamiento

---

## 🛠️ Buenas prácticas

- Ejecutar los laboratorios en orden sugerido
- No modificar archivos de solución directamente
- Usar scripts de limpieza antes de repetir ejercicios
- Documentar problemas en `docs/troubleshooting.md`
- Mantener consistencia en nombres de labs (`lab-01`, `lab-02`, etc.)

---

## 🤝 Contribución

Para agregar nuevos laboratorios:

1. Crear una nueva carpeta bajo el área correspondiente
2. Seguir la estructura estándar de laboratorio
3. Documentar claramente objetivos y pasos
4. Incluir scripts reproducibles
5. Validar ejecución en entorno limpio

---

## 📚 Referencias

Este repositorio puede integrarse con herramientas y tecnologías como:

- Kubernetes
- Docker
- Helm
- GitOps (ej: FluxCD)
- Gestión de identidades (ej: Keycloak)
- Blockchain (ej: Hyperledger Fabric, Hyperledger Besu)

---

## 📌 Notas finales

Este repositorio es parte de un enfoque de capacitación práctica orientado a:

- Aprender haciendo
- Reducir la brecha entre teoría y operación real
- Fortalecer capacidades técnicas en entornos modernos

---
