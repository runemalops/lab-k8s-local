# Curso: Introducción a Kubernetes como herramienta de Deployment (entorno local)

Curso de **5 días × 2 h (10 h)** de nivel básico para estudiantes de ingeniería y developers. Todo el laboratorio corre en **equipos locales** (kind + Docker), sin costo de nube.

> Formato comprimido: la clase es teoría esencial + práctica guiada. Las extensiones
> (kubectl a fondo, Kustomize, probes/OOMKilled, plantillas Helm avanzadas, casos extra de
> debugging) quedan como **material asíncrono**.

## Documentos del curso

| Archivo | Audiencia | Contenido |
|---|---|---|
| [01_plan_de_contenidos.md](01_plan_de_contenidos.md) | Instructor + estudiante | Ficha técnica, objetivos, prerrequisitos, 16 módulos, programa de 5 días × 2 h, proyecto final y evaluación |
| [02_guia_de_contenidos_y_modulos.md](02_guia_de_contenidos_y_modulos.md) | Instructor + estudiante | Detalle de cada módulo (teoría, lab, entregable, errores comunes) |
| [03_estructura_instructor.md](03_estructura_instructor.md) | Instructor | Preparación previa, repo del curso, rutina diaria, evaluación, kit de emergencia |
| [04_estructura_estudiante.md](04_estructura_estudiante.md) | Estudiante | Instalación, reglas del lab, entregables, troubleshooting y continuidad |

## Resumen del programa (5 días × 2 h)

- **Día 1:** contenedores → arquitectura K8s → clúster local con kind → primer deployment declarativo
- **Día 2:** K8s como herramienta de deployment: config/secrets, Ingress, rollout y rollback
- **Día 3:** empaquetado de despliegues con Helm (values dev/staging)
- **Día 4:** pipeline CI/CD que despliega + diagnóstico de despliegues fallidos
- **Día 5:** seguridad (RBAC), de local a producción y proyecto final

**Asíncrono (opcional):** `lab03-kubectl`, `lab09-kustomize`, extensión de `lab07-rollout`,
plantillas avanzadas de Helm y casos 3–4 de `lab12-debug`.

---

## Instalación previa (1 semana antes del curso)

| SO | Guía | Script |
|---|---|---|
| Linux | [setup/instalacion-linux.md](setup/instalacion-linux.md) | `bash setup/install-linux.sh` |
| macOS | [setup/instalacion-macos.md](setup/instalacion-macos.md) | `bash setup/install-macos.sh` |
| Windows 10/11 | [setup/instalacion-windows-wsl2.md](setup/instalacion-windows-wsl2.md) (WSL2 + Ubuntu) | `.\setup\install-windows.ps1` (PowerShell como admin) |

Todas las rutas:

```bash
bash setup/instalar.sh            # detecta el SO y lanza el instalador adecuado
bash setup/verificacion.sh        # debe terminar todo en [OK]
```

Después de instalar, sigue la **[guía de configuración inicial](setup/configuracion-inicial.md)**
(PATH, alias, Git, editor, primer clúster, `/etc/hosts`, checklist previo al Día 1).
Si algo falla: [setup/troubleshooting-setup.md](setup/troubleshooting-setup.md).

---

## Laboratorios

Cada laboratorio incluye **guía del alumno** (`README.md`), **guía del instructor**
(`INSTRUCTOR.md`), esqueletos para completar y la carpeta `solution/` (reservada al
instructor hasta que el aula avance).

| Lab | Módulo | Día | Modalidad | Tema |
|---|---|---|---|---|
| [lab01-containers](labs/lab01-containers/) | M01 | 1 | Aula | Contenedores, imágenes y artefactos de deployment |
| [lab02-kind](labs/lab02-kind/) | M03 | 1 | Aula | Clúster local con kind (create/delete/contextos) |
| [lab03-kubectl](labs/lab03-kubectl/) | M04 | 1 | Asíncrono | kubectl: observar, inspeccionar y modificar |
| [lab04-first-deploy](labs/lab04-first-deploy/) | M05 | 1 | Aula | Primer deployment declarativo (Namespace/Deployment/Service) |
| [lab05-config](labs/lab05-config/) | M07 | 2 | Aula | Configuración y secretos (ConfigMap/Secret) |
| [lab06-ingress](labs/lab06-ingress/) | M08 | 2 | Aula | Exposición: Service, DNS e Ingress |
| [lab07-rollout](labs/lab07-rollout/) | M09 | 2 | Aula (express) | Ciclo de vida: recursos, rollout y rollback |
| [lab08-helm](labs/lab08-helm/) | M10 | 3 | Aula | Helm: charts, values, upgrade y rollback |
| [lab09-kustomize](labs/lab09-kustomize/) | M11 | 3 | Asíncrono | Kustomize: base + overlays dev/staging |
| [lab10-cicd](labs/lab10-cicd/) | M12 | 4 | Aula | CI/CD: pipeline que valida, despliega y comprueba |
| [lab11-observability](labs/lab11-observability/) | M13 | 4 | Aula | Observabilidad y árbol de decisión de diagnóstico |
| [lab12-debug](labs/lab12-debug/) | M14 | 5 | Aula (casos 1–2) | Debugging de 4 despliegues rotos + RBAC mínimo |

## Proyecto final

- [project/SPEC.md](project/SPEC.md) — requisitos, restricciones, rúbrica (40 pts) y checklist de limpieza.
- [project/starter/](project/starter/) — repo base para arrancar (manifiestos mínimos, workflow y plantillas de evidencia).

## Slides

[slides/README.md](slides/README.md) — estructura de los decks por día y material de apoyo.

---

## Reglas de oro del laboratorio (Día 1)

1. Un solo clúster por alumno: `kind create cluster --name curso-k8s`.
2. Un namespace por ejercicio (`lab01` … `lab12`).
3. Etiqueta `app.kubernetes.io/part-of: curso-k8s` en los manifiestos.
4. Imágenes siempre con **tag explícito** (nunca `:latest` en entregables).
5. Al final de cada día: borrar namespaces y recrear el clúster en <2 min.
6. Nada de `sudo` fuera de la instalación inicial.
