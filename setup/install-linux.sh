#!/usr/bin/env bash
# Curso K8S-LOCAL-DEPLOY-01 · Instalación de tooling en Linux
# Uso:  bash setup/install-linux.sh
# No interactivo/CI:  SKIP_DOCKER=1 bash setup/install-linux.sh
set -euo pipefail

# Versiones congeladas del curso (ver 03_estructura_instructor.md §1.3)
KUBECTL_VERSION="${KUBECTL_VERSION:-v1.31.4}"   # alineado al clúster kind (K8s 1.31.x)
KUBECTL_CHANNEL="${KUBECTL_CHANNEL:-}"          # si se define, p.ej. "stable", manda sobre KUBECTL_VERSION
KIND_VERSION="${KIND_VERSION:-v0.24.0}"
HELM_VERSION="${HELM_VERSION:-v3.16.4}"
SKIP_DOCKER="${SKIP_DOCKER:-0}"
BIN_DIR="${BIN_DIR:-/usr/local/bin}"

# Colores solo si hay TTY
if [ -t 1 ]; then
  C_OK=$'\033[32m'; C_WARN=$'\033[33m'; C_ERR=$'\033[31m'; C_INF=$'\033[36m'; C_OFF=$'\033[0m'
else
  C_OK=""; C_WARN=""; C_ERR=""; C_INF=""; C_OFF=""
fi

ok()   { printf '%s[OK]%s %s\n'   "$C_OK"   "$C_OFF" "$*"; }
warn() { printf '%s[AVISO]%s %s\n' "$C_WARN" "$C_OFF" "$*"; }
err()  { printf '%s[ERROR]%s %s\n' "$C_ERR"  "$C_OFF" "$*"; }
info() { printf '%s[INFO]%s %s\n' "$C_INF"  "$C_OFF" "$*"; }
die()  { err "$*"; exit 1; }

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  KARCH="amd64" ;;
  aarch64|arm64) KARCH="arm64" ;;
  *) die "Arquitectura no soportada: $ARCH" ;;
esac

command -v curl >/dev/null 2>&1 || die "Falta 'curl'. Instálalo con tu gestor de paquetes (ej: sudo apt-get install -y curl)."
command -v git  >/dev/null 2>&1 || warn "Falta 'git' (lo necesitarás el Día 1): sudo apt-get install -y git"

mkdir -p "$BIN_DIR" 2>/dev/null || sudo mkdir -p "$BIN_DIR"
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) export PATH="$BIN_DIR:$PATH"
     warn "$BIN_DIR no está en tu PATH. Añade a ~/.bashrc:  export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac

# ---------------------------------------------------------------- Docker
install_docker() {
  if [ "$SKIP_DOCKER" = "1" ]; then
    warn "SKIP_DOCKER=1 → no se instala Docker."
    return
  fi
  if command -v docker >/dev/null 2>&1; then
    ok "docker ($(docker --version 2>/dev/null | head -1))"
  else
    info "Instalando Docker Engine (script oficial de Docker)…"
    curl -fsSL https://get.docker.com | sudo sh
    ok "docker instalado"
  fi
  if docker info >/dev/null 2>&1; then
    ok "daemon Docker respondiendo"
  else
    if command -v systemctl >/dev/null 2>&1; then
      sudo systemctl enable --now docker >/dev/null 2>&1 || true
    fi
    if docker info >/dev/null 2>&1; then
      ok "daemon Docker respondiendo"
    else
      warn "El daemon Docker no responde. Reinicia sesión tras añadirte al grupo 'docker' o ejecuta: sudo systemctl start docker"
    fi
  fi
  if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    info "Añadiendo $USER al grupo 'docker' (haz logout/login para que surta efecto)"
    sudo usermod -aG docker "$USER" 2>/dev/null || warn "No se pudo añadir al grupo docker"
  fi
}

# ---------------------------------------------------------------- kubectl
install_kubectl() {
  if command -v kubectl >/dev/null 2>&1 && [ "${FORCE:-0}" != "1" ]; then
    ok "kubectl ($(kubectl version --client 2>/dev/null | head -1))"
    return
  fi
  local ver
  if [ -n "$KUBECTL_CHANNEL" ]; then
    ver="$(curl -fsSL "https://dl.k8s.io/release/${KUBECTL_CHANNEL}.txt")"
  else
    ver="$KUBECTL_VERSION"
  fi
  info "kubectl ${ver} (${KARCH})"
  curl -fsSLo /tmp/kubectl "https://dl.k8s.io/release/${ver}/bin/linux/${KARCH}/kubectl"
  chmod +x /tmp/kubectl
  if [ -w "$BIN_DIR" ]; then
    mv /tmp/kubectl "$BIN_DIR/kubectl"
  else
    sudo mv /tmp/kubectl "$BIN_DIR/kubectl"
  fi
  ok "kubectl $(kubectl version --client -o yaml 2>/dev/null | grep gitVersion | head -1 | awk '{print $2}')"
}

# ---------------------------------------------------------------- kind
install_kind() {
  if command -v kind >/dev/null 2>&1 && [ "${FORCE:-0}" != "1" ]; then
    ok "kind ($(kind version))"
    return
  fi
  info "kind ${KIND_VERSION} (${KARCH})"
  curl -fsSLo /tmp/kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${KARCH}"
  chmod +x /tmp/kind
  if [ -w "$BIN_DIR" ]; then
    mv /tmp/kind "$BIN_DIR/kind"
  else
    sudo mv /tmp/kind "$BIN_DIR/kind"
  fi
  ok "kind $(kind version)"
}

# ---------------------------------------------------------------- Helm
install_helm() {
  if command -v helm >/dev/null 2>&1 && [ "${FORCE:-0}" != "1" ]; then
    ok "helm ($(helm version --short 2>/dev/null))"
    return
  fi
  local ver="${HELM_VERSION:-}"
  if [ -z "$ver" ]; then
    ver="$(curl -fsSL https://api.github.com/repos/helm/helm/releases/latest 2>/dev/null | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4 || true)"
    ver="${ver:-v3.16.4}"
  fi
  info "Helm ${ver} (${KARCH})"
  curl -fsSLo /tmp/helm.tgz "https://get.helm.sh/helm-${ver}-linux-${KARCH}.tar.gz"
  mkdir -p /tmp/helm-extract && tar -xzf /tmp/helm.tgz -C /tmp/helm-extract
  mv "/tmp/helm-extract/linux-${KARCH}/helm" /tmp/helm && chmod +x /tmp/helm
  rm -rf /tmp/helm.tgz /tmp/helm-extract
  if [ -w "$BIN_DIR" ]; then
    mv /tmp/helm "$BIN_DIR/helm"
  else
    sudo mv /tmp/helm "$BIN_DIR/helm"
  fi
  ok "helm $(helm version --short 2>/dev/null)"
}

# ---------------------------------------------------------------- main
echo "=== Instalación de tooling del curso (Linux / ${KARCH}) ==="
install_docker
install_kubectl || warn "Falló la instalación de kubectl"
install_kind    || warn "Falló la instalación de kind"
install_helm    || warn "Falló la instalación de Helm"

echo
echo "=== Verificación final ==="
bash "$(dirname "$0")/verificacion.sh" || true

echo
ok "Instalación terminada."
info "Siguiente paso: guía de configuración inicial → setup/configuracion-inicial.md"
