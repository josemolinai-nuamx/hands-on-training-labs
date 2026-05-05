# Checklist de Validacion - Laboratorio 30 min

## 1) Aislamiento de cluster
- [ ] Se ejecuto `k3d cluster stop lab`.
- [ ] `k3d cluster list` muestra `lab` detenido.
- [ ] El cluster nuevo `lab-seguridad-05` esta en `Running`.

## 2) Recursos base
- [ ] Namespace `lab-seguridad` existe.
- [ ] Pod de `app-demo` en estado `Running`.
- [ ] Service `app-demo` creado.

## 3) RBAC
- [ ] `kubectl auth can-i list pods -n lab-seguridad --as=system:serviceaccount:lab-seguridad:sa-lab-reader` devuelve `yes`.
- [ ] `kubectl auth can-i create deployments -n lab-seguridad --as=system:serviceaccount:lab-seguridad:sa-lab-reader` devuelve `no`.

## 4) Ingress y TLS
- [ ] Controlador `ingress-nginx-controller` desplegado en namespace `ingress-nginx`.
- [ ] IngressClass `nginx` disponible.
- [ ] Secret TLS `demo-tls` creado.
- [ ] Ingress `app-demo-ingress` creado.
- [ ] Port-forward activo hacia `ingress-nginx-controller` en 8445.
- [ ] Prueba HTTPS responde correctamente con `curl -k --resolve demo.local:8445:127.0.0.1 https://demo.local:8445/`.

## 5) Evidencias para cierre
- [ ] Captura/salida de `k3d cluster list`.
- [ ] Captura/salida de `kubectl get pods,svc,ingress -n lab-seguridad`.
- [ ] Captura/salida de ambos `kubectl auth can-i`.
- [ ] Captura/salida del `curl -k --resolve demo.local:8445:127.0.0.1 https://demo.local:8445/` exitoso.
