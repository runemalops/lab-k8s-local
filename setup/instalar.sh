#!/usr/bin/env bash
# Curso K8S-LOCAL-DEPLOY-01 · Instalador unificado (detecta el SO)
# Uso:  bash setup/instalar.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

case "$OS" in
  Linux)
    echo "Sistema detectado: Linux"
    bash "$HERE/install-linux.sh"
    ;;
  Darwin)
    echo "Sistema detectado: macOS"
    bash "$HERE/install-macos.sh"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    echo "Sistema detectado: Windows (Git Bash / PowerShell)"
    echo "→ Ejecuta en PowerShell como Administrador:"
    echo "     Set-ExecutionPolicy -Scope Process Bypass"
    echo "     .\\setup\\install-windows.ps1"
    exit 1
    ;;
  *)
    echo "SO no reconocido: $OS"
    echo "Consulta las guías manuales: setup/instalacion-*.md"
    exit 1
    ;;
esac
