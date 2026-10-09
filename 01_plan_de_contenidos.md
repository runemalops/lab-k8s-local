# Curso: Introducción a Kubernetes como herramienta de Deployment (entorno local)

**Duración:** 4 días (09:00–13:00 · 14:00–17:00 → ~7 h efectivas/día)
**Formato:** Teoría + laboratorios 100% en equipos locales (sin nube, sin costo)
**Audiencia:** Estudiantes de ingeniería y developers en formación (últimos semestres / junior)
**Nivel:** Básico → Intermedio bajo. No requiere experiencia previa en Kubernetes ni Docker avanzado.

---

## 1. Ficha técnica

| Campo | Detalle |
|---|---|
| Código | K8S-LOCAL-DEPLOY-01 |
| Modalidad | Presencial u online, cada alumno con su propio equipo |
| Idioma | Español (terminología técnica en inglés) |
| Enfoque | Kubernetes como **herramienta de deployment**: de la imagen al despliegue versionado, multi-entorno y automatizado |
| Entorno | Clúster local: **kind** (principal), alternativas minikube / Docker Desktop / k3d |
| Tooling | Docker/colima, kubectl, kind, helm, kustomize, Git, editor (VS Code) |
| Evaluación | 60% laboratorios entregables + 40% proyecto final (día 4) |
| Materiales | Repo de alumnos: esqueletos de manifiestos, charts base, pipelines, solución de referencia |

### Por qué Kubernetes **local** (y no nube)
- **Cero costo y cero fricción:** sin créditos, cuotas ni sorpresas de facturación.
- **Reproducibilidad:** todos los alumnos corren exactamente lo mismo en su equipo.
- **Foco en deployment:** el alumno entiende *qué* despliega y *cómo* antes de preocuparse por *dónde* corre.
- **Puente natural:** lo aprendido aquí aplica igual a AKS, EKS, GKE o Rancher; el día 4 se explica la ruta de migración a nube.

### Por qué este curso y no uno de "administrar clusters"
- El objetivo del alumno es **llevar código de desarrollo a un entorno ejecutable**: manifiestos, paquetes (Helm/Kustomize), entornos (dev/staging), versionado y CI/CD.
- El cluster es *inbox* de despliegue; la administración profunda (etcd, upgrades, certificados) queda fuera de alcance.

---

## 2. Objetivos de aprendizaje

Al finalizar, el alumno será capaz de:

1. Explicar la diferencia entre contenedor, imagen y clúster; y describir la arquitectura de Kubernetes (control plane vs nodos).
2. Instalar y operar un clúster local con **kind** y usar `kubectl` con soltura.
3. Desplegar una aplicación real usando manifiestos declarativos (Deployment, Service, ConfigMap, Secret, Ingress, Namespace).
4. Gestionar el **ciclo de vida de un deployment**: rollout, rollback, versionado de imágenes y estrategias de actualización.
5. Empaquetar despliegues multi-entorno con **Helm** y **Kustomize**.
6. Automatizar despliegues con un **pipeline CI/CD** que aplique cambios al clúster.
7. Diagnosticar despliegues fallidos (Pending, CrashLoopBackOff, ImagePullBackOff, errores de red) con logs, describe y events.
8. Aplicar higiene de seguridad básica (Secrets, RBAC mínimo, imágenes etiquetadas) y **cerrar el laboratorio sin dejar recursos**.

---

## 3. Prerrequisitos

### Del alumno
- Nivel medio de Linux/terminal (navegar, editar archivos, variables de entorno).
- Básicos de una lenguaje de programación (Python, JS o Java) para leer YAML y entender su app de ejemplo.
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

> Windows: usar **WSL2 + Ubuntu** como entorno de trabajo (instrucciones en la guía del estudiante). Docker Desktop con WSL2 backend o colima/OrbStack en macOS.

### Del instructor
- Repo Git del curso con `labs/` (skeleton + `solution/`), `slides/` y `project/`.
- Máquina demo proyectable con todo el tooling preinstalado y clúster kind corriendo.
- Verificación previa de instalación en 2–3 equipos Windows/macOS/Linux (semanas antes).

---

## 4. Entorno de laboratorio (local)

### 4.1 Stack elegido y por qué

| Herramienta | Rol | Por qué esta opción |
|---|---|---|
| **kind** | Clúster local en Docker | Ligero, oficial CNCF, mismo código que usa CI (GitHub Actions); crea/borra clúster en segundos |
| Docker Desktop / colima / OrbStack / Rancher Desktop | Runtime de contenedores | Estándar de facto; alternativas según SO/licencia |
| kubectl | Cliente | Estándar único para cualquier clúster |
| helm / kustomize | Empaquetado de despliegues | Las dos herramientas de deployment más usadas en la industria |
| minikube / k3d / Docker Desktop K8s | Alternativas | Para alumnos sin privilegios o con restricciones; el curso lo soporta como "modo compatible" |

### 4.2 Reglas de oro del laboratorio (se dictan el Día 1)
1. Un solo clúster kind por alumno, nombre `curso-k8s` (`kind create cluster --name curso-k8s`).
2. **Un namespace por ejercicio** (`lab01`, `lab02`, …) para poder limpiar con un solo comando.
3. Tags en manifiestos: `app.kubernetes.io/part-of: curso-k8s` para facilitar auditoría.
4. Imágenes siempre con **tag explícito** (nunca `:latest` en entregables).
5. Al final de cada día: `kind delete cluster --name curso-k8s` y volver a crearlo en 2 minutos (simula "infraestructura efímera").
6. Nada de `sudo` fuera de la instalación inicial; nada de modificaciones globales sin avisar.

### 4.3 Instalación de tooling (guía previa, enviada 1 semana antes)

```bash
# Docker (según SO) → https://docs.docker.com/get-docker/
docker version

# kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Kustomize (via kubectl plugin)
kubectl kustomize --help >/dev/null 2>&1 || \
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash

# Verificación
docker info && kind version && kubectl version --client && helm version && git --version
```

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

| # | Módulo | Día | Tipo |
|---|---|---|---|
| M01 | Contenedores, imágenes y artefactos de deployment | 1 | Teoría + lab local |
| M02 | Arquitectura de Kubernetes: control plane, nodos, desired state | 1 | Teoría |
| M03 | Clúster local con kind: instalación, ciclos de vida, alternativas | 1 | Lab guiado |
| M04 | kubectl: contexto, describir, logs, aplicar, eliminar | 1 | Teoría + lab |
| M05 | Primer deployment declarativo: Pod, Deployment, ReplicaSet, Service, Namespace | 1 | Lab guiado |
| M06 | K8s como herramienta de deployment: declarativo vs imperativo, desired state, Git como fuente de verdad | 2 | Teoría |
| M07 | Configuración y secretos: ConfigMap, Secret, env vars, volúmenes | 2 | Teoría + lab |
| M08 | Exposición de servicios: ClusterIP/NodePort/LoadBalancer, port-forward, Ingress + ingress-nginx | 2 | Lab |
| M09 | Ciclo de vida del despliegue: requests/limits, rollout, rollback, versionado de imágenes | 2 | Teoría + lab |
| M10 | Empaquetado con Helm: charts, values, templates, hooks | 3 | Teoría + lab |
| M11 | Kustomize y multi-entorno: overlays dev/staging/prod | 3 | Lab |
| M12 | CI/CD que despliega: pipeline que valida, buildea y aplica al clúster | 3 | Teoría + lab |
| M13 | Observabilidad del despliegue: logs, events, describe, top, métricas básicas | 4 | Teoría + lab |
| M14 | Debugging de despliegues fallidos y seguridad básica (RBAC, Secrets, imágenes) | 4 | Teoría + lab |
| M15 | De local a producción: lo que cambia al llevar el despliegue a nube/CI real | 4 | Teoría |
| M16 | Proyecto final: app + manifiestos + Helm/Kustomize + pipeline + entrega | 4 | Lab evaluado |

---

## 6. Programa día a día

> Horario sugerido: **09:00–13:00 teoría+lab · 14:00–17:00 lab+debrief**. Cada bloque cierra con 15 min de Q&A y mini-retro.

---

### DÍA 1 — Contenedores, Kubernetes y primer despliegue

**Meta:** que el alumno tenga un clúster local corriendo y despliegue su primera app con manifiestos declarativos.

| Hora | Bloque | Contenido | Actividad |
|---|---|---|---|
| 09:00 | M01 (1 h) | Contenedores vs VMs, imágenes, Dockerfile básico, registry, artefactos de deployment | Lab: construir y correr una imagen |
| 10:00 | M02 (1.5 h) | Arquitectura K8s: API server, etcd, scheduler, controller-manager, kubelet, kube-proxy, pods, nodos, namespaces; desired state | Diagrama + quiz rápido |
| 11:30 | *Break* | | |
| 11:45 | M03 (1 h) | kind: qué es, crear/borrar clúster, nodos como contenedores, contexto de kubeconfig, alternativas (minikube, k3d, Docker Desktop) | Lab: crear `curso-k8s`, inspeccionar nodos |
| 14:00 | M04 (1.5 h) | kubectl: get/describe/logs/exec/delete/apply, `-o wide/yaml`, labels y selectors | Lab: recorrer un pod con kubectl |
| 15:30 | M05 (2 h) | Deployment + ReplicaSet, Service, Namespace; YAML mínimo explicado línea a línea | Lab: desplegar nginx + Service + Namespace `lab01`, probar con curl/port-forward |
| 16:45 | Cierre | Errores típicos del día (ImagePull, Pending, contexto equivocado); borrado del clúster y recreación en 2 min | Retro del día |

**Entregable D1:** manifiestos `deployment.yaml` + `service.yaml` + evidencia (`kubectl get all -n lab01`) y notas del quiz de arquitectura.

---

### DÍA 2 — Kubernetes como herramienta de deployment

**Meta:** entender el modelo declarativo y dominar configuración, exposición y ciclo de vida de un despliegue.

| Hora | Bloque | Contenido | Actividad |
|---|---|---|---|
| 09:00 | M06 (1 h) | Imperativo vs declarativo, desired state, reconciliación, Git como fuente de verdad, `kubectl apply` vs `create` | Debate: "mi app funciona en mi laptop, ¿y en otro lado?" |
| 10:00 | M07 (1.5 h) | ConfigMap, Secret (con `stringData`), env vars, envFrom, volúmenes simples | Lab: app que lee config de ConfigMap y credenciales de Secret |
| 11:30 | *Break* | | |
| 11:45 | M08 (1.5 h) | Service types, DNS interno del clúster, port-forward, Ingress con ingress-nginx, hosts de prueba | Lab: exponer `app.local` con reglas de path en `lab03` |
| 14:00 | M09 (2 h) | requests/limits, QoS, rollout, `rollout status/undo/history`, estrategias RollingUpdate, versionado de imágenes (tags) | Lab: rollout a v2, provocar fallo, rollback a v1 |
| 16:00 | Práctica integradora | Desplegar app de 2 servicios (web + api) con config y exposición | Trabajo en parejas |
| 16:45 | Cierre | Errores de red (DNS, selector, puerto), limpieza de namespaces | Retro |

**Entregable D2:** manifiestos de la app de 2 servicios (deployment, service, configmap, secret, ingress) + evidencia de rollback (`kubectl rollout history`).

---

### DÍA 3 — Empaquetado, multi-entorno y CI/CD

**Meta:** industrializar el despliegue: paquetes versionados, entornos separados y pipeline automatizado.

| Hora | Bloque | Contenido | Actividad |
|---|---|---|---|
| 09:00 | M10 (1.5 h) | Helm: conceptos (chart, values, release, repository), `install/upgrade/rollback`, `templates/`, `values.yaml` | Lab: instalar un chart propio sobre la app de D2 |
| 10:30 | M10 cont. | Plantillas Helm: `{{ .Release.Name }}`, rangos, helpers | Lab: parametrizar imagen y réplicas |
| 11:30 | *Break* | | |
| 11:45 | M11 (1.5 h) | Kustomize: base/overlays, patches, `kustomize build`, cuándo usar Helm vs Kustomize | Lab: overlays `dev` y `staging` con distinta configuración |
| 14:00 | M12 (2 h) | CI/CD: fases (lint → test → build → push → deploy), GitHub Actions/ GitLab CI, `kubeval`/`kubeconform`, despliegue a kind en pipeline | Lab: pipeline que valida manifiestos y despliega al clúster |
| 16:00 | M12 cont. | GitOps breve: idea de declarative pipeline, Flux/ArgoCD como siguiente paso (demo) | Demo + discusión |
| 16:45 | Cierre | Coste de la complejidad: cuándo sí y cuándo no usar Helm/Kustomize/CI | Retro |

**Entregable D3:** chart Helm o estructura Kustomize funcional + pipeline ejecutado con captura del job verde.

---

### DÍA 4 — Operación, debugging, seguridad y proyecto final

**Meta:** diagnosticar despliegues rotos, aplicar seguridad básica, entender el salto a producción y entregar el proyecto.

| Hora | Bloque | Contenido | Actividad |
|---|---|---|---|
| 09:00 | M13 (1 h) | `kubectl top`, events, `describe`, `logs --previous`, métricas básicas, salud del clúster | Lab: provocar CrashLoopBackOff y diagnosticar |
| 10:00 | M14 (1 h) | RBAC básico (Role/RoleBinding), Secrets (malas prácticas vs buenas), imágenes con tag, SecurityContext mínimo | Lab: service account con permisos limitados |
| 11:00 | M14 cont. | Troubleshooting: Service sin endpoints, DNS rota, quota de recursos, image tag inexistente | Lab de diagnóstico (kasos en parejas) |
| 14:00 | M15 (0.5 h) | De local a producción: diferencias (nodos gestionados, ingress con cloud LB, secret manager, registry, coste) | Teoría + ruta de migración |
| 14:30 | M16 Proyecto (2.5 h) | Aplicar todo: manifiestos + Helm/Kustomize + pipeline + docs | Ver especificación §7 |
| 16:00 | Evaluación | Revisión entre pares + checklist del instructor | Presentación 5 min por equipo |
| 16:45 | Cierre | Borrado final del laboratorio, recursos de continuidad, rutas de certificación (CKA/CKAD) | Evaluación del curso |

**Entregable D4:** proyecto completo (§7) + evidencia de borrado limpio del clúster.

---

## 7. Proyecto final (evaluado)

**Objetivo:** entregar una aplicación desplegable de forma **reproducible y automatizada** en un clúster local limpio (desde `kind create cluster` hasta app en marcha en <15 minutos).

Requisitos:
1. Repo Git con manifiestos Kubernetes de una app de 2 servicios (web + API).
2. Empaquetado con **Helm o Kustomize** (parametrizable: al menos entornos `dev` y `staging`).
3. Configuración externa (ConfigMap) y secreto (Secret) sin valores hardcodeados en manifiestos.
4. Exposición: Ingress con host de prueba (o Service según disponibilidad) y documentación de cómo probarlo.
5. Recursos `requests/limits` y al menos una estrategia de rollout/rollback demostrada.
6. Pipeline CI/CD (GitHub Actions o GitLab CI) que valide (`kubeconform`), despliegue al clúster local y tenga job verde.
7. README con: arquitectura, comandos de reproducción paso a paso y checklist de limpieza.
8. Evidencia de diagnóstico: captura de un despliegue fallido provocado + su resolución.

Rúbrica (40 pts): Manifiestos y arquitectura (10) · Empaquetado multi-entorno (10) · CI/CD (8) · Exposición/escalado (6) · Docs, higiene y limpieza (6).

---

## 8. Checklist de limpieza (fin de cada día)

```bash
# 1) Borrar namespaces de labs (conserva el clúster si el instructor lo indica)
kubectl get ns --show-labels | grep lab
kubectl delete ns lab01 lab02 lab03 --ignore-not-found

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
| Quizzes rápidos (5 min, fin de cada bloque) | Diario | 10% |
| Entregables de labs (D1–D3) | Diario | 30% |
| Proyecto final (§7) | Día 4 | 40% |
| Participación y retro alimentaria | Final | 20% |

**Continuidad post-curso:** CKA/CKAD, GitOps con Flux/ArgoCD, Helm avanzado, migración a nube (AKS/EKS/GKE) con Terraform/OpenTofu, observabilidad con Prometheus/Grafana.
