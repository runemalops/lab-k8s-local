# Lab 02 · Clúster local con kind

**Módulo:** M03 · **Día:** 1 · **Duración en aula:** 15 min (bloque D1 de 2 h)
**Guía:** alumno · **Carpeta:** `labs/lab02-kind/`

---

## 🎯 Objetivo

Crear, inspeccionar, conmutar y destruir un clúster local de forma **repetible en menos de
2 minutos**. Entender que los "nodos" de tu clúster son, en el fondo, contenedores Docker.

## 🧰 Prerrequisitos

- `bash setup/verificacion.sh` en verde.
- Docker corriendo.

## 📋 Pasos

### 1. Crea el clúster del curso

```bash
cd labs/lab02-kind
kind create cluster --name curso-k8s --config kind-config.yaml
```

> Si prefieres el modo mínimo: `kind create cluster --name curso-k8s` (sin `--config`).
> Con `kind-config.yaml` el nodo expone los puertos 80/443 en `localhost`, lo que
> facilitará el lab de Ingress (lab 06).

**Objetivo de tiempo: <2 min.**

### 2. Mira qué pasó por dentro

```bash
docker ps                        # los "nodos" son contenedores
kind get clusters
kubectl cluster-info
kubectl get nodes -o wide
kubectl config get-contexts
kubectl config current-context
```

Responde mientras miras la salida:
- ¿Cuántos nodos hay y cómo se llaman?
- ¿Qué proceso corre en el nodo `control-plane`?
- ¿Qué cambió en tu `~/.kube/config`?

### 3. Practica la conmutación de contexto

Crea un segundo clúster temporal y juega con los contextos:

```bash
kind create cluster --name practica --wait 120s
kubectl config get-contexts
kubectl get nodes                       # ¿qué clúster ves?
kubectl config use-context kind-curso-k8s
kubectl get nodes                       # ¿y ahora?
kind delete cluster --name practica
kubectl config use-context kind-curso-k8s   # vuelve al del curso
```

### 4. Destruye y recrea (infraestructura efímera)

```bash
kind delete cluster --name curso-k8s
kind get clusters          # debe salir vacío
time kind create cluster --name curso-k8s --config kind-config.yaml
```

**Meta:** el ciclo completo en menos de 2 minutos.

### 5. Comprueba que el clúster funciona

```bash
kubectl create deployment smoke --image=nginx:1.27 --replicas=1
kubectl get pods -o wide
kubectl delete deployment smoke
```

## 📦 Entregable

- Salida de `kubectl get nodes -o wide` con **dos contextos** creados.
- Tiempo del ciclo delete → create (anótalo en `evidence.txt`).
- Respuesta corta: *¿qué relación hay entre `docker ps` y `kubectl get nodes`?*

## ⚠️ Errores comunes

| Error | Causa | Fix |
|---|---|---|
| `Cannot connect to the Docker daemon` | Docker apagado | `sudo systemctl start docker` / `colima start` / abre Ubuntu en WSL2 |
| `kubectl` apunta al clúster equivocado | Contexto incorrecto | `kubectl config use-context kind-curso-k8s` |
| El clúster tarda o se queda `NotReady` | Poca RAM o WSL2 saturado | `kind delete cluster --all`, cierra apps, reintenta |
| Quedan clústeres olvidados | Borrados a medias | `kind get clusters` + `kind delete cluster --all` |
| `unknown flag --config` | kind desactualizado | reinstala con `FORCE=1 bash setup/install-linux.sh` |

## 🧹 Limpieza

Al **final del día** (regla 5 del laboratorio):

```bash
kind delete cluster --name curso-k8s
docker ps -a
```

## 🔗 Siguiente

→ `labs/lab03-kubectl/` — usar kubectl sobre ese clúster.
