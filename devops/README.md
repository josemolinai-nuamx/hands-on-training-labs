# Automatización y CI/CD

flux bootstrap git \
  --url=https://github.com/josemolinai-nuamx/hands-on-training-labs \
  --branch=main \
  --path=./devops/flux_repo/overlays/dev \
  --namespace=flux-system

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