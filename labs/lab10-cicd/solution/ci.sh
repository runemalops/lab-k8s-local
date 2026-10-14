#!/usr/bin/env bash
# Lab 10 — Pipeline LOCAL (fallback del CI/CD)
# Misma lógica que el workflow de GitHub Actions, para ejecutar en tu terminal.
#
# Uso:
#   bash labs/lab10-cicd/ci.sh
#   KUSTOMIZE_DIR=mi/ruta NS=mi-ns bash labs/lab10-cicd/ci.sh
#   SKIP_DEPLOY=1 bash labs/lab10-cicd/ci.sh     # solo valida
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
KUSTOMIZE_DIR="${KUSTOMIZE_DIR:-$REPO_ROOT/labs/lab10-cicd/manifests}"
NS="${NS:-lab10}"
DEPLOYMENT="${DEPLOYMENT:-curso-web}"
OUT="/tmp/ci-rendered-$(basename "$KUSTOMIZE_DIR").yaml"
SKIP_DEPLOY="${SKIP_DEPLOY:-0}"
TIMEOUT="${TIMEOUT:-120s}"

step() { printf '\n\033[36m==> %s\033[0m\n' "$*"; }
fail() { printf '\033[31m[FAIL]\033[0m %s\n' "$*"; exit 1; }

[ -d "$KUSTOMIZE_DIR" ] || fail "No existe la carpeta: $KUSTOMIZE_DIR"

step "[1/4] Renderizar manifiestos (kubectl kustomize)"
kubectl kustomize "$KUSTOMIZE_DIR" > "$OUT"
wc -l "$OUT"

step "[2/4] Validar sintaxis (kubectl apply --dry-run=client)"
kubectl apply --dry-run=client -f "$OUT" >/dev/null
echo "OK: manifiestos válidos"

if command -v kubeconform >/dev/null 2>&1; then
  step "[3/4] Validar esquema (kubeconform)"
  kubeconform -summary -strict "$OUT"
else
  step "[3/4] kubeconform no instalado → se omite (opcional)"
  echo "   Instálalo: https://github.com/yannh/kubeconform"
fi

if [ "$SKIP_DEPLOY" = "1" ]; then
  step "[4/4] SKIP_DEPLOY=1 → no se despliega"
  echo; echo "[OK] Pipeline local superado (solo validación)."
  exit 0
fi

step "[4/4] Desplegar y comprobar rollout"
kubectl apply -f "$OUT"
kubectl rollout status deployment/"$DEPLOYMENT" -n "$NS" --timeout="$TIMEOUT"
kubectl get pods -n "$NS"

echo
echo "[OK] Pipeline local superado (namespace: $NS)."
