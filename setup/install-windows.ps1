# Curso K8S-LOCAL-DEPLOY-01 · Instalación de tooling en Windows (WSL2 + Ubuntu)
# Ejecutar en PowerShell COMO ADMINISTRADOR.
#   Set-ExecutionPolicy -Scope Process Bypass
#   .\setup\install-windows.ps1
#
# Qué hace:
#   1) Habilita WSL2 y la plataforma de máquina virtual.
#   2) Instala la distribución Ubuntu (si no existe).
#   3) Copia los scripts del curso dentro de WSL y ejecuta install-linux.sh.
#   (Si pide reinicio, vuelve a lanzar el mismo script tras el reboot.)

$ErrorActionPreference = "Stop"

function Write-Ok($m)   { Write-Host "[OK] $m"    -ForegroundColor Green }
function Write-Info($m) { Write-Host "[INFO] $m"  -ForegroundColor Cyan }
function Write-Warn($m) { Write-Host "[AVISO] $m" -ForegroundColor Yellow }
function Write-Err($m)  { Write-Host "[ERROR] $m" -ForegroundColor Red }

$Distro = "Ubuntu"
$ScriptRoot = $PSScriptRoot
if (-not $ScriptRoot) { $ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path }

Write-Host "=== Instalacion de tooling del curso (Windows + WSL2) ===" -ForegroundColor White

# --- 1. Estado de WSL -------------------------------------------------------
$wslOk = $false
try { $null = wsl --status 2>$null; $wslOk = $true } catch { $wslOk = $false }

$hasDistro = $false
try {
  $list = wsl --list --quiet 2>$null
  if ($list -and ($list -match $Distro)) { $hasDistro = $true }
} catch { $hasDistro = $false }

if (-not $hasDistro) {
  Write-Info "Habilitando WSL2 e instalando $Distro (puede pedir reinicio)..."
  try {
    wsl --install -d $Distro --no-launch
    Write-Ok "Distribucion $Distro instalada/registrada."
  } catch {
    Write-Warn "Fallo directo de 'wsl --install'. Probando por caracteristicas de Windows..."
    $needRestart = $false
    if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -ne "Enabled") {
      Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | Out-Null
      $needRestart = $true
    }
    if ((Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -ne "Enabled") {
      Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart | Out-Null
      $needRestart = $true
    }
    if ($needRestart) {
      Write-Warn "Reinicia el equipo y vuelve a ejecutar este script."
      exit 1
    }
    wsl --install -d $Distro --no-launch
  }
}

# --- 2. Arranque y usuario ---------------------------------------------------
Write-Info "Inicializando $Distro (primera ejecucion: tarda 1-3 min)..."
wsl -d $Distro -u root -- echo "wsl-ok" | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Warn "Si Windows pide un reinicio, reinicia y vuelve a lanzar el script."
  exit 1
}
Write-Ok "WSL2 listo."

# --- 3. Dependencias minimas dentro de WSL ----------------------------------
Write-Info "Instalando dependencias basicas en WSL (curl, git, ca-certificates)..."
wsl -d $Distro -u root -- bash -lc "apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl git ca-certificates gnupg sudo >/dev/null"
Write-Ok "Dependencias basicas."

# --- 4. Copiar los scripts del curso a un sitio accesible dentro de WSL ------
$workdirWsl = "/tmp/curso-k8s-setup"
$mk = wsl -d $Distro -u root -- bash -lc "mkdir -p $workdirWsl && chmod 777 $workdirWsl"
$src = (Join-Path $ScriptRoot "install-linux.sh")
$ver = (Join-Path $ScriptRoot "verificacion.sh")

if (Test-Path $src) {
  # Ruta de Windows -> ruta WSL (C:\foo -> /mnt/c/foo)
  $winPath = $src -replace '\\', '/'
  if ($winPath -match '^([A-Za-z]):') {
    $drive = $Matches[1].ToLower()
    $wslPath = "/mnt/$drive" + ($winPath -replace '^[A-Za-z]:', '')
    Write-Info "Scripts detectados en: $wslPath"
    wsl -d $Distro -u root -- bash -lc "cp '$wslPath/install-linux.sh' '$wslPath/verificacion.sh' $workdirWsl/ 2>/dev/null; chmod +x $workdirWsl/*.sh"
  }
} else {
  Write-Warn "No encuentro install-linux.sh junto a este .ps1; se descargara desde el repo del curso."
}

# Si no se pudieron copiar, clonar el repo (requiere que exista un remoto)
$hasInstaller = wsl -d $Distro -u root -- bash -lc "test -f $workdirWsl/install-linux.sh && echo yes"
if ("$hasInstaller" -notmatch "yes") {
  Write-Warn "No se pudieron copiar los scripts. Copia manualmente la carpeta 'setup' dentro de WSL"
  Write-Warn "  y ejecuta:  bash setup/install-linux.sh"
} else {
  Write-Info "Ejecutando install-linux.sh dentro de WSL..."
  wsl -d $Distro -- bash -lc "bash $workdirWsl/install-linux.sh"
}

Write-Host ""
Write-Ok "Instalacion terminada."
Write-Info "Trabajo SIEMPRE dentro de WSL: abre 'Ubuntu' (no PowerShell) para los labs."
Write-Info "Siguiente paso: setup/configuracion-inicial.md"
