#!/usr/bin/env bash
# Curso K8S-LOCAL-DEPLOY-01 · Instalación de tooling en macOS
# Uso:  bash setup/install-macos.sh
# Runtime de contenedores: DOCKER_PROVIDER=colima (default) | orbstack | desktop
# Helm/Kubectl/kind se instalan en las versiones congeladas del curso.
set -euo pipefail

# Versiones congeladas del curso (ver 03_estructura_instructor.md §1.3)
KUBECTL_VERSION="${KUBECTL_VERSION:-v1.31.4}"
KIND_VERSION="${KIND_VERSION:-v0.24.0}"
HELM_VERSION="${HELM_VERSION:-v3.16.4}"

DOCKER_PROVIDER="${DOCKER_PROVIDER:-colima}"
SKIP_DOCKER="${SKIP_DOCKER:-0}"
COLIMA_CPUS="${COLIMA_CPUS:-4}"
COLIMA_MEM="${COLIMA_MEM:-6144}"

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

[ "$(uname -s)" = "Darwin" ] || die "Este script es para macOS. Usa setup/install-linux.sh en Linux."
command -v curl >/dev/null 2>&1 || die "Falta 'curl'."
command -v tar   >/dev/null 2>&1 || die "Falta 'tar'."

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) KARCH="amd64" ;;
  arm64)  KARCH="arm64" ;;
  *) die "Arquitectura no soportada: $ARCH" ;;
esac

# Directorio de destino: HOME/.local/bin si no podemos escribir en el estándar
if [ -n "${BIN_DIR:-}" ]; then
  :
elif [ -w /usr/local/bin ] 2>/dev/null; then
  BIN_DIR=/usr/local/bin
elif [ -w "/opt/homebrew/bin" ] 2>/dev/null; then
  BIN_DIR=/opt/homebrew/bin
else
  BIN_DIR="$HOME/.local/bin"
fi
mkdir -p "$BIN_DIR" 2>/dev/null || true

install_bin() { # install_bin <archivo-tmp> <nombre>
  if [ -w "$BIN_DIR" ]; then mv "$1" "$BIN_DIR/$2"; else sudo mv "$1" "$BIN_DIR/$2"; fi
}

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) export PATH="$BIN_DIR:$PATH"
     warn "$BIN_DIR no está en tu PATH. Añade a ~/.zshrc:  export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac

# ---------------------------------------------------------------- Homebrew
install_brew() {
  if command -v brew >/dev/null 2>&1; then
    ok "Homebrew ($(brew --version | head -1 | cut -d' ' -f2))"
    return
  fi
  info "Instalando Homebrew… (pedirá tu contraseña)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  case "$ARCH" in
    arm64) eval "$(/opt/homebrew/bin/brew shellenv)" ;;
    *)     eval "$(/usr/local/bin/brew shellenv)" ;;
  esac
  command -v brew >/dev/null 2>&1 || die "Homebrew no quedó en el PATH. Abre una terminal nueva y vuelve a ejecutar."
  ok "Homebrew instalado"
}

brew_ensure() {
  local cask="" pkg="$1"
  if [ "$1" = "--cask" ]; then cask="--cask"; pkg="$2"; fi
  if brew list $cask "$pkg" >/dev/null 2>&1; then
    ok "$pkg"
  else
    info "brew install $cask $pkg"
    brew install $cask "$pkg"
    ok "$pkg"
  fi
}

# ---------------------------------------------------------------- Docker
install_docker() {
  [ "$SKIP_DOCKER" = "1" ] && { warn "SKIP_DOCKER=1 → no se instala runtime de contenedores."; return; }

  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    ok "docker funcionando ($(docker --version 2>/dev/null | head -1))"
    return
  fi

  case "$DOCKER_PROVIDER" in
    orbstack)
      brew_ensure --cask orbstack || die "No se pudo instalar OrbStack: https://orbstack.dev"
      open -a OrbStack 2>/dev/null || true
      ;;
    desktop)
      brew_ensure --cask docker || die "No se pudo instalar Docker Desktop: https://docs.docker.com/get-docker/"
      open -a Docker 2>/dev/null || true
      ;;
    colima|*)
      brew_ensure colima
      brew_ensure docker
      if ! colima status >/dev/null 2>&1; then
        info "Arrancando colima (${COLIMA_CPUS} CPUs, ${COLIMA_MEM} MB RAM)… la primera vez tarda unos minutos"
        colima start --cpu "$COLIMA_CPUS" --memory "$COLIMA_MEM"
      fi
      ;;
  esac

  for _ in $(seq 1 30); do
    docker info >/dev/null 2>&1 && break
    sleep 2
  done
  docker info >/dev/null 2>&1 && ok "daemon Docker respondiendo" \
    || warn "El daemon Docker aún no responde. Ábrelo (Docker Desktop/OrbStack) o ejecuta: colima start"
}

# ---------------------------------------------------------------- kubectl
install_kubectl() {
  if command -v kubectl >/dev/null 2>&1 && [ "${FORCE:-0}" != "1" ]; then
    ok "kubectl ($(kubectl version --client -o yaml 2>/dev/null | grep gitVersion | head -1 | awk '{print $2}'))"
    return
  fi
  info "kubectl ${KUBECTL_VERSION} (${KARCH})"
  curl -fsSLo /tmp/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/darwin/${KARCH}/kubectl"
  chmod +x /tmp/kubectl
  install_bin /tmp/kubectl kubectl
  ok "kubectl $(kubectl version --client -o yaml 2>/dev/null | grep gitVersion | head -1 | awk '{print $2}')"
}

# ---------------------------------------------------------------- kind
install_kind() {
  if command -v kind >/dev/null 2>&1 && [ "${FORCE:-0}" != "1" ]; then
    ok "kind ($(kind version))"
    return
  fi
  info "kind ${KIND_VERSION} (${KARCH})"
  curl -fsSLo /tmp/kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-darwin-${KARCH}"
  chmod +x /tmp/kind
  install_bin /tmp/kind kind
  ok "kind $(kind version)"
}

# ---------------------------------------------------------------- Helm
install_helm() {
  if command -v helm >/dev/null 2>&1 && [ "${FORCE:-0}" != "1" ]; then
    ok "helm ($(helm version --short 2>/dev/null))"
    return
  fi
  info "Helm ${HELM_VERSION} (${KARCH})"
  curl -fsSLo /tmp/helm.tgz "https://get.helm.sh/helm-${HELM_VERSION}-darwin-${KARCH}.tar.gz"
  mkdir -p /tmp/helm-extract && tar -xzf /tmp/helm.tgz -C /tmp/helm-extract
  mv "/tmp/helm-extract/darwin-${KARCH}/helm" /tmp/helm && chmod +x /tmp/helm
  rm -rf /tmp/helm.tgz /tmp/helm-extract
  install_bin /tmp/helm helm
  ok "helm $(helm version --short 2>/dev/null)"
}

# ---------------------------------------------------------------- main
echo "=== Instalación de tooling del curso (macOS / ${KARCH}) ==="
install_brew
brew_ensure git
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
info "kustomize viene incluido en kubectl:  kubectl kustomize --help"
