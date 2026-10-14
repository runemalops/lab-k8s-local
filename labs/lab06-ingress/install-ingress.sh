#!/usr/bin/env bash
# Lab 06 — Instalación de ingress-nginx (provider kind)
# Versión congelada del controlador (cambiar solo si el instructor lo indica)
set -euo pipefail

INGRESS_NGINX_VERSION="${INGRESS_NGINX_VERSION:-controller-v1.12.1}"
MANIFEST_URL="https://raw.githubusercontent.com/kubernetes/ingress-nginx/${INGRESS_NGINX_VERSION}/deploy/static/provider/kind/deploy.yaml"

echo "==> Instalando ingress-nginx (${INGRESS_NGINX_VERSION})"
kubectl apply -f "$MANIFEST_URL"

echo "==> Esperando a que el controlador esté listo (puede tardar 1-2 min la primera vez)"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

kubectl get pods -n ingress-nginx
echo
echo "==> Listo. Pruébalo con:"
echo "    kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80"
echo "    curl -H 'Host: app.local' http://localhost:8080/"
