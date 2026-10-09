# Estructura del curso — Lado del estudiante

**Curso:** Introducción a Kubernetes como herramienta de Deployment (entorno local)
**Propósito:** tu hoja de ruta: qué instalar, qué entregar cada día, cómo estudiar y cómo cerrar tu laboratorio.

---

## 1. Bienvenida y qué esperar

- **Qué aprenderás:** llevar una aplicación de tu editor de código a un clúster Kubernetes real (local, en tu laptop), con despliegues versionados, configuración externa, empaquetado (Helm/Kustomize) y automatización (CI/CD).
- **Qué NO es este curso:** administración avanzada de clusters, certificaciones oficiales, ni despliegue en la nube (ver "continuidad" en §8).
- **Compromiso:** ~2 h de práctica extra entre día y día. Quien solo asiste a clase no alcanza el proyecto final.

---

## 2. Instalación previa (una semana antes)

### 2.1 Instala por tu sistema
| SO | Guía | Notas clave |
|---|---|---|
| Linux | `setup/instalacion-linux.md` | Docker Engine + kind + kubectl + helm |
| macOS | `setup/instalacion-macos.md` | Docker Desktop / OrbStack / colima |
| Windows | `setup/instalacion-windows-wsl2.md` | **WSL2 + Ubuntu obligatorio**; trabajar siempre dentro de WSL2 |

### 2.2 Verificación (ejecuta y guarda la salida)

```bash
bash setup/verificacion.sh
```

Salida esperada (todas en verde):
```
[OK] docker
[OK] kind
[OK] kubectl
[OK] helm
[OK] git
[OK] cluster temporal creado y borrado
```

### 2.3 Requisitos de equipo
- 8 GB RAM (16 recomendados), 4 cores, 10 GB de disco libre, virtualización habilitada.
- Si tu equipo no cumple: avisa en T-5 para asignarte pareja o alternativa con minikube.

---

## 3. Estructura de los 4 días (vista estudiante)

| Día | Tema | Entregable (antes de las 17:00) |
|---|---|---|
| **1** | Contenedores + arquitectura K8s + tu primer clúster (kind) + primer deployment | `deployment.yaml` + `service.yaml` + `evidence.txt` |
| **2** | Modelo declarativo, configuración, exposición (Ingress), rollout y rollback | App de 2 servicios (5 manifiestos) + evidencia de rollback |
| **3** | Helm, Kustomize multi-entorno y pipeline CI/CD | Chart o estructura Kustomize + pipeline con job verde |
| **4** | Observabilidad, debugging, seguridad, proyecto final | Repo del proyecto + demo + limpieza firmada |

### Rutina diaria recomendada
- **Antes de clase (30 min):** leer el resumen del módulo en `02_guia_de_contenidos_y_modulos.md`.
- **Durante:** toma notas de errores y soluciones (será tu cheat-sheet).
- **Después (1–2 h):** repetir el lab sin seguir la guía y subir el entregable al repo.

---

## 4. Reglas del laboratorio

1. Un clúster: `kind create cluster --name curso-k8s` (no crees clústeres con otros nombres).
2. Un namespace por ejercicio: `lab01`, `lab02`, … → limpiar es un solo comando.
3. Todo manifiesto va a tu repo Git; nada importante solo en la terminal.
4. Imágenes siempre con **tag explícito** (`nginx:1.27`, nunca `nginx:latest` en entregables).
5. Al final de cada día: borra namespaces y **recrea el clúster** (practica el ciclo completo).
6. Pide ayuda con el formato: *qué hice → qué esperaba → qué pasó → comando exacto*.

---

## 5. Entregables en detalle

### Día 1
- [ ] `deployment.yaml` y `service.yaml` en `labs/lab04/` de tu repo.
- [ ] `evidence.txt` con salida de `kubectl get all -n lab04`.
- [ ] Captura de tu cluster recreado desde cero (<2 min).

### Día 2
- [ ] App de 2 servicios: deployments, services, configmap, secret, ingress.
- [ ] Evidencia de rollback: `kubectl rollout history` + la versión final activa.
- [ ] `notes-errors.md` con 3 errores que te hayan costado y su solución.

### Día 3
- [ ] Chart Helm **o** estructura Kustomize con `dev` y `staging`.
- [ ] Pipeline CI/CD ejecutado (captura verde + una roja de validación fallida).
- [ ] Comandos de reproducción en el README.

### Día 4 (proyecto final)
- [ ] Repo completo según especificación (rúbrica en `01_plan_de_contenidos.md` §7).
- [ ] Evidencia de un despliegue roto provocado + cómo lo resolviste.
- [ ] Demo de 5 minutos.
- [ ] Checklist de limpieza final (§6).

**Formato mínimo de evidencia:** archivo `evidence.txt` con fecha, comando y salida (o captura PNG en la misma carpeta).

---

## 6. Checklist de limpieza (obligatorio cada día)

```bash
# 1) Borrar namespaces de labs
kubectl delete ns lab01 lab02 lab03 lab04 lab05 lab06 lab07 --ignore-not-found
kubectl delete ns lab08 lab09 lab10 lab11 lab12 --ignore-not-found

# 2) Liberar releases de Helm
helm list -A
helm uninstall <release> -n <ns>

# 3) Destruir el clúster
kind delete cluster --name curso-k8s

# 4) Verificar
kubectl config get-contexts
docker ps -a     # no deben quedar nodos kind
```

**Por qué importa:** un clúster olvidado consume 2–4 GB de RAM y confunde los ejercicios del día siguiente.

---

## 7. Troubleshooting rápido del alumno

| Síntoma | Causa probable | Fix rápido |
|---|---|---|
| `docker: command not found` / daemon caído | Docker no instalado/corriendo | Iniciar Docker Desktop o `sudo systemctl start docker` |
| `kind: cannot connect` | WSL2 sin Docker, o clúster borrado | `docker ps` y `kind create cluster --name curso-k8s` |
| `ImagePullBackOff` | tag inexistente o typo | `kubectl describe pod <p>` → revisar imagen |
| Pod `Pending` | recursos/replicas sin sitio | `kubectl describe` → mira eventos |
| `404` en Ingress | host/path mal o falta controller | `curl -H "Host: app.local" ...` y revisa `ingressClassName` |
| `kubectl` apunta a otro clúster | contexto incorrecto | `kubectl config use-context kind-curso-k8s` |
| Mucha RAM consumida | clústeres/contenedores de más | limpieza §6 + `docker system prune -f` |
| Windows: comandos no funcionan | estás en PowerShell en vez de WSL2 | abre Ubuntu (WSL2) y repite |

**Pedir ayuda eficaz:** pega el comando + salida completa (sin borrar líneas de error) y di qué esperabas.

---

## 8. Continuidad (después del curso)

1. **Consolidar:** repite el proyecto en un repo personal con otra app tuya.
2. **Certificación:** ruta CKAD → CKA (Kubernetes official).
3. **Nube:** mismo despliegue en AKS/EKS/GKE + IaC con Terraform/OpenTofu (curso siguiente).
4. **GitOps:** automatiza con Flux o ArgoCD lo que hoy haces con `kubectl apply` desde CI.
5. **Observabilidad:** añade Prometheus + Grafana sobre tu clúster local.
