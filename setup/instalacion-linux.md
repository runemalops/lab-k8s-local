# Instalación en Linux

**Curso:** K8S-LOCAL-DEPLOY-01 · **SO:** Ubuntu/Debian, Fedora, Arch o derivados
**Tiempo estimado:** 15–25 min · **Conexión:** sí (descargas)

## Opción A — Instalador automático (recomendada)

```bash
cd <ruta-del-repo>
bash setup/install-linux.sh
bash setup/verificacion.sh
```

El instalador:
1. Detecta tu arquitectura (`amd64`/`arm64`).
2. Instala **Docker Engine** si no existe (script oficial `get.docker.com`) y te añade al grupo `docker`.
3. Instala **kubectl** (`v1.31.4`, alineado al clúster), **kind** (`v0.24.0`) y **Helm** (`v3.16.4`) en `/usr/local/bin`.
4. Comprueba que `kubectl kustomize` funcione (Kustomize viene embebido).
5. Ejecuta la verificación final.

Variables opcionales (versiones congeladas del curso, cámbialas solo si tu instructor lo indica):

```bash
KIND_VERSION=v0.24.0 KUBECTL_VERSION=v1.31.4 HELM_VERSION=v3.16.4 bash setup/install-linux.sh
KUBECTL_CHANNEL=stable bash setup/install-linux.sh   # última kubectl estable
SKIP_DOCKER=1 bash setup/install-linux.sh            # si Docker ya está instalado
```

> **Tras instalar Docker cierra sesión y vuelve a entrar** para que el grupo `docker` surta efecto.
> Si prefieres no cerrar sesión: `newgrp docker`.

## Opción B — Instalación manual

```bash
# 1) Docker Engine
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER   # relogin después

# 2) kubectl (versión alineada al clúster kind del curso: K8s 1.31.x)
curl -LO "https://dl.k8s.io/release/v1.31.4/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# 3) kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind

# 4) Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sudo bash
```

## Opciones alternativas

| Situación | Alternativa |
|---|---|
| Sin privilegios (`sudo`) | pide al administrador o usa la instalación en `~/.local/bin` (exporta `BIN_DIR=$HOME/.local/bin`) |
| Fedora/RHEL con `podman-docker` | instala Docker Engine real o usa `minikube --driver=podman` (modo compatible) |
| Empresa con proxy | exporta `HTTPS_PROXY`/`NO_PROXY` antes de instalar |
| Equipo con poca RAM (≤8 GB) | reserva ≥4 GB libres; cierra el navegador durante los labs |

## Verificación final

```bash
bash setup/verificacion.sh
```

Salida esperada (todo `[OK]`):

```
[OK] docker
[OK] kind
[OK] kubectl
[OK] helm
[OK] git
[OK] kustomize (embebido en kubectl)
[OK] daemon Docker respondiendo
[OK] cluster temporal creado y borrado
```

Siguiente paso → [configuracion-inicial.md](configuracion-inicial.md)
