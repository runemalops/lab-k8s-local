# 02 · Guía de contenidos y módulos (formato 5 días × 2 h)

Este documento es la referencia de contenidos **módulo a módulo**: duración, objetivo,
teoría, demo, laboratorio, errores comunes del alumno y el PR que lo deja listo.
Sirve de checklist de desarrollo para el instructor y para medir el avance del alumno.

> **Formato vigente: 5 días × 2 h = 10 h de clase.**
> Rutina fija diaria: `0:00–0:05` quiz de calentamiento · `0:05–1:50` teoría esencial + práctica
> guiada · `1:50–2:00` entregable, retro y limpieza.
> Los módulos marcados **[ASÍNCRONO]** no van en aula: se dejan como material de ampliación
> con su lab completo y entregable opcional.

---

## Resumen de módulos

| Día | Módulos | Labs en aula | Horas |
|---|---|---|---|
| **D1** | M01 Contenedores · M02 Arquitectura · M03 kind · M04 kubectl (integrado) · M05 Primer deployment | lab01, lab02, lab04 | 2 h |
| **D2** | M06 Declarativo · M07 Config/secretos · M08 Exposición · M09 Ciclo de vida (express) | lab05, lab06, lab07 (express) | 2 h |
| **D3** | M10 Helm · M11 Kustomize **[ASÍNCRONO]** | lab08 | 2 h |
| **D4** | M12 CI/CD · M13 Observabilidad | lab10, lab11 | 2 h |
| **D5** | M14 Debugging+seguridad · M15 De local a prod · M16 Proyecto final | lab12 (casos 1–2) + proyecto | 2 h |

**En aula:** 10 de 12 labs (lab03 y lab09 + extensiones de lab07/lab08/lab12 → material asíncrono).

---

# DÍA 1 — Del contenedor al primer despliegue

**Objetivo del día:** que el alumno vea la cadena completa en 2 h: imagen → clúster →
manifiesto → servicio funcionando en su equipo.

## M01 — Contenedores, imágenes y artefactos de deployment

**Tipo:** Teoría (15 min) + Lab01 (15 min) · **Carpeta:** `labs/lab01-containers/`

- **Objetivo:** comprender contenedor vs VM, imagen vs contenedor, tag, registry y por qué el
  artefacto de deployment es la imagen.
- **Teoría (15 min):** aislamiento de procesos, capas/union FS, `Dockerfile` mínimo
  (FROM/COPY/RUN/EXPOSE/USER), tags inmutables, semver aplicado a imágenes.
- **Laboratorio (15 min):** Lab01 — generar `nginx:1.27` propio con contenido de la página,
  crear `Dockerfile` y construir `curso-web:1.0`.
- **Errores comunes:** `:latest` explícito (penalizado), imágenes gigantes sin slim, no
  entender que el contenedor corre la imagen.
- **Como lo evalúa el alumno:** `docker images | grep curso-web` muestra su tag.
- **Extensión / PR:** reemplazar base por `alpine` y comparar tamaños (20 lines extra).

## M02 — Arquitectura de Kubernetes: control plane, nodos, desired state

**Tipo:** Teoría (10 min) · **Sin lab** · **Carpeta:** diagrama en `slides/`

- **Objetivo:** explicar qué es el API server, etcd, scheduler y controller-manager; qué es un
  nodo; y la idea de *desired state*.
- **Teoría (10 min):** API server como única puerta; etcd como estado; scheduler y controllers
  en bucle de reconciliación; kubelet + container runtime en el nodo; Pod como unidad.
- **Laboratorio:** diagrama en la pizarra + pregunta clave: "si borro el pod, ¿quién lo repone?"
- **Errores comunes:** pensar que K8s es un PaaS; creer que SSH al nodo es la forma de operar.
- **Como lo evalúa el alumno:** en 60 segundos dibujar la arquitectura y explicar el bucle
  `spec → reconcile → status`.
- **Extensión / PR:** M01/M02 en profundidad en el material asíncrono (CRDs y operators).

## M03 — Clúster local con kind

**Tipo:** Teoría (5 min) + Lab02 (15 min) · **Carpeta:** `labs/lab02-kind/`

- **Objetivo:** crear, inspeccionar y destruir un clúster en <2 min; entender *contexto*.
- **Teoría (5 min):** kind = clúster en contenedores; kubeconfig y contextos; alternativas
  (minikube, k3d, Docker Desktop, Rancher Desktop) y cuándo usar cada una.
- **Laboratorio (15 min):** Lab02 — `kind create cluster --name curso-k8s`, inspeccionar
  nodos/contenedores del control plane, borrar y recrear.
- **Errores comunes:** olvidar el `--name` y acumular clústers; ignorar el *contexto activo*.
- **Como lo evalúa el alumno:** `kind get clusters` y `kubectl config current-context`.
- **Extensión / PR:** entorno alternativo funcionando (minikube/Docker Desktop) para el
  ejercicio de compatibilidad.

## M04 — kubectl: contexto, describir, logs, aplicar, eliminar

**Tipo:** Teoría (5 min) + práctico integrado en Lab04 · **Carpeta:** `labs/lab03-kubectl/` **[ASÍNCRONO]**

- **Objetivo:** dominar el patrón `kubectl <verbo> <tipo> <nombre>` y los verbos del día a día.
- **Teoría (5 min, en aula):** `get/describe/logs/apply/delete/edit`, flags clave
  (`-n`, `-l`, `-o wide/yaml`, `--context`), autocompletado.
- **En aula:** se practica dentro del Lab04 (get/describe/port-forward/scale).
- **Laboratorio completo (50 min, asíncrono):** Lab03 — dashboard mental con verbos, filtro por
  labels, describir un pod caído, generar YAML, borrar con elegancia.
- **Errores comunes:** pegar YAML gigantes; confundir `describe` con `get`; saltarse `-n`.
- **Como lo evalúa el alumno:** cheat-sheet de una página con 15 comandos mínimos.
- **Extensión / PR:** traducir un comando imperativo a manifiesto declarativo sin romper nada.

## M05 — Primer deployment declarativo

**Tipo:** Teoría (10 min) + Lab04 (30 min) · **Carpeta:** `labs/lab04-first-deploy/`

- **Objetivo:** leer y modificar un manifiesto YAML de Deployment + Service y desplegarlo.
- **Teoría (10 min):** anatomía mínima de un manifiesto (apiVersion/kind/metadata/spec),
  labels y selectors, Namespace por ejercicio, desired state.
- **Laboratorio (30 min):** Lab04 — namespace `lab04`, deployment `nginx:1.27` con 2 réplicas,
  Service y `port-forward`, escalar, sabotaje de pod y recuperación.
- **Errores comunes:** indentación de YAML, selectors que no casan, confundir Service con Ingress.
- **Como lo evalúa el alumno:** `kubectl get all -n lab04` en verde y la app respondiendo por
  port-forward.
- **Extensión / PR:** añadir un Deployment de la app real del alumno (sustituir nginx).
- **Entregable D1:** `deployment.yaml` + `service.yaml` + `evidence.txt`.

---

# DÍA 2 — Configuración, exposición y ciclo de vida

**Objetivo del día:** separar configuración y código, exponer el servicio fuera del clúster y
saber revertir un release malo.

## M06 — K8s como herramienta de deployment: declarativo vs imperativo

**Tipo:** Teoría (10 min) · **Carpeta:** demo de `slides/`

- **Objetivo:** entender por qué el estado deseado vive en Git y el clúster lo reconcilia.
- **Teoría (10 min):** imperativo vs declarativo; reconciliación; Git como fuente de verdad;
  drift; alias-vs-fuente de verdad (demo del sabotaje: borrar pods y ver la recuperación).
- **Laboratorio:** demo en vivo del instructor (5 min) + quiz de contraintuición.
- **Errores comunes:** "kubedit" (editar con `kubectl edit` sin reflejarlo en Git).
- **Como lo evalúa el alumno:** reproducir el sabotaje y explicar qué lo repuso.
- **Extensión / PR:** pequeñas (10–20 líneas): manual "imperativo → declarativo".

## M07 — Configuración y secretos

**Tipo:** Teoría (15 min) + Lab05 (30 min) · **Carpeta:** `labs/lab05-config/`

- **Objetivo:** externalizar config y secretos; actualizar sin reconstruir la imagen.
- **Teoría (15 min):** ConfigMap y Secret, `env` vs volúmenes, `envFrom`, propagación y
  `rollout restart`, buenas prácticas de secretos (base64 ≠ cifrado).
- **Laboratorio (30 min):** Lab05 — app `hashicorp/http-echo` con config externa y secreto,
  demostrar propagación con `rollout restart`.
- **Errores comunes:** reiniciar deploy a mano (funciona, pero sin evento de rollout); hardcodear
  credenciales en el manifiesto.
- **Como lo evalúa el alumno:** ver el cambio de mensaje sin tocar la imagen.
- **Extensión / PR:** consumir el ConfigMap como archivo en `volumeMounts` en vez de env.
- **Entregable D2 (parte config):** manifiestos + evidencia de propagación.

## M08 — Exposición: ClusterIP, NodePort, port-forward e Ingress

**Tipo:** Teoría (15 min) + Lab06 (20 min) · **Carpeta:** `labs/lab06-ingress/`

- **Objetivo:** llegar a la app desde fuera con rutas por host/path.
- **Teoría (15 min):** ClusterIP/NodePort/LoadBalancer, DNS interno (`svc.ns.svc.cluster.local`),
  port-forward, Ingress + ingress-nginx (controlador ya instalado por el instructor).
- **Laboratorio (20 min):** Lab06 — host `app.local`, rutas `/` y `/api`, verificación con
  `curl -H "Host: app.local ..."` y fallback con port-forward.
- **Errores comunes:** 404 por path, Service sin endpoints, olvidar el header `Host`.
- **Como lo evalúa el alumno:** `curl` responde en ambas rutas.
- **Extensión / PR:** segundo host (`staging.app.local`).

## M09 — Ciclo de vida: rollout, rollback y versionado de imágenes

**Tipo:** Teoría + demo (15 min) + Lab07 *express* (10 min dentro del bloque) · **Carpeta:** `labs/lab07-rollout/` (versión completa **[ASÍNCRONA]**)

- **Objetivo:** desplegar una imagen nueva, detectar el fallo y revertir sin pánico.
- **Teoría (15 min):** requests/limits, RollingUpdate, RevisionHistoryLimit, `rollout
  status/history/undo/set image`, etiquetado inmutable de imágenes.
- **En aula (10 min):** Lab07 *express* — subir a `nginx:1.27.1`, provocar el fallo con
  `nginx:1.27.999`, `rollout undo` documentado. OOMKilled/probes → **asíncrono**.
- **Errores comunes:** "resolver" con delete+apply (rompe el historial); imágenes `:latest`.
- **Como lo evalúa el alumno:** ver 2 revisiones en `rollout history` y volver a la 1ª.
- **Extensión / PR (asíncrona):** lab07 completo (probes, OOMKilled, cambio de imagen por template).
- **Entregable D2:** manifiestos de config/exposición + evidencia de rollback.

---

# DÍA 3 — Empaquetado de despliegues con Helm

**Objetivo del día:** pasar de YAML sueltos a un paquete versionado y parametrizable.

## M10 — Helm: charts, values, upgrade y rollback

**Tipo:** Teoría (25 min) + Lab08 (75 min, en 2 sub-bloques) · **Carpeta:** `labs/lab08-helm/`

- **Objetivo:** empaquetar un despliegue, parametrizarlo y gestionarlo por versiones.
- **Teoría (25 min):** conceptos chart/values/release/repository, layout de un chart,
  funciones clave (`Range`, `toYaml`, `Include`), `lint/template/install/upgrade/rollback`.
- **Lab08 · parte 1 (40 min):** chart del servicio web — podar `helm create`, parametrizar
  imagen y réplicas, `--set`, `helm lint` + `helm template` antes de aplicar.
- **Lab08 · parte 2 (35 min):** `values-dev.yaml` vs `values-staging.yaml`, upgrade entre
  entornos y rollback a la revisión anterior.
- **Errores comunes:** editar plantillas generadas a mano (siguiente upgrade las pisa); olvidar
  `helm lint`; mezclar releases en el mismo namespace.
- **Como lo evalúa el alumno:** `helm list -A` con su release y el rollback exitoso.
- **Extensión / PR (asíncrona):** plantillas avanzadas (helpers, condicionales, `NOTES.txt`).
- **Entregable D3:** chart con 2 files de values + evidencia de upgrade/rollback.

## M11 — Kustomize y multi-entorno: overlays dev/staging **[ASÍNCRONO]**

**Tipo:** Lab (45 min) · **Carpeta:** `labs/lab09-kustomize/` · **Modalidad:** material opcional

- **Objetivo:** lograr multi-entorno *sin plantillas*, solo con overlays.
- **Qué contiene:** `base/` + `overlays/dev` + `overlays/staging` (réplicas e imagen
  distintas), `kubectl apply -k` (o `kustomize build`), nota sobre `commonLabels` deprecado y
  el bloque moderno `labels`/`includeSelectors`.
- **En aula:** solo la comparación Helm vs Kustomize en el cierre del Día 3 (5 min).
- **Errores comunes:** aplicar la base directamente (sin overlays); edits en `base/` que rompen
  los overlays.
- **Extensión / PR:** añadir un tercer overlay `prod` con réplicas de producción.

---

# DÍA 4 — CI/CD y diagnóstico del despliegue

**Objetivo del día:** automatizar la validación/despliegue y diagnosticar fallas en minutos.

## M12 — CI/CD que despliega en Kubernetes

**Tipo:** Teoría + demo (20 min) + Lab10 (35 min) · **Carpeta:** `labs/lab10-cicd/`

- **Objetivo:** pipeline que valida manifiestos y despliega al clúster local.
- **Teoría (15 min):** fases del pipeline (lint → build → push → deploy → smoke test),
  validación de manifiestos, kind en CI, agente y runner, secretos del pipeline.
- **Demo (5 min):** GitOps con Flux/ArgoCD — "tu clúster vigila el repo".
- **Laboratorio (35 min):** Lab10 — pipeline local `bash labs/lab10-cicd/ci.sh`
  (verde + rojo a propósito), workflow de GitHub Actions en `solution/`.
- **Errores comunes:** ejecutar todo sin `set -e`; workflow que solo "existe" pero nunca corrió.
- **Como lo evalúa el alumno:** job verde + job rojo documentado.
- **Extensión / PR:** pipeline corriendo de verdad en GitHub Actions.
- **Entregable D4:** captura de pipeline verde + rojo.

## M13 — Observabilidad del despliegue

**Tipo:** Teoría (15 min) + Lab11 (30 min) · **Carpeta:** `labs/lab11-observability/`

- **Objetivo:** responder "¿qué está pasando?" con el flujo `get → describe → events → logs`.
- **Teoría (15 min):** eventos, códigos y señales; árbol de decisión de 1 página; diferenciar
  fallo de *la app* vs fallo de *la configuración* vs fallo de *la infra*.
- **Laboratorio (30 min):** Lab11 — provocar `CrashLoopBackOff` con `nginx:busted` (health
  wrong) y destinarlo con el árbol de decisión; entregar `guia-diagnostico.md`.
- **Errores comunes:** mirar logs sin mirar events; no escalar 0 podos visibles.
- **Como lo evalúa el alumno:** "diagnostica en 60 s este clúster caído".
- **Extensión / PR:** añadir un caso de error propio al árbol de decisión.
- **Entregable D4:** `guia-diagnostico.md`.

---

# DÍA 5 — Seguridad, de local a producción y proyecto final

**Objetivo del día:** seguridad mínima, el salto a nube y la entrega final.

## M14 — Debugging de despliegues fallidos y seguridad básica

**Tipo:** Teoría (20 min) + Lab12 casos 1–2 (25 min) · **Carpeta:** `labs/lab12-debug/`

- **Objetivo:** resolver los 4 fallos clásicos y aplicar RBAC mínimo.
- **Teoría (20 min):** matriz de fallos (Pending, CrashLoopBackOff, ImagePullBackOff, Service
  sin endpoints); RBAC (Role/RoleBinding, `kubectl auth can-i`); Secrets y buenas prácticas
  de imágenes (tag + usuario no-root).
- **Laboratorio en aula (25 min):** casos 1 y 2 en parejas; luego ServiceAccount con permisos
  acotados + comprobación `auth can-i`.
- **Casos 3 y 4:** material **[ASÍNCRONO]** con `solution/fixed/` y `solution/diagnostico.md`.
- **Errores comunes:** pegar la solución antes de leer events; `ClusterRoleBinding` por pereza.
- **Como lo evalúa el alumno:** `kubectl auth can-i` devolviendo `yes`/`no` correctos.
- **Extensión / PR:** definir un Role acotado al namespace del proyecto.

## M15 — De local a producción

**Tipo:** Teoría (10 min) · **Carpeta:** `slides/`

- **Objetivo:** enumerar qué cambia al llevar el despliegue a nube/CI real.
- **Teoría (10 min):** nodos gestionados (AKS/EKS/GKE), Ingress con LoadBalancer + DNS y TLS,
  secretos en el pipeline/secret manager, imágenes en un registry y costes.
- **Laboratorio:** solo diagrama "lo que cambia" y pregunta: ¿qué no se lleva a producción?
- **Errores comunes:** creer que el clúster local se "promueve" a producción.
- **Extensión / PR:** camino de actualización a AKS/EKS/GKE con Git+CI (plan escrito).

## M16 — Proyecto final

**Tipo:** Lab evaluado (50 min en aula) · **Carpeta:** `project/` (`SPEC.md` + `starter/`)

- **Objetivo:** entregar una app desplegable reproducible en un clúster limpio.
- **En aula (50 min):** arranque con `project/starter/` + **ruta express** de `project/SPEC.md`
  (2 servicios, Helm con dev/staging, config/secretos, exposición, un rollback, `ci.sh`).
  Ampliación opcional (Kustomize, CI en la nube, TLS) queda fuera de evaluación.
- **Cierre (10 min):** demos express (2 min/equipo), rúbrica, evaluación y **checklist de
  limpieza final**.
- **Errores comunes:** README que no permite reproducir el despliegue desde cero.
- **Como lo evalúa el alumno:** seguir su propio README en una terminal limpia < 15 min.
- **Extensión / PR:** completar la ruta completa del SPEC después del curso.
- **Entregable D5:** repo + rúbrica 40 pts + evidencia de clúster limpio.
