# Estructura del curso — Lado del instructor

**Curso:** Introducción a Kubernetes como herramienta de Deployment (entorno local)
**Propósito:** playbook completo para preparar, dictar y cerrar el curso de **5 días × 2 h (10 h)**.

---

## 1. Antes del curso (T-14 a T-1 días)

### 1.1 Checklist de preparación

| Plazo | Tarea | Estado |
|---|---|---|
| T-14 | Congelar repo del curso (rama `main`, tag `v1.0`) | ☐ |
| T-14 | Verificar instalación en 2–3 equipos representativos (Windows/WSL2, macOS, Linux) usando `setup/instalar.sh` + `setup/verificacion.sh` | ☐ |
| T-10 | Enviar **guía de instalación** al alumno (`setup/instalacion-*.md` + `setup/install-*.{sh,ps1}`) | ☐ |
| T-7 | Recoger respuestas del pre-test (arquitectura, YAML, Docker) y survey de hardware | ☐ |
| T-5 | Preparar slides (`slides/`), cheat-sheets (`labs/lab03-kubectl/solution/cheatsheet.md`) e impresas y cuentas de Git del aula | ☐ |
| T-3 | Recordario de instalación + prueba de verificación (`setup/verificacion.sh` y §4.4 de `01_plan`) | ☐ |
| T-1 | Correr los 10 labs del horario (lab01, lab02, lab04–lab08, lab10, lab11 y casos 1–2 de lab12) en la máquina demo; congelar versiones (kind, helm, imágenes) | ☐ |
| T-1 | **Precargar el aula** (el formato comprimido no admite esperas): ingress-nginx instalado, imágenes base prebajeadas (`nginx:1.27`, `nginx:1.27.0`, `nginx:1.27.1`, `hashicorp/http-echo:1.0`) y `bash labs/lab10-cicd/ci.sh` en verde | ☐ |

### 1.2 Pre-test (enviar en T-7, 10 min)
1. ¿Qué diferencia contenedor de una VM?
2. ¿Qué es un `Dockerfile` y para qué sirve un `tag`?
3. Escribe la palabra YAML correcta para un recurso de Kubernetes (aprox.).
4. ¿Algún vez has desplegado una app a un servidor? ¿Cómo?
5. Nivel de comodidad con terminal Linux (1–5).

**Uso:** ajustar el ritmo del Día 1 y formar parejas complementarias (terminal fuerte + débil).

### 1.3 Versiones congeladas del curso (fijar en el repo)

| Herramienta | Versión sugerida |
|---|---|
| kind | v0.24.x |
| Kubernetes (kind node image) | 1.31.x |
| kubectl | estable alineado al clúster |
| Helm | 3.16.x |
| Imágenes base | `nginx:1.27`, `hashicorp/http-echo`, app de ejemplo propia |
| Acciones de GitHub | `ubuntu-latest`, `helm/kind-action` |

---

## 2. Repositorio del curso (estructura real)

```
curso-k8s-local/
├── README.md                       # índice general (enviar al alumno)
├── 01_plan_de_contenidos.md
├── 02_guia_de_contenidos_y_modulos.md
├── 03_estructura_instructor.md     # este archivo
├── 04_estructura_estudiante.md
├── slides/
│   └── README.md                   # decks d1..d5 (los coloca el instructor)
├── labs/
│   ├── lab01-containers/           # README.md (alumno) + INSTRUCTOR.md + skeleton + solution/
│   ├── lab02-kind/                 # kind-config.yaml + solution/
│   ├── lab03-kubectl/              # cheatsheet.md + solution/cheatsheet.md
│   ├── lab04-first-deploy/         # namespace/deployment/service + solution/
│   ├── lab05-config/               # configmap/secret/deployment + solution/
│   ├── lab06-ingress/              # install-ingress.sh + apps/ingress + solution/
│   ├── lab07-rollout/              # deployment con resources/probes + solution/
│   ├── lab08-helm/                 # chart/ (esqueleto) + solution/curso-web/
│   ├── lab09-kustomize/            # base/ + overlays/ + solution/
│   ├── lab10-cicd/                 # ci.sh (fallback local) + .github/workflows/ + manifests/
│   ├── lab11-observability/        # healthy + broken-crashloop + guia-diagnostico
│   └── lab12-debug/                # broken/ (4 fallos) + rbac.yaml + solution/fixed/
├── project/
│   ├── SPEC.md                     # requisitos y rúbrica (40 pts)
│   └── starter/                    # repo base para alumnos
├── setup/
│   ├── instalar.sh                 # dispatcher (detecta SO)
│   ├── install-linux.sh
│   ├── install-macos.sh
│   ├── install-windows.ps1
│   ├── instalacion-linux.md
│   ├── instalacion-macos.md
│   ├── instalacion-windows-wsl2.md
│   ├── configuracion-inicial.md    # guía post-instalación (enviar junto con la instalación)
│   ├── verificacion.sh             # script de autocomprobación
│   └── troubleshooting-setup.md
└── solutions/                      # OPCIONAL: copia del material del instructor
    └── (las soluciones viven en labs/*/solution/)
```

**Cómo se usa cada lab:**
- `README.md` → guía del alumno (paso a paso, entregable, errores comunes).
- `INSTRUCTOR.md` → tiempos, demo clave, errores esperados del aula, checklist de
  entregable y **cuándo** liberar `solution/`.
- `solution/` → respuesta de referencia. **Regla:** no se abre antes de 15 min de
  esfuerzo del alumno ni antes de que ≥70 % del aula avance.

**Regla de entrega:** al alumno se entrega `main` **sin** carpetas `solution/`
(filtrar en el fork o mantener un repo privado del instructor).

---

## 3. Rutina diaria (aplicar cada día — sesión de 2 h)

| Momento (relativo) | Acción | Tiempo |
|---|---|---|
| 0:00 | Warm-up: 3 preguntas del día anterior + quiz de 5 preguntas | 5 min |
| 0:05 | Teoría esencial con demo en vivo proyectada (1 o 2 bloques cortos) | 15–35 min |
| 0:20–1:50 | Lab guiado: el instructor demuestra el primer paso, luego los alumnos ejecutan | 60–75 min |
| en el lab | "Clinic": levantar la mano; priorizar bloqueos >5 min (2 h no perdona) | rotativo |
| 1:50 | Retro: qué salió, qué duele, qué viene; **checklist de limpieza** | 10 min |

> **Disciplina de 2 h:** el instructor tiene la pizarra de tiempos visible y corta en seco
> cualquier bloque que se pase de 2 min. Lo que no cabe → material asíncrono, no "minutos extra".

**Reglas de aula del instructor:**
1. Nunca entregar el YAML final resuelto antes de que el alumno intente (mín. 5 min de esfuerzo en este formato).
2. Bloqueos frecuentes → pausar y hacer demo grupal (mínimo 3 alumnos con el mismo error).
3. Todo error repetido se documenta en la "Pizarra de errores" (slides del día siguiente).
4. El instructor ejecuta la limpieza en su máquina al final de cada sesión (ejemplo visible).
5. Ninguna sesión se cierra con recursos sin borrar: limpieza obligatoria en los últimos 5 min.

---

## 4. Guía de enseñanza por día (qué enfatizar)

### Día 1 — "De la imagen al despliegue en 2 horas"
- Enfatizar: **desired state**; si no está en el YAML, no existe.
- Demo clave: borrar un pod manualmente y ver cómo el Deployment lo recrea.
- Ritmo: es el día más cargado. Si se atrasa >5 min, recorta la parte de alternativas de kind
  (el lab03 de kubectl es material asíncrono y sobra en aula).
- Cuidado: no profundizar en control plane interno (fuera de alcance).
- Salida esperada: todos con `kubectl get all -n lab04` mostrando su nginx y limpieza ejecutada.

### Día 2 — "Deployment es un proceso, no un comando"
- Enfatizar: config externa, versionado de imágenes, rollback como skill obligatoria.
- Demo clave: rollout fallido → bloqueo → `rollout undo` en <30 s.
- Aviso: ingress-nginx **ya instalado** y lab06 en 20 min; si se atrasa, deja `lab07` completo
  (probes/OOMKilled) como asíncrono — en aula solo rollout + undo.
- Salida esperada: cada alumno con evidencia de rollback.

### Día 3 — "Lo que no está paquetizado, no se reproduce"
- Enfatizar: repetibilidad (mismos comandos, mismo resultado) y separación de entornos.
- Demo clave: mismo chart desplegado con `--set` distinto y luego con `values-*.yaml`.
- Kustomize: solo comparación de 5 min en el cierre (lab09 es asíncrono).
- Salida esperada: chart con 2 archivos de values y rollback documentado.

### Día 4 — "Automatiza y diagnostica"
- Enfatizar: pipeline que valida antes de desplegar; flujo `get → describe → events → logs`.
- Demo clave: CrashLoopBackOff resuelto en vivo + mini-demo GitOps (5 min).
- Riesgo: pipeline CI/CD es el bloque más frágil → **fallback offline** siempre disponible
  (`bash labs/lab10-cicd/ci.sh`).
- Salida esperada: pipeline verde + rojo por alumno/pareja y `guia-diagnostico.md`.

### Día 5 — "Seguridad, producción y entrega"
- Enfatizar: RBAC mínimo, secretos bien tratados, imágenes etiquetadas y no-root.
- Demo clave: `kubectl auth can-i` sí/no con ServiceAccount acotado.
- "De local a producción": 10 min, sin abrir contenido nuevo (es cierre, no módulo).
- Proyecto: 50 min con `project/starter/` y ruta express; si un equipo no termina, los
  últimos 10 min se usan igual para demos + rúbrica + limpieza final (entrega diferida a 48 h).
- Salida esperada: proyecto entregado + clúster destruido en la sala.

---

## 5. Evaluación (detallada para el instructor)

### 5.1 Instrumentos y momentos
| Qué | Cuándo | Cómo calificar |
|---|---|---|
| Quiz diario (5 preguntas) | Inicio de cada día (5 min) | Autocheck en aula, 1 pt c/u |
| Entregables D1–D4 | Cierre de cada día, repo del alumno | Checklist de 5 puntos por entregable |
| Proyecto final | Día 5 (50 min en aula + entrega diferida 48 h) | Rúbrica §5.3 del plan (40 pts) + demo express 2 min |
| Participación | Continuo | Registro del instructor (intervenciones útiles, ayuda a pares) |

### 5.2 Checklist de entregable genérico (usar en D1–D4)
- [ ] Archivos en el repo con nombres correctos.
- [ ] Manifiestos validados (`kubectl apply --dry-run=client` / `helm lint`).
- [ ] Evidencia incluida (salida de comando en archivo `evidence.txt` o captura).
- [ ] Funciona en clúster recreado desde cero (prueba de reproducibilidad).
- [ ] Limpieza ejecutada (namespaces borrados).

### 5.3 Rúbrica del proyecto final (40 pts) — ruta express
| Criterio | Pts | Indicador de 10/10 |
|---|---|---|
| Manifiestos y arquitectura | 10 | 2 servicios con labels correctos, YAML validado, sin valores hardcodeados |
| Empaquetado multi-entorno (Helm) | 10 | Chart con `values-dev` + `values-staging`; cambiar de entorno no toca el chart |
| Config/secretos y exposición | 8 | ConfigMap + Secret usados, Ingress o Service probado y documentado |
| Rollback e higiene/limpieza | 6 | Evidencia de rollback + `requests/limits` + limpieza ejecutada |
| Docs y reproducibilidad | 6 | README que permite desplegar en <15 min desde `kind create cluster` |

**Umbrales:** ≥32 pts = aprobado · ≥36 = destacado · <28 = recuperación (reespecífico del lab más débil).

### 5.4 Recuperación
- Alumno que falla en 1 entregable → lab extra guiado (20 min, al inicio del día siguiente o asíncrono).
- Alumno que no termina el proyecto en los 50 min → entrega diferida a 48 h con la misma rúbrica.
- Alumno que falla el proyecto → reentrega con feedback; el material asíncrono (lab09/lab03) suma como extra.

---

## 6. Kit de emergencia del instructor

### 6.1 Máquina demo siempre lista
```bash
# Estado "cero" verificado cada mañana
kind delete cluster --name curso-k8s 2>/dev/null
kind create cluster --name curso-k8s
kubectl create ns demo && kubectl create deployment demo --image=nginx:1.27 -n demo
```

### 6.2 Comandos de rescate para errores frecuentes en aula
```bash
# Contexto perdido / clústeres de más
kind get clusters
kubectl config get-contexts
kubectl config use-context kind-curso-k8s

# Clúster no responde / podado de RAM
kind delete cluster --name <otro>            # liberar recursos
docker system prune -f                       # imágenes huérfanas

# Ingress-nginx caído
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

# DNS interno fallando
kubectl run tmp --rm -it --image=busybox:1.36 -- nslookup kubernetes.default
```

### 6.3 Fallbacks si algo falla
| Fallo | Fallback |
|---|---|
| Docker/WSL2 no instala en 1 alumno | Pareja compartida + alumno usa la guía en su equipo después (entrega D1 flexible) |
| GitHub Actions no corre | Pipeline local documentado (`bash ci.sh`) con misma lógica |
| Sin ancho de banda para imágenes | Pre-descargar y `docker save/load` en USB compartido |
| kind no funciona en equipo viejo | minikube `--driver=docker` o Docker Desktop K8s (modo compatible) |

---

## 7. Post-curso

- Enviar encuesta de satisfacción (NPS + 3 abiertas) el mismo día del cierre.
- Publicar certificado de asistencia (≥80% de asistencia + proyecto aprobado).
- Compartir recursos: CKA/CKAD roadmap, repo del curso con `solution/` desbloqueada a los 7 días.
- Coordinar el siguiente curso (K8s en nube + Terraform/OpenTofu) como continuidad natural.
