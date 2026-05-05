#!/usr/bin/env bash
set -euo pipefail

MANIFEST_URL="${1:-https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml}"

echo "Aplicando manifiesto de ingress-nginx desde: $MANIFEST_URL"
kubectl apply -f "$MANIFEST_URL"

echo "Esperando rollout del controlador..."
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=240s

echo "Validando ingressClass nginx..."
kubectl get ingressclass nginx

echo "Ingress NGINX instalado y listo."
