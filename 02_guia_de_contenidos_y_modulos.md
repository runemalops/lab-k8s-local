# Guía de contenidos y detalle de módulos

**Curso:** Introducción a Kubernetes como herramienta de Deployment (entorno local)
**Uso:** documento de referencia para instructor y alumno; cada módulo indica objetivo, teoría, lab, entregable y errores comunes.

> Convención: ⏱ duración · 🎯 objetivo · 📖 teoría · 🔧 lab · 📦 entregable · ⚠️ errores comunes

---

## DÍA 1 — Fundamentos

---

### M01 · Contenedores, imágenes y artefactos de deployment ⏱ 1 h

- **🎯 Objetivo:** distinguir contenedor/imagen/artefacto y producir una imagen desplegable.
- **📖 Teoría (35 min):**
  - Contenedores vs VMs (namespaces, cgroups, capas).
  - Imagen: capas, Dockerfile, tag vs digest, registry (Docker Hub, GHCR).
  - Artefactos de una app: binario + config + dependencias → imagen.
  - Por qué el deployment moderno se basa en "build once, deploy anywhere".
- **🔧 Lab (25 min):** `lab01/`
  1. Dockerfile de una app estática simple (o nginx con contenido propio).
  2. `docker build -t curso-web:1.0 .` y `docker run -p 8080:80`.
  3. Etiquetar versiones (`:1.0`, `:1.1`) y observar capas con `docker history`.
- **📦 Entregable:** Dockerfile + imagen etiquetada en local.
- **⚠️ Errores comunes:** imagen sin tag implícito `latest`; build desde directorio malo (`.dockerignore`); puertos confundidos (`-p host:contenedor`).

---

### M02 · Arquitectura de Kubernetes ⏱ 1.5 h

- **🎯 Objetivo:** describir qué componentes existen y cómo se reconcilia el estado deseado.
- **📖 Teoría (60 min):**
  - Control plane: API server, etcd, scheduler, controller-manager.
  - Nodos: kubelet, kube-proxy, container runtime.
  - Unidades: Pod, Node, Namespace, Label/Selector, Annotation.
  - Modelo declarativo: desired state → reconciliación → estado observado.
  - Ciclo de vida de un Pod (Pending → Running → Succeeded/Failed).
  - Add-ons mínimos (CoreDNS, kube-proxy) — sin profundizar.
- **🔧 Actividad (30 min):** diagrama en pizarra/colaborativo; quiz rápido de 5 preguntas.
- **📦 Entregable:** diagrama anotado + respuestas del quiz.
- **⚠️ Errores comunes:** confundir "contenedor" con "pod"; creer que el API server "ejecuta" los pods.

---

### M03 · Clúster local con kind ⏱ 1 h

- **🎯 Objetivo:** crear, inspeccionar y destruir un clúster local de forma repetible.
- **📖 Teoría (25 min):**
  - kind: nodos como contenedores Docker; arquitectura `kind create/delete`.
  - kubeconfig y contextos: qué mira `kubectl` y por qué.
  - Alternativas: minikube, k3d, Docker Desktop Kubernetes, k3s — cuándo elegir cada uno.
- **🔧 Lab (35 min):** `lab02/`
  1. `kind create cluster --name curso-k8s`.
  2. `docker ps` → ver los nodos; `kubectl cluster-info`; `kubectl get nodes -o wide`.
  3. Crear un segundo clúster temporal y usar `--context` para conmutar.
  4. `kind delete cluster --name curso-k8s` y recrearlo (tiempo objetivo: <2 min).
- **📦 Entregable:** capturas de `kubectl get nodes` con los 2 contextos y del ciclo create/delete.
- **⚠️ Errores comunes:** Docker no corriendo; contexto equivocado (`kubectl` apunta a otro clúster); clústeres huérfanos que consumen RAM.

---

### M04 · kubectl: la brújula diaria ⏱ 1.5 h

- **🎯 Objetivo:** usar kubectl para observar, inspeccionar y modificar recursos sin memorizar todo.
- **📖 Teoría (35 min):**
  - Patrón `kubectl <verbo> <tipo> <nombre> [-n ns]`.
  - Ver: `get`, `-o wide/yaml/json`, `--show-labels`.
  - Inspección: `describe`, `logs`, `exec`, `edit` (y cuándo **no** usarlo).
  - Aplicación: `apply`, `delete`, `label`, `annotate`; descubrimiento con `api-resources`.
- **🔧 Lab (50 min):** `lab03/`
  1. `kubectl run` temporal para practicar.
  2. Identificar un pod: logs, env (`exec -- env`), proceso interno.
  3. Modificar con `apply` de un YAML descargado con `get -o yaml`.
- **📦 Entregable:** cheat-sheet personal de 10 comandos kubectl.
- **⚠️ Errores comunes:** olvidar `-n` (busca en `default`); confundir nombre del recurso con tipo; pods efímeros que desaparecen (`kubectl run --rm -it`).

---

### M05 · Primer deployment declarativo ⏱ 2 h

- **🎯 Objetivo:** desplegar nginx con Deployment + Service + Namespace desde YAML.
- **📖 Teoría (30 min):**
  - Pod vs Deployment vs ReplicaSet: quién crea a quién.
  - Service: selector → endpoints; por qué el Pod no es estable.
  - YAML mínimo anotado (apiVersion, kind, metadata, spec).
- **🔧 Lab (70 min):** `lab04/`
  1. Namespace `lab04`.
  2. `deployment.yaml` (2 réplicas, imagen `nginx:1.27`, labels).
  3. `service.yaml` (ClusterIP y luego LoadBalancer → kind + cloud-provider-kind o port-forward).
  4. Probar: `curl` vía `kubectl port-forward`.
  5. Escalar: `kubectl scale` y observar ReplicaSet.
- **📦 Entregable:** `deployment.yaml` + `service.yaml` + evidencia de `kubectl get all -n lab04`.
- **⚠️ Errores comunes:** selector que no coincide con pod labels; imagen tag inexistente; Deployment sin `replicas` esperando 1 por defecto.

---

## DÍA 2 — K8s como herramienta de deployment

---

### M06 · El modelo declarativo ⏱ 1 h

- **🎯 Objetivo:** razonar por qué declarativo escala mejor que imperativo.
- **📖 Teoría (35 min):**
  - Imperativo (`kubectl create/scale`) vs declarativo (`apply` de manifiestos).
  - Reconciliación: qué pasa si borras un pod manualmente.
  - Git como fuente de verdad: diff → review → apply (semilla de GitOps).
  - `kubectl diff` y `apply --dry-run=server`.
- **🔧 Actividad (25 min):** laboratorio del "sabotaje": borrar un pod y describir qué hace el sistema; comparar `scale` imperativo vs cambio de `replicas` en YAML (drift).
- **📦 Entregable:** notas de la actividad (qué cambió y qué lo reparó).
- **⚠️ Errores comunes:** aplicar cambios con `kubectl edit` y perderlos en el siguiente `apply`; manifiestos modificados fuera de Git.

---

### M07 · Configuración y secretos ⏱ 1.5 h

- **🎯 Objetivo:** externalizar configuración y credenciales fuera de la imagen.
- **📖 Teoría (40 min):**
  - ConfigMap (texto) y Secret (base64 ≠ cifrado); `stringData`.
  - Inyección: `env`, `envFrom`, volúmenes (`items`, montaje en path).
  - Buenas prácticas: no hardcodear, rotación, qué **no** va en un Secret.
- **🔧 Lab (45 min):** `lab05/`
  1. ConfigMap con `APP_ENV` y archivo de config montado.
  2. Secret con credenciales de ejemplo y `envFrom`.
  3. App que muestra su configuración en pantalla/endpoint.
  4. Cambio de ConfigMap → `rollout restart` para ver propagación.
- **📦 Entregable:** `configmap.yaml`, `secret.yaml` (valores de ejemplo) + evidencia del cambio en caliente.
- **⚠️ Errores comunes:** olvidar `restart` tras cambiar env vars; secretos commiteados en base64 como si fueran privados; claves con guiones inválidas para `env`.

---

### M08 · Exposición: Service, DNS e Ingress ⏱ 1.5 h

- **🎯 Objetivo:** exponer servicios dentro y fuera del clúster de forma controlada.
- **📖 Teoría (40 min):**
  - Service types: ClusterIP (interno), NodePort, LoadBalancer (kind: cloud-provider-kind o port-forward como alternativa).
  - DNS interno: `<svc>.<ns>.svc.cluster.local`.
  - Ingress: reglas host/path, controller ingress-nginx, `ingressClassName`.
  - TLS: mención (cert-manager) sin implementar en el lab.
- **🔧 Lab (45 min):** `lab06/`
  1. Instalar ingress-nginx en kind (manifest oficial o Helm chart).
  2. Entrada para `app.local` con paths `/api` y `/`.
  3. Entrada local (`/etc/hosts` o `curl -H "Host: app.local"`) y probar.
  4. Observar que el Service ClusterIP no es alcanzable desde fuera.
- **📦 Entregable:** `ingress.yaml` + prueba con `curl` exitosa.
- **⚠️ Errores comunes:** 404 del default backend (host/path mal); olvidar `ingressClassName`; Service correcto pero Deployment sin labels del selector.

---

### M09 · Ciclo de vida del despliegue: recursos, rollout y rollback ⏱ 2 h

- **🎯 Objetivo:** controlar actualizaciones versionadas y recuperarse de un mal release.
- **📖 Teoría (45 min):**
  - `resources.requests/limits` y su efecto (cuellos de botella, OOMKilled).
  - RollingUpdate: `maxSurge`/`maxUnavailable`; `rollout status/history/pause/undo`.
  - Versionado de imágenes: tags inmutables vs `latest`.
  - Health checks: `livenessProbe`/`readinessProbe` y su rol en el rollout.
- **🔧 Lab (60 min):** `lab07/`
  1. Desplegar `curso-web:1.0` con requests/limits y probes.
  2. Rollout a `1.1` observando pods viejos/nuevos.
  3. Rollout fallido a un tag inexistente → ver bloqueo → `rollout undo`.
  4. Probar `kubectl set image` (imperativo) vs editar YAML y comparar.
- **📦 Entregable:** salida de `kubectl rollout history` con al menos 2 versiones y rollback demostrado.
- **⚠️ Errores comunes:** `ImagePullBackOff` por tag mal escrito; limits demasiado bajos → OOMKilled; probes mal calibradas → reinicios infinitos.

---

## DÍA 3 — Empaquetado y automatización

---

### M10 · Helm: empaquetando despliegues ⏱ 3 h (1.5 + 1.5)

- **🎯 Objetivo:** convertir manifiestos sueltos en un chart parametrizado y versionado.
- **📖 Teoría (50 min):**
  - Conceptos: chart, values, release, repository, version (SemVer de charts).
  - Comandos: `helm install/upgrade/rollback/uninstall/list/lint/template`.
  - Estructura del chart y `templates/` con sintaxis Go.
- **🔧 Lab (60 min):** `lab08/`
  1. `helm create curso-web` y podar lo innecesario.
  2. Envolver el deployment + service de la app de D2.
  3. Parametrizar `image.tag`, `replicas`, `env`.
  4. `helm lint`, `helm template`, `helm install web ./curso-web --set replicas=3`.
- **🔧 Lab 2 (50 min):** templates avanzados (condicionales `ingress.enabled`, helpers `_helpers.tpl`), `values-dev.yaml` vs `values-staging.yaml`, `helm upgrade` y `helm rollback`.
- **📦 Entregable:** chart funcional con 2 archivos de values y evidencia de upgrade/rollback.
- **⚠️ Errores comunes:** YAML roto tras editar plantillas (usar siempre `helm template` para validar); nombres duplicados de release; valores con números interpretados como strings.

---

### M11 · Kustomize y multi-entorno ⏱ 1.5 h

- **🎯 Objetivo:** mantener una base de manifiestos y variantes por entorno sin duplicar archivos.
- **📖 Teoría (35 min):**
  - Base + overlays; `kustomization.yaml`, `patches`, `images`, `commonLabels`.
  - Helm vs Kustomize: cuándo usar cada uno (paquete distribuible vs patch sobre Git).
  - `kubectl apply -k` nativo (sin binario extra).
- **🔧 Lab (45 min):** `lab09/`
  1. Crear `base/` con deployment + service.
  2. `overlays/dev` (1 réplica, tag dev) y `overlays/staging` (3 réplicas, recursos mayores).
  3. `kubectl apply -k overlays/dev` y luego `staging` en otro namespace.
  4. Comparar salida con `kustomize build`.
- **📦 Entregable:** estructura base/overlays + evidencia de los 2 despliegues diferenciados.
- **⚠️ Errores comunes:** patch que no matchea por GVK/name erróneos; modificar la base en vez del overlay; olvidar regenerar (`build` es en tiempo de aplicación, no hay estado).

---

### M12 · CI/CD: el pipeline que despliega ⏱ 2.5 h (2 + 0.5)

- **🎯 Objetivo:** automatizar validación y despliegue de manifiestos desde un pipeline.
- **📖 Teoría (50 min):**
  - Fases: lint/validate → test → build image → push → deploy.
  - Validación de manifiestos: `kubeconform`/`kubeval`, `yamllint`, `helm lint`.
  - Desplegar desde CI a un clúster: kind en el propio runner; kubeconfig como secreto.
  - Estrategias de entorno: `main` → staging (manual) → prod; entornos efímeros.
- **🔧 Lab (70 min):** `lab10/`
  1. Workflow GitHub Actions (o GitLab CI) con jobs: `validate` + `deploy`.
  2. `validate`: kubeconform sobre `overlays/dev`.
  3. `deploy`: crear kind, `kubectl apply -k` (o `helm upgrade --install`), comprobación `kubectl rollout status`.
  4. Provocar un fallo de validación en PR y ver el job rojo.
- **🔧 Demo (30 min):** GitOps con Flux/ArgoCD — qué cambia respecto a push-based.
- **📦 Entregable:** pipeline ejecutado (captura de job verde + uno rojo).
- **⚠️ Errores comunes:** kubeconfig del clúster local no disponible en el runner (usar kind en el job); secretos mal guardados; deploy sin comprobación posterior.

---

## DÍA 4 — Operación y entrega

---

### M13 · Observabilidad del despliegue ⏱ 1 h

- **🎯 Objetivo:** responder "¿qué está pasando con mi despliegue?" en minutos.
- **📖 Teoría (25 min):**
  - Señales: logs, events, métricas; `kubectl top` (metrics-server).
  - Flujo de diagnóstico: `get` → `describe` → `events` → `logs` → `exec`.
  - Recursos de clúster: `kubectl top nodes`, uso y límites.
- **🔧 Lab (30 min):** `lab11/`
  1. Provocar CrashLoopBackOff (comando inválido en el contenedor) y leer el ciclo.
  2. Buscar el evento raíz en `kubectl describe pod`.
  3. Comparar un pod sano vs uno fallido.
- **📦 Entregable:** mini-guía de diagnóstico (árbol de decisión de 1 página).
- **⚠️ Errores comunes:** mirar solo los logs actuales (usar `--previous`); ignorar events por "ruido".

---

### M14 · Debugging y seguridad básica ⏱ 2 h (1 + 1)

- **🎯 Objetivo:** resolver los 6 fallos de despliegue más comunes y aplicar mínimo viable de seguridad.
- **📖 Teoría (40 min):**
  - Matriz de fallos: Pending, ImagePullBackOff, CrashLoopBackOff, OOMKilled, ErrImagePull, Service sin endpoints.
  - Seguridad: RBAC básico (Role/RoleBinding/ServiceAccount), SecurityContext (`runAsNonRoot`), imágenes de origen conocido y tag fijo.
  - Secretos en la práctica: qué sí (Kubernetes Secret para demos) y qué no (Key Vault/externo en producción).
- **🔧 Lab (40 min):** `lab12/`
  1. Práctica de diagnóstico en parejas: 4 manifiestos rotos (entregados rotos a propósito) → arreglar y documentar.
  2. ServiceAccount con Role que solo permite `get/list` de pods → probar con `kubectl auth can-i`.
- **📦 Entregable:** tabla de fallo → causa → solución + manifiesto RBAC funcional.
- **⚠️ Errores comunes:** dar `cluster-admin` por comodidad; asumir que base64 es cifrado.

---

### M15 · De local a producción ⏱ 30 min

- **🎯 Objetivo:** entender qué cambia (y qué se conserva) al llevar el mismo despliegue a un clúster gestionado.
- **📖 Teoría (30 min):**
  - Mismos manifiestos, entorno distinto: nodos gestionados (AKS/EKS/GKE), Ingress con cloud LB, registry gestionado, secret manager, autoscaling.
  - Costos y límites de un clúster real.
  - Ruta de aprendizaje: IaC (Terraform/OpenTofu), GitOps, CKA/CKAD.
  - Nota: los manifiestos/Helm/Kustomize de este curso son portables sin cambios.

---

### M16 · Proyecto final ⏱ 2.5 h + 30 min evaluación

- **🎯 Objetivo:** integrar 4 días en un entregable reproducible.
- **🔧 Trabajo:** ver especificación en `01_plan_de_contenidos.md` §7 (requisitos y rúbrica).
- **📋 Flujo sugerido al alumno:**
  1. Repo limpio + app de 2 servicios (30 min).
  2. Manifiestos base + Kustomize/Helm con 2 entornos (45 min).
  3. Pipeline CI/CD validando y desplegando (30 min).
  4. Ingress, config, recursos, rollback demo (20 min).
  5. README + evidencias + limpieza (15 min).
- **📦 Entregable:** repo Git + demo de 5 min por equipo + checklist de limpieza firmado.

---

## Resumen de entregables por día

| Día | Entregable clave | Formato |
|---|---|---|
| 1 | Manifiestos primer deployment + evidencia kubectl | Archivos + captura |
| 2 | App de 2 servicios completa + rollback demostrado | Archivos YAML + capturas |
| 3 | Chart Helm o estructura Kustomize + pipeline verde | Repo + captura CI |
| 4 | Proyecto final (§7) + limpieza | Repo + demo + checklist |
