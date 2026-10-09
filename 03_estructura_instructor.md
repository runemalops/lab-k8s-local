# Estructura del curso — Lado del instructor

**Curso:** Introducción a Kubernetes como herramienta de Deployment (entorno local)
**Propósito:** playbook completo para preparar, dictar y cerrar el curso de 4 días.

---

## 1. Antes del curso (T-14 a T-1 días)

### 1.1 Checklist de preparación

| Plazo | Tarea | Estado |
|---|---|---|
| T-14 | Congelar repo del curso (rama `main`, tag `v1.0`) | ☐ |
| T-14 | Verificar instalación en 2–3 equipos representativos (Windows/WSL2, macOS, Linux) | ☐ |
| T-10 | Enviar **guía de instalación** al alumno (`04_estructura_estudiante.md` §2) | ☐ |
| T-7 | Recoger respuestas del pre-test (arquitectura, YAML, Docker) y survey de hardware | ☐ |
| T-5 | Preparar slides (1 por día), cheat-sheets impresas y cuentas de Git del aula | ☐ |
| T-3 | Recordatorio de instalación + prueba de verificación (§4.4 de `01_plan`) | ☐ |
| T-1 | Correr los 4 labs completos en la máquina demo; congelar versiones (kind, helm, imágenes) | ☐ |

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

## 2. Repositorio del curso (estructura)

```
curso-k8s-local/
├── README.md                     # índice y acceso a materiales
├── 01_plan_de_contenidos.md
├── 02_guia_de_contenidos_y_modulos.md
├── 03_estructura_instructor.md   # este archivo
├── 04_estructura_estudiante.md
├── slides/                       # 1 deck por día (d1..d4)
├── labs/
│   ├── lab01-containers/         # Dockerfile skeleton + solution/
│   ├── lab02-kind/               # guía create/delete
│   ├── lab03-kubectl/
│   ├── lab04-first-deploy/       # deployment/service skeleton + solution/
│   ├── lab05-config/
│   ├── lab06-ingress/
│   ├── lab07-rollout/
│   ├── lab08-helm/               # chart base + solution/
│   ├── lab09-kustomize/          # base/overlays + solution/
│   ├── lab10-cicd/               # .github/workflows/ + solution/
│   ├── lab11-observability/
│   └── lab12-debug/              # manifiestos rotos a propósito
├── project/
│   ├── SPEC.md                   # rúbrica y requisitos
│   └── starter/                  # repo base para alumnos
├── setup/
│   ├── instalacion-linux.md
│   ├── instalacion-macos.md
│   ├── instalacion-windows-wsl2.md
│   ├── verificacion.sh           # script de autocomprobación
│   └── troubleshooting-setup.md
└── solutions/                    # SOLO instructor (rama protegida o repo privado)
    ├── day1/ day2/ day3/ day4/
    └── project-reference/
```

**Regla:** los alumnos solo ven `main` sin `solutions/` (carpeta en repo privado o eliminada del fork).

---

## 3. Rutina diaria (aplicar cada día)

| Momento | Acción | Tiempo |
|---|---|---|
| 09:00 | Warm-up: 3 preguntas del día anterior + quiz | 10 min |
| 09:10 | Teoría con demo en vivo proyectada | bloques de 50–60 min |
| cada bloque | Pausa de 10 min cada 90 min | — |
| 14:00 | Lab guiado: el instructor demuestra el primer paso, luego los alumnos ejecutan | 2 h |
| 16:00 | "Clinic": alumnos levantan la mano; el instructor rota priorizando bloqueos >10 min | 45 min |
| 16:45 | Retro: qué salió, qué duele, qué viene; checklist de limpieza | 15 min |

**Reglas de aula del instructor:**
1. Nunca entregar el YAML final resuelto antes de que el alumno intente (mín. 15 min de esfuerzo).
2. Bloqueos frecuentes → pausar y hacer demo grupal (mínimo 3 alumnos con el mismo error).
3. Todo error repetido se documenta en la "Pizarra de errores" (slides del día siguiente).
4. El instructor ejecuta la limpieza en su máquina al final de cada sesión (ejemplo visible).

---

## 4. Guía de enseñanza por día (qué enfatizar)

### Día 1 — "El cluster es una máquina de estados"
- Enfatizar: **desired state**; si no está en el YAML, no existe.
- Demo clave: borrar un pod manualmente y ver cómo el Deployment lo recrea.
- Cuidado: no profundizar en control plane interno (fuera de alcance).
- Salida esperada: todos los alumnos con `kubectl get all` mostrando su nginx.

### Día 2 — "Deployment es un proceso, no un comando"
- Enfatizar: config externa, versionado de imágenes, rollback como skill obligatoria.
- Demo clave: rollout fallido → bloqueo → `rollout undo` en <30 s.
- Salida esperada: cada alumno con evidencia de rollback.

### Día 3 — "Lo que no está automatizado, no existe"
- Enfatizar: repetibilidad (mismos comandos, mismo resultado) y separación de entornos.
- Demo clave: mismo chart desplegado con `--set` distinto y luego con overlays.
- Salida esperada: pipeline verde al menos una vez por pareja.
- Riesgo: pipeline CI/CD es el bloque más frágil → tener **fallback offline** (pipeline local con `act` o ejecución paso a paso en terminal documentada).

### Día 4 — "Diagnóstico > memorización"
- Enfatizar: flujo `get → describe → events → logs`.
- Demo clave: CrashLoopBackOff resuelto en vivo sin tocar el teclado de los alumnos.
- Cierre: conectar con el ecosistema (nube, IaC, GitOps) sin abrir nuevo contenido.

---

## 5. Evaluación (detallada para el instructor)

### 5.1 Instrumentos y momentos
| Qué | Cuándo | Cómo calificar |
|---|---|---|
| Quiz diario (5 preguntas) | Fin de cada mañana | Autocheck en aula, 1 pt c/u |
| Entregables D1–D3 | Fin de día, repo del alumno | Checklist de 5 puntos por entregable |
| Proyecto final | Día 4 | Rúbrica §7 del plan (40 pts) + demo 5 min |
| Participación | Continuo | Registro del instructor (intervenciones útiles, ayuda a pares) |

### 5.2 Checklist de entregable genérico (usar en D1–D3)
- [ ] Archivos en el repo con nombres correctos.
- [ ] Manifiestos validados (`kubectl apply --dry-run=client` / `helm lint`).
- [ ] Evidencia incluida (salida de comando en archivo `evidence.txt` o captura).
- [ ] Funciona en clúster recreado desde cero (prueba de reproducibilidad).
- [ ] Limpieza ejecutada (namespaces borrados).

### 5.3 Rúbrica del proyecto final (40 pts)
| Criterio | Pts | Indicador de 10/10 |
|---|---|---|
| Manifiestos y arquitectura | 10 | 2 servicios con labels correctos, YAML validado, sin valores hardcodeados |
| Empaquetado multi-entorno | 10 | Base + 2 entornos funcionales; cambiar de entorno no toca la base |
| CI/CD | 8 | Pipeline valida y despliega; falla ante manifiesto inválido |
| Exposición/escalado | 6 | Ingress/Service probado + recurso de escalado o réplicas configuradas |
| Docs, higiene y limpieza | 6 | README reproducible + limpieza ejecutada |

**Umbrales:** ≥32 pts = aprobado · ≥36 = destacado · <28 = recuperación (reespecífico del lab más débil).

### 5.4 Recuperación
- Alumno que falla en 1 entregable → lab extra guiado (30 min, día siguiente por la mañana).
- Alumno que falla el proyecto → entrega diferida a 48 h con la misma rúbrica.

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
