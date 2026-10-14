# Instalación en macOS

**Curso:** K8S-LOCAL-DEPLOY-01 · **SO:** macOS 13+ (Apple Silicon o Intel)
**Tiempo estimado:** 20–40 min (la primera arranca de colima tarda)

## Opción A — Instalador automático (recomendada)

```bash
cd <ruta-del-repo>
bash setup/install-macos.sh
bash setup/verificacion.sh
```

Variables opcionales:

```bash
# Elegir runtime de contenedores (colima = default, gratuito)
DOCKER_PROVIDER=orbstack bash setup/install-macos.sh
DOCKER_PROVIDER=desktop  bash setup/install-macos.sh   # Docker Desktop

# Ajustar recursos de la VM
COLIMA_CPUS=6 COLIMA_MEM=8192 bash setup/install-macos.sh
```

El instalador instala Homebrew si falta, luego `git`, `kubectl`, `kind`, `helm` y el runtime de contenedores.

## Opción B — Instalación manual

```bash
# 1) Homebrew (https://brew.sh)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2) Herramientas del curso (versiones congeladas: kubectl v1.31.4, kind v0.24.0, helm v3.16.4)
brew install git
brew install kubectl kind helm     # última versión (si usas brew, revisa el aviso inferior)

# 3) Runtime de contenedores (elige UNA opción)
brew install colima docker && colima start --cpu 4 --memory 6144   # recomendado
# brew install --cask orbstack
# brew install --cask docker                                        # Docker Desktop

# 4) Verificación
docker info && kind version && kubectl version --client && helm version
```

> **Aviso:** `brew install` entrega la última versión (Helm 4, kubectl más nueva que el
> clúster). El **instalador automático (Opción A)** instala en cambio las versiones
> congeladas del curso (`kubectl v1.31.4`, `kind v0.24.0`, `helm v3.16.4`), que es lo
> recomendado para seguir las guías sin sorpresas.

## Recursos y licencias

| Opción | Coste | Notas |
|---|---|---|
| **colima** (default) | Gratis | VM ligera con Lima; suficiente para 1 clúster kind |
| OrbStack | Gratis para uso personal; **de pago en empresa** | Muy rápido en Apple Silicon |
| Docker Desktop | Gratis solo equipos pequeños/educación | Revisa licencia si lo usas en empresa |

> El curso funciona igual con las tres opciones: los labs solo requieren un `docker` funcional.

## Problemas típicos en macOS

| Síntoma | Fix |
|---|---|
| `colima: command not found` | `brew install colima docker` y abre una terminal nueva |
| `Cannot connect to the Docker daemon` | `colima start` o abre Docker Desktop/OrbStack |
| `kind create` muy lento o falla por RAM | cierra apps y repite con `COLIMA_MEM=8192` |
| Apple Silicon + imagen `amd64` | funciona por emulación (lento); usa imágenes `arm64` cuando puedas |
| `brew` pidiendo CommandLineTools | acepta la instalación de Xcode CLI y repite |

## Verificación final

```bash
bash setup/verificacion.sh
```

Salida esperada: todos los checks en `[OK]`, incluido `cluster temporal creado y borrado`.

Siguiente paso → [configuracion-inicial.md](configuracion-inicial.md)
