# Automatización y CI/CD

## Configuracion boostrap Flux

flux bootstrap git \
  --token-auth=true \
  --url=https://github.com/josemolinai-nuamx/hands-on-training-labs \
  --branch=main \
  --path=./devops/flux_repo/overlays/dev \
  --namespace=flux-system \
  --interval=1m

## Token = ghp_ / 5qx7 / b5bE / FTWY / TjR / rJU / 98y / DzB / x8L / XnG / 2w3 / jJu
¡IMPORTANTE! Para armar el token por favor eliminar " / " desde ghp_ y validar que no queden espacios. 

## Genertar token.

Pasos en GitHub:

1. Haz clic en tu foto de perfil (esquina superior derecha) y selecciona Settings.
2. En el menú de la izquierda, desplázate hasta la sección "Developer settings".
3. Luego, haz clic en "Personal access tokens" y selecciona "Tokens (classic)" .
4. Haz clic en "Generate new token" y luego en "Generate new token (classic)".
4. 1. Nota (opcional): Pon un nombre descriptivo, por ejemplo, "flux-bootstrap" .
5. Expiración: Elige un período de validez (ej. 90 días). Recuerda que tendrás que renovarlo antes de que venza .
6. Permisos (lo más importante): Marca el scope repo. Esto le dará a Flux acceso completo a tus repositorios privados, que es necesario para que funcione .

Haz clic en "Generate token" en la parte inferior de la página.

¡IMPORTANTE! Aparecerá el token (una cadena larga de caracteres). Cópialo y guárdalo en un lugar seguro de inmediato, ya que no podrás volver a verlo después de cerrar la página.

## generar kubeconfig cluster
```bash 
k3d kubeconfig get lab > lab.yaml
```


## Herramientas

### github-desktop

```bash
wget -qO - https://mirror.mwt.me/shiftkey-desktop/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/mwt-desktop.gpg > /dev/null
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mwt-desktop.gpg] https://mirror.mwt.me/shiftkey-desktop/deb/ any main" > /etc/apt/sources.list.d/mwt-desktop.list'
```
```bash
sudo apt update && sudo apt install github-desktop
```

### OpenLens

Interfaz de usuario para administrar clústeres de Kubernetes

```bash
curl -LO https://github.com/MuhammedKalkan/OpenLens/releases/download/v6.5.2-366/OpenLens-6.5.2-366.amd64.deb
sudo apt install ./OpenLens-6.5.2-366.amd64.deb
```

### MobaXterm

 Software de escritorio remoto para Windows. Incluye herramientas de red, como SSH, VNC, MOSH o FTP y Unix, lo que ayuda a conectarse y manejar tareas o aplicaciones desde computadoras remotas.

- https://mobaxterm.mobatek.net/

- https://mobaxterm.mobatek.net/download.html
