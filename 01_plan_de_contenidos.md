# Curso: Introducción a Kubernetes como herramienta de Deployment (entorno local)

**Duración:** 5 días × 2 h = **10 h** de clase (más ~3 h de material asíncrono opcional)
**Formato:** Teoría comprimida en clase + laboratorios 100% en equipos locales (sin nube, sin costo)
**Audiencia:** Estudiantes de ingeniería y developers en formación (últimos semestres / junior)
**Nivel:** Básico. No requiere experiencia previa en Kubernetes ni Docker avanzado.

> **Modelo de 10 h (alcance reducido):** el tiempo de aula es escaso, así que la clase es
> **teoría esencial + práctica guiada**; las extensiones (kubectl a fondo, Kustomize,
> probes/OOMKilled, plantillas Helm avanzadas, casos extra de debugging) quedan como
> **material asíncrono** para profundizar.

---

## 1. Ficha técnica

| Campo | Detalle |
|---|---|
| Código | K8S-LOCAL-DEPLOY-01 (formato express 5×2 h) |
| Duración | 5 días × 2 h (10 h efectivas de aula) |
| Horario sugerido | 2 h continuas por día (p. ej. 18:00–20:00 laboral o 10:00–12:00) |
| Modalidad | Presencial u online, cada alumno con su propio equipo |
| Idioma | Español (terminología técnica en inglés) |
| Enfoque | Kubernetes como **herramienta de deployment**: de la imagen al despliegue versionado y automatizado |
| Entorno | Clúster local: **kind** (principal); alternativas minikube / Docker Desktop / k3d |
| Tooling | Docker/colima, kubectl, kind, helm, Git, editor (VS Code) |
| Evaluación | 60% laboratorios y participación + 40% proyecto final (Día 5) |
| Materiales | Repo de alumnos: esqueletos de manifiestos, chart Helm, pipeline, starter del proyecto |

### Por qué Kubernetes **local** (y no nube)
- **Cero costo y cero fricción:** sin créditos, cuotas ni sorpresas de facturación.
- **Reproducibilidad:** todos los alumnos corren exactamente lo mismo en su equipo.
- **Foco en deployment:** el alumno entiende *qué* despliega y *cómo* antes de preocuparse por *dónde* corre.
- **Puente natural:** lo aprendido aquí aplica igual a AKS, EKS, GKE o Rancher (Día 5: ruta de migración).

### Por qué este curso y no uno de "administrar clusters"
- El objetivo del alumno es **llevar código de desarrollo a un entorno ejecutable**: manifiestos,
  paquetes (Helm), versionado, exponer, diagnosticar y automatizar.
- El clúster es *inbox* de despliegue; la administración profunda (etcd, upgrades, certificados)
  queda fuera de alcance.

---

## 2. Objetivos de aprendizaje

Al finalizar, el alumno será capaz de:

1. Explicar la diferencia entre contenedor, imagen y clúster; y describir la arquitectura
   de Kubernetes (control plane vs nodos) a grandes rasgos.
2. Operar un clúster local con **kind** y usar `kubectl` con soltura en el flujo diario.
3. Desplegar una aplicación usando manifiestos declarativos (Deployment, Service, ConfigMap,
   Secret, Ingress, Namespace).
4. Gestionar el **ciclo de vida de un despliegue**: rollout y rollback versionando imágenes.
5. Empaquetar despliegues multi-entorno con **Helm** (values dev/staging).
6. Ejecutar un **pipeline de validación y despliegue** sobre el clúster local.
7. Diagnosticar despliegues fallidos (Pending, CrashLoopBackOff, ImagePullBackOff, Service sin
   endpoints) con `get → describe → events → logs`.
8. Aplicar higiene de seguridad básica (Secrets, RBAC mínimo, imágenes etiquetadas) y **cerrar el
   laboratorio sin dejar recursos**.

> Objetivo opcional (material asíncrono): 9. Empaquetar con **Kustomize** (base + overlays).

---

## 3. Prerrequisitos

### Del alumno
- Nivel medio de Linux/terminal (navegar, editar archivos, variables de entorno).
- Básicos de un lenguaje de programación (Python, JS o Java) para leer YAML.
- Git básico (clone, commit, push).
- **Opcional (ayuda, no bloquea):** Docker, red basics (HTTP, puertos, DNS).

### Del equipo del alumno (requisitos de hardware/software)
| Requisito | Mínimo | Recomendado |
|---|---|---|
| RAM libre | 8 GB total, 4 GB libres | 16 GB, 8 GB libres |
| CPU | 4 cores | 8 cores |
| SO | Windows 10/11, macOS, Linux | Linux o macOS |
| Virtualización | Habilitada (VT-x/AMD-V) | — |
| Disco libre | 10 GB | 20 GB |
| Internet | Sí (descargas de imágenes y tooling) | — |

> Windows: usar **WSL2 + Ubuntu** como entorno de trabajo (instrucciones en
`setup/instalacion-windows-wsl2.md`). Docker Desktop con WSL2 backend o colima/OrbStack en macOS.

### Del instructor
- Repo Git del curso con `labs/` (esqueleto + `solution/`), `slides/` y `project/`.
- Máquina demo proyectable con todo el tooling preinstalado y clúster kind corriendo.
- **Preparación extra por el formato comprimido (T-1):** ingress-nginx instalado, imágenes base
  precargadas (`nginx:1.27`, `nginx:1.27.0`, `nginx:1.27.1`, `hashicorp/http-echo:1.0`) y
  `bash labs/lab10-cicd/ci.sh` probado en verde. Cada minuto de aula cuenta.

---

## 4. Entorno de laboratorio (local)

### 4.1 Stack elegido y por qué

| Herramienta | Rol | Por qué esta opción |
|---|---|---|
| **kind** | Clúster local en Docker | Ligero, oficial CNCF, mismo código que usa CI (GitHub Actions); crea/borra clúster en segundos |
| Docker Desktop / colima / OrbStack / Rancher Desktop | Runtime de contenedores | Estándar de facto; alternativas según SO/licencia |
| kubectl | Cliente | Estándar único para cualquier clúster |
| helm | Empaquetado de despliegues | La herramienta de empaquetado más usada en la industria |
| kustomize | Alternativa de empaquetado | Material **asíncrono** en este formato (incluido en `kubectl`) |
| minikube / k3d / Docker Desktop K8s | Alternativas | Para alumnos sin privilegios o con restricciones; "modo compatible" |

### 4.2 Reglas de oro del laboratorio (se dictan el Día 1)
1. Un solo clúster kind por alumno, nombre `curso-k8s` (`kind create cluster --name curso-k8s`).
2. **Un namespace por ejercicio** (`lab01`, `lab02`, …) para poder limpiar con un solo comando.
3. Tags en manifiestos: `app.kubernetes.io/part-of: curso-k8s` para facilitar auditoría.
4. Imágenes siempre con **tag explícito** (nunca `:latest` en entregables).
5. Al final de cada día: `kind delete cluster --name curso-k8s` y volver a crearlo en 2 minutos
   (simula "infraestructura efímera").
6. Nada de `sudo` fuera de la instalación inicial; nada de modificaciones globales sin avisar.

### 4.3 Instalación de tooling (guía previa, enviada 1 semana antes)

```bash
bash setup/instalar.sh        # detecta el SO (Linux/macOS/WSL2)
bash setup/verificacion.sh    # todo debe salir en [OK]
```

Ver detalles por SO en `setup/instalacion-linux.md`, `setup/instalacion-macos.md` y
`setup/instalacion-windows-wsl2.md`; después, `setup/configuracion-inicial.md`.

### 4.4 Verificación previa (checklist del alumno)

```bash
kind create cluster --name check && kubectl cluster-info --context kind-check
kubectl create deployment check --image=nginx:1.27 --replicas=2
kubectl expose deployment check --port=80 --type=LoadBalancer
kubectl get all
kind delete cluster --name check
```

---

## 5. Plan de contenidos (módulos)

| # | Módulo | Día | Tipo | Modalidad |
|---|---|---|---|---|
| M01 | Contenedores, imágenes y artefactos de deployment | 1 | Teoría + lab local | Clase |
| M02 | Arquitectura de Kubernetes: control plane, nodos, desired state | 1 | Teoría | Clase |
| M03 | Clúster local con kind: instalación, ciclos de vida, alternativas | 1 | Lab guiado | Clase |
| M04 | kubectl: contexto, describir, logs, aplicar, eliminar | 1 | Teoría + lab | Clase (integrado en el lab04) |
| M05 | Primer deployment declarativo: Pod, Deployment, Service, Namespace | 1 | Lab guiado | Clase |
| M06 | K8s como herramienta de deployment: declarativo vs imperativo, desired state | 2 | Teoría | Clase (comprimido) |
| M07 | Configuración y secretos: ConfigMap, Secret, env vars, volúmenes | 2 | Teoría + lab | Clase |
| M08 | Exposición: ClusterIP/NodePort, port-forward, Ingress + ingress-nginx | 2 | Lab | Clase |
| M09 | Ciclo de vida: requests/limits, rollout, rollback, versionado de imágenes | 2 | Lab express | Clase (solo rollout/rollback; probes y OOMKilled → asíncrono) |
| M10 | Empaquetado con Helm: charts, values, upgrade y rollback | 3 | Teoría + lab | Clase (plantillas avanzadas → asíncrono) |
| M11 | Kustomize y multi-entorno: overlays dev/staging | 3 | Lab | **Asíncrono / opcional** |
| M12 | CI/CD que despliega: pipeline que valida y aplica al clúster | 4 | Teoría + lab | Clase |
| M13 | Observabilidad del despliegue: logs, events, describe, árbol de decisión | 4 | Teoría + lab | Clase |
| M14 | Debugging de despliegues fallidos y seguridad básica (RBAC, Secrets, imágenes) | 5 | Teoría + lab | Clase (2 casos + RBAC; casos 3–4 → asíncrono) |
| M15 | De local a producción: lo que cambia al llevar el despliegue a nube/CI real | 5 | Teoría | Clase (breve) |
| M16 | Proyecto final: app + manifiestos + Helm + pipeline + entrega | 5 | Lab evaluado | Clase (starter + ruta express) |

**Cobertura:** 15 módulos en aula + 1 asíncrono (M11) · 10 de los 12 labs en aula · 2 labs y
extensiones como ampliación opcional.

---

## 6. Programa día a día

> **Rutina diaria fija (2 h):**
> `0:00–0:05` warm-up + quiz del día anterior · `0:05–…` teoría esencial (25–35 min) ·
> `…–1:50` práctica guiada · `1:50–2:00` entregable, retro y **limpieza**.
> Cada día cierra con 5 min de Q&A y mini-retro.

---

### DÍA 1 — Del contenedor al primer despliegue (2 h)

**Meta:** clúster local corriendo y primer app desplegada con manifiestos declarativos.

| Hora | Bloque | Contenido | Actividad |
|---|---|---|---|
| 0:00 | Warm-up (5) | Reglas del laboratorio, quiz de prerrequisitos | Quiz |
| 0:05 | M01+M02 (25) | Contenedores vs VM, imagen/tag/registry; arquitectura K8s (API server, etcd, scheduler, nodos, desired state) | Diagrama + preguntas |
| 0:30 | M01 lab (15) | Dockerfile mínimo, build y etiquetado | **Lab01**: imagen `curso-web:1.0` |
| 0:45 | M03+M04 (10) | kind, kubeconfig/contextos; patrón `kubectl <verbo> <tipo> <nombre>` | Demo |
| 0:55 | M03 lab (15) | crear/borrar clúster, contextos | **Lab02**: `curso-k8s` + ciclo <2 min |
| 1:10 | M05 (10) | YAML mínimo línea a línea: Namespace/Deployment/Service | Demo |
| 1:20 | M05 lab (30) | desplegar nginx, port-forward, escalar, sabotaje | **Lab04** (incluye kubectl) |
| 1:50 | Cierre (10) | errores típicos, entregable, borrado y recreación del clúster | Retro |

**Entregable D1:** `deployment.yaml` + `service.yaml` + `evidence.txt` (`kubectl get all -n lab04`).
**Asíncrono (opcional):** lab03 (kubectl a fondo) + cheat-sheet personal.

---

### DÍA 2 — Configuración, exposición y ciclo de vida (2 h)

**Meta:** configurar sin reimágenes, exponer fuera del clúster y recuperarse de un mal release.

| Hora | Bloque | Contenido | Actividad |
|---|---|---|---|
| 0:00 | Warm-up (5) | Quiz D1 | Quiz |
| 0:05 | M06+M07 (25) | Imperativo vs declarativo, reconciliación, Git como fuente de verdad; ConfigMap/Secret, env vs volúmenes | Demo del sabotaje (borrar pods) |
| 0:30 | M07 lab (30) | config externa, secretos, propagación y `rollout restart` | **Lab05** |
| 1:00 | M08 (15) | Service types, DNS interno, Ingress + ingress-nginx | Demo |
| 1:15 | M08 lab (20) | exponer `app.local` con `/` y `/api` | **Lab06** (controlador preinstalado) |
| 1:35 | M09 (15) | requests/limits, RollingUpdate, `rollout status/history/undo`, tags inmutables | **Lab07 express**: rollout a v1 → fallo → undo |
| 1:50 | Cierre (10) | errores de red, limpieza de namespaces, entregable | Retro |

**Entregable D2:** manifiestos de config/exposición + evidencia de rollback
(`kubectl rollout history` + `undo`).
**Asíncrono (opcional):** lab07 completo (probes, OOMKilled, `set image` vs apply).

---

### DÍA 3 — Empaquetado de despliegues con Helm (2 h)

**Meta:** pasar de YAML sueltos a un paquete versionado y parametrizable por entorno.

| Hora | Bloque | Contenido | Actividad |
|---|---|---|---|
| 0:00 | Warm-up (5) | Quiz D2 | Quiz |
| 0:05 | M10 (25) | chart/values/release/repository, `install/upgrade/rollback/lint/template` | Demo: `helm create` podado |
| 0:30 | M10 lab · parte 1 (40) | chart del servicio web, parametrizar imagen y réplicas, `--set` | **Lab08-1** |
| 1:10 | M10 lab · parte 2 (35) | `values-dev.yaml` vs `values-staging.yaml`, upgrade y rollback | **Lab08-2** |
| 1:45 | Cierre (15) | debate: ¿cuándo Helm y cuándo YAML/Kustomize?; entregable | Retro |

**Entregable D3:** chart funcional con 2 archivos de values + evidencia de upgrade/rollback.
**Asíncrono (opcional):** plantillas avanzadas (helpers, condicionales) y **lab09 (Kustomize)**.

---

### DÍA 4 — CI/CD y diagnóstico del despliegue (2 h)

**Meta:** automatizar validación+despliegue y responder "¿qué está pasando?" en minutos.

| Hora | Bloque | Contenido | Actividad |
|---|---|---|---|
| 0:00 | Warm-up (5) | Quiz D3 | Quiz |
| 0:05 | M12 (20) | fases del pipeline, validación de manifiestos, kind en CI; demo GitOps (5 min) | Demo |
| 0:25 | M12 lab (35) | pipeline local (`ci.sh`) + workflow de GitHub Actions | **Lab10** |
| 1:00 | M13 (15) | logs/events/describe; flujo `get → describe → events → logs` | Demo del CrashLoopBackOff |
| 1:15 | M13 lab (30) | provocar fallo, diagnosticar, árbol de decisión de 1 página | **Lab11** |
| 1:45 | Cierre (15) | entregable (job verde + rojo), retro | Retro |

**Entregable D4:** pipeline ejecutado (captura verde + una roja) + `guia-diagnostico.md`.
**Asíncrono (opcional):** GitOps con Flux/ArgoCD en el equipo propio.

---

### DÍA 5 — Seguridad, de local a producción y proyecto final (2 h)

**Meta:** aplicar seguridad mínima, entender el salto a nube y entregar el proyecto.

| Hora | Bloque | Contenido | Actividad |
|---|---|---|---|
| 0:00 | Warm-up (5) | Quiz D4 | Quiz |
| 0:05 | M14 (20) | matriz de fallos, RBAC (Role/RoleBinding), Secrets y buenas prácticas de imágenes | Demo `kubectl auth can-i` |
| 0:25 | M14 lab (25) | 2 casos rotos en parejas + ServiceAccount con permisos acotados | **Lab12** (casos 1–2) |
| 0:50 | M15 (10) | de local a producción: nodos gestionados, Ingress con LB, secret manager, costes | Teoría |
| 1:00 | M16 (50) | proyecto final con `project/starter/` y ruta express | Trabajo en equipo |
| 1:50 | Cierre (10) | demos express (2 min/equipo), evaluación, **checklist de limpieza final** | Evaluación |

**Entregable D5:** proyecto final (§7) + evidencia de borrado limpio del clúster.
**Asíncrono (opcional):** casos 3–4 del lab12 y ampliación del proyecto (ruta completa).

---

## 7. Proyecto final (evaluado) — ruta express para 10 h

**Objetivo:** entregar una aplicación desplegable de forma **reproducible** en un clúster local
limpio (desde `kind create cluster` hasta app en marcha en <15 minutos con tu README).

Requisitos (ruta express, la que se evalúa en este formato):

1. Repo Git con manifiestos de una app de 2 servicios (web + API).
2. Empaquetado con **Helm**: un chart con `values-dev.yaml` y `values-staging.yaml` (puede partir
   de `labs/lab08-helm/solution/curso-web`).
3. Configuración externa (ConfigMap) y secreto (Secret) sin valores hardcodeados en manifiestos.
4. Exposición: Ingress con host de prueba **o** Service + documentación de cómo probarlo.
5. `requests/limits` y **una** evidencia de rollback (`helm rollback` o `kubectl rollout undo`).
6. Pipeline de validación y despliegue: `bash ci.sh` local aceptado; con workflow de
   GitHub Actions = puntos extra.
7. README con arquitectura, comandos de reproducción paso a paso y checklist de limpieza.
8. Evidencia de diagnóstico: un despliegue fallido provocado + su resolución.

Ampliación opcional (no evaluada en este formato, material de continuidad): Kustomize como
alternativa a Helm, workflow de CI/CD en la nube, Ingress con TLS, autoscaling.

Rúbrica (40 pts): Manifiestos y arquitectura (10) · Empaquetado Helm multi-entorno (10) ·
Config/secretos y exposición (8) · Rollback e higiene/limpieza (6) · Docs y reproducibilidad (6).

> La especificación detallada, la estructura de repo y el starter están en
> [`project/SPEC.md`](project/SPEC.md) y [`project/starter/`](project/starter/).

---

## 8. Checklist de limpieza (fin de cada día)

```bash
# 1) Borrar namespaces de labs (conserva el clúster si el instructor lo indica)
kubectl get ns --show-labels | grep lab
kubectl delete ns lab01 lab02 lab03 lab04 lab05 lab06 lab07 --ignore-not-found
kubectl delete ns lab08 lab09 lab10 lab11 lab12 --ignore-not-found

# 2) Borrar releases de Helm
helm list -A
helm uninstall <release> -n <namespace>

# 3) Destruir el clúster completo (obligatorio al final del curso)
kind delete cluster --name curso-k8s

# 4) Verificar que no quedan recursos de Docker
docker ps -a
docker system df

# 5) Verificar kubeconfig limpio
kubectl config get-contexts
```

---

## 9. Evaluación y seguimiento

| Instrumento | Momento | Peso |
|---|---|---|
| Quizzes rápidos (5 min, inicio de cada día) | Diario | 10% |
| Entregables de labs (D1–D4) | Diario | 30% |
| Proyecto final (§7, ruta express) | Día 5 | 40% |
| Participación y retro alimentaria | Final | 20% |

**Continuidad post-curso:** material asíncrono del curso (Kustomize, probes, plantillas Helm
avanzadas), CKA/CKAD, GitOps con Flux/ArgoCD, migración a nube (AKS/EKS/GKE) con
Terraform/OpenTofu y observabilidad con Prometheus/Grafana.
