#!/usr/bin/env bash
# Curso K8S-LOCAL-DEPLOY-01 · Verificación de la instalación
# Uso:  bash setup/verificacion.sh
#   SKIP_CLUSTER=1 bash setup/verificacion.sh   (omite la prueba de clúster)
#   MIN_RAM_GB=8   bash setup/verificacion.sh   (cambia el mínimo de RAM libre)
set -uo pipefail

SKIP_CLUSTER="${SKIP_CLUSTER:-0}"
MIN_RAM_GB="${MIN_RAM_GB:-4}"

if [ -t 1 ]; then
  G=$'\033[32m'; R=$'\033[31m'; Y=$'\033[33m'; N=$'\033[0m'
else
  G=""; R=""; Y=""; N=""
fi

FAILS=0

pass() { printf '%s[OK]%s %s\n' "$G" "$N" "$*"; }
fail() { printf '%s[FAIL]%s %s\n' "$R" "$N" "$*"; FAILS=$((FAILS+1)); }
note() { printf '%s[NOTA]%s %s\n' "$Y" "$N" "$*"; }

check_bin() { # check_bin <nombre> <comando...>
  local bin="$1"; shift
  if command -v "$bin" >/dev/null 2>&1; then
    pass "$bin"
    "$@" 2>/dev/null | sed -n '1{s/^/      /;p;}' || true
  else
    fail "$bin  (no está en el PATH)"
  fi
}

echo "=== Verificación de entorno · curso Kubernetes local ==="
echo

# 1) Binarios
check_bin docker  docker --version
check_bin kind    kind version
check_bin kubectl kubectl version --client
check_bin helm    helm version --short
check_bin git     git --version

# kustomize viene embebido en kubectl
if kubectl kustomize --help >/dev/null 2>&1; then
  pass "kustomize (embebido en kubectl)"
else
  fail "kustomize (kubectl kustomize --help falló)"
fi

# 2) Daemon de contenedores
if docker info >/dev/null 2>&1; then
  pass "daemon Docker respondiendo"
else
  fail "daemon Docker no responde"
  note "Linux: sudo systemctl start docker · macOS: colima start / abre Docker Desktop · Windows: abre Ubuntu (WSL2)"
fi

# 3) Recursos del equipo
if command -v free >/dev/null 2>&1; then
  FREE_GB=$(free -b 2>/dev/null | awk '/^Mem:/ {printf "%d", $7/1024/1024/1024}')
elif command -v vm_stat >/dev/null 2>&1; then
  FREE_GB=$(vm_stat | awk '/Pages free/ {gsub(/\./,"",$3); printf "%d", $3*4096/1024/1024/1024}')
else
  FREE_GB=999
fi
if [ "${FREE_GB:-0}" -ge "$MIN_RAM_GB" ] 2>/dev/null; then
  pass "RAM libre: ${FREE_GB} GB (mínimo ${MIN_RAM_GB} GB)"
else
  note "RAM libre: ${FREE_GB:-?} GB < ${MIN_RAM_GB} GB recomendados para el clúster"
fi

# 4) Prueba de ciclo de vida de kind (clúster temporal)
if [ "$SKIP_CLUSTER" = "1" ]; then
  note "SKIP_CLUSTER=1 → prueba de clúster omitida"
elif ! docker info >/dev/null 2>&1; then
  fail "cluster temporal creado y borrado  (Docker no responde, prueba omitida)"
else
  TMP_NAME="check-$$"
  if kind create cluster --name "$TMP_NAME" --wait 120s >/dev/null 2>&1; then
    if kubectl get nodes >/dev/null 2>&1; then
      kind delete cluster --name "$TMP_NAME" >/dev/null 2>&1
      pass "cluster temporal creado y borrado"
    else
      kind delete cluster --name "$TMP_NAME" >/dev/null 2>&1
      fail "cluster temporal creado y borrado  (kubectl no vio los nodos)"
    fi
  else
    kind delete cluster --name "$TMP_NAME" >/dev/null 2>&1
    fail "cluster temporal creado y borrado  (kind create falló)"
    note "Mira: kind create cluster --name $TMP_NAME (sin redirigir la salida)"
  fi
fi

echo
if [ "$FAILS" -eq 0 ]; then
  printf '%sTODO EN VERDE%s → estás listo para el Día 1.\n' "$G" "$N"
  exit 0
else
  printf '%s%s comprobación(es) fallida(s)%s → revisa setup/troubleshooting-setup.md\n' "$R" "$FAILS" "$N"
  exit 1
fi
