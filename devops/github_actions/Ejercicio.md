# Ejercicio Prático

En este ejercicio practico, se realizara la integracion de GitHub Actions + runner self-hosted apuntando a k3d en maquina local para despliegue de la aplicacion Demo-App.

## 1. Estructura del repo

- Crear una rama `nombre_rama_unica` donde se aplicaran los cambios, colocarle el nombre que guste.

- Crear directorio en la raiz del repositorio. 

```bash
.github/
└── workflows/
    └── deploy.yaml
```
o 

```bash
.github/workflows/deploy.yaml
```

- En su contenido

```yaml
---
name: Deploy Demo App (Helm)

on:
  push:
    branches:
      
      - main

jobs:
  deploy:
    runs-on: self-hosted

    steps:
      - name: checkout repo
        uses: actions/checkout@v4

      - name: verificar kubectl
        run: kubectl get nodes

      - name: verificar Helm
        run: helm version

      - name: deploy con Helm (install/upgrade)
        run: |
          helm upgrade --install demo-app ./devops/demo-app \
            --namespace demo-app \
            --create-namespace

      - name: verificar despliegue
        run: |
          kubectl get pods -n demo-app
          kubectl get svc -n demo-app
```

## 2. Crear runner self-hosted en maquina local

- En la maquina local crear el directorio donde se ejecutara el runner.

```bash
cd ~
mkdir actions-runner
cd actions-runner
```

- Configurar actions runner local dentro del directorio `actions-runner`

Crear runner self-hosted

- En el repo Github ir a:

Settings → Actions → Runners
Click en "New self-hosted runner"
Selecciona Linux

Debe mostrar algo similar a estas intrucciones, seuir en su orden, tener preente que en alguos casos , debe adicionar /usr/bin/ segn la imgen de linux utilizada. 

```bash
# Download the latest runner package
curl -o actions-runner-linux-x64-2.334.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.334.0/actions-runner-linux-x64-2.334.0.tar.gz
# Optional: Validate the hash
echo "048024cd2c848eb6f14d5646d56c13a4def2ae7ee3ad12122bee960c56f3d271  actions-runner-linux-x64-2.334.0.tar.gz" | shasum -a 256 -c
# Extract the installer
/usr/bin/tar -xzf actions-runner-linux-x64-2.334.0.tar.gz
```

- Crear el runner y iniciar la configuration

```bash
# Create the runner and start the configuration experience
/bin/bash ./config.sh --url https://github.com/josemolinai-nuamx/hands-on-training-labs --token BFC / ZC3 / MJV / Q4N / UY5 / AJS / OGY / OLJ / 5P2 / XI
# Last step, run it!
/bin/bash ./run.sh
```

## 3. Ejecutar el pipeline

realizar el commit a la la rama `nombre_rama_unica`

```bash
git add .
git commit -m "deploy pipeline"
git push origin main
```

Luego:

👉 Ir a Actions en GitHub
👉 Ver el job corriendo
👉 Logs mostrarán:

```bash
kubectl get nodes
helm upgrade --install ...
```

## 4. Probar el despliegue

Validar el despliegue

```bash
get pod -n demo-app
#Respuesta esperada
NAME                   READY   STATUS    RESTARTS   AGE
demo-app-xxxxxxx-yyyy   1/1     Running   0          7d22h
```

y probar

```bash
kubectl port-forward svc/demo-app 8080:80 -n demo-app
```

En el navegador web

http://localhost:8080