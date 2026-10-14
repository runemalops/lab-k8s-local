# Troubleshooting de la instalación

**Curso:** K8S-LOCAL-DEPLOY-01 · Errores frecuentes **antes** del Día 1, por SO.

---

## Diagnóstico rápido

```bash
bash setup/verificacion.sh
```

Cada `[FAIL]` indica la sección de abajo que te toca.

---

## Docker / runtime de contenedores

| Síntoma | Causa | Fix |
|---|---|---|
| `docker: command not found` | No instalado | `bash setup/install-linux.sh` (o brew en macOS) |
| `Cannot connect to the Docker daemon` | Daemon caído | Linux: `sudo systemctl start docker` · macOS: `colima start` / abre Docker Desktop · Windows: `wsl --shutdown` y reabre Ubuntu |
| `permission denied while trying to connect to the Docker daemon` | Sin permisos de grupo | `sudo usermod -aG docker $USER` y **cierra sesión** (o `newgrp docker`) |
| `docker info` cuelga (WSL2) | Backend roto | `wsl --shutdown`, reabre Ubuntu |
| `colima start` falla por RAM | Poca memoria | `colima delete && colima start --memory 4096` |
| `This version of Docker is not supported` (macOS) | Docker Desktop caducado | Actualízalo o cambia a `DOCKER_PROVIDER=colima` |

## kind

| Síntoma | Causa | Fix |
|---|---|---|
| `kind: command not found` | No instalado / PATH | Reejecuta `install-*.sh`; comprueba `echo $PATH` |
| `failed to create cluster: node "..." not ready` | Recursos bajos | `kind delete cluster --all`; cierra apps; reintenta |
| `ERROR: unknown flag: --name` | kind v0.11 o anterior | Reinstala kind `v0.24.0` |
| `Cannot connect to the Docker daemon` al crear clúster | Docker caído | Ver fila anterior |
| Clústeres viejos comen RAM | Olvidos | `kind get clusters && kind delete cluster --all` |

## kubectl

| Síntoma | Causa | Fix |
|---|---|---|
| `The connection to the server ... was refused` | Sin clúster o contexto malo | `kind create cluster --name curso-k8s` y `kubectl config use-context kind-curso-k8s` |
| `kubectl apunta a otro clúster` | Contexto equivocado | `kubectl config get-contexts` → `use-context` |
| `error: no context exists` | kubeconfig vacío | Borra clúster y recrea: `kind delete/create cluster --name curso-k8s` |
| `kubectl kustomize` no existe | kubectl antiguo | Actualiza kubectl al `stable` actual |

## Helm

| Síntoma | Causa | Fix |
|---|---|---|
| `helm: command not found` | No instalado | `bash setup/install-*.sh` o `brew install helm` |
| `lock file ... helm.lock` | Instalación concurrente | Borra `~/.cache/helm/locks` y reintenta |
| `network timeouts` al instalar charts | Firewall/proxy | Revisa `HTTPS_PROXY`; prueba con `helm repo update` |

## WSL2 / Windows

| Síntoma | Causa | Fix |
|---|---|---|
| `wsl --install` no arranca | Falta virtualización | Activa VT-x/AMD-V en BIOS; actualiza Windows |
| Distro Ubuntu pide crear usuario al abrirse | Primera ejecución | Crea el usuario (sin usarlo como root en los labs) |
| Los scripts .ps1 no ejecutan | Política de ejecución | `Set-ExecutionPolicy -Scope Process Bypass` |
| Dentro de WSL no veo el disco de Windows | — | Rutas `/mnt/c/...` (preferible: clonar en `~/`) |
| `apt-get` con errores de firma/404 | Reloj desincronizado | `sudo hwclock -s` o reinicia Windows |
| `This update does not apply` en wsl | Versión vieja | `wsl --update` |

## macOS

| Síntoma | Causa | Fix |
|---|---|---|
| `xcrun: invalid active developer path` | Falta Xcode CLI | `xcode-select --install` |
| `brew: command not found` | PATH de Homebrew | `eval "$(/opt/homebrew/bin/brew shellenv)"` (Apple Silicon) |
| `permission denied` en `/usr/local/bin` | Permisos | Instala con `BIN_DIR=$HOME/.local/bin` |
| Colima no arranca tras actualizar macOS | VM dañada | `colima delete && colima start` |

## Recursos y red

| Síntoma | Fix |
|---|---|
| Poca RAM al crear el clúster | `kind delete cluster --all`, `docker system prune -f`, cierra navegadores |
| `ImagePullBackOff` en verificación | Sin internet o tag mal escrito → revisa `docker pull nginx:1.27` |
| Proxy corporativo | Exporta `HTTPS_PROXY`, `NO_PROXY=localhost,127.0.0.1,10.0.0.0/8` |
| Descargas muy lentas | Usa el mirror/red del aula o pide el paquete offline al instructor |

## Último recurso (estado "cero")

```bash
kind delete cluster --all
docker system prune -af
rm -rf ~/.kube/cache        # solo borra caché, no tu kubeconfig
FORCE=1 bash setup/install-linux.sh    # en macOS: FORCE=1 bash setup/install-macos.sh
bash setup/verificacion.sh
```

> Si tras esto sigue fallando, avisa **antes del Día 1** con la salida completa de
> `bash setup/verificacion.sh` (formato de ayuda: *qué instalé → qué esperaba → qué pasó*).
