# Proyecto final · Especificación y rúbrica

**Curso:** K8S-LOCAL-DEPLOY-01 (formato 5×2 h) · **Módulo:** M16 · **Día:** 5 (50 min en aula)
**Formato:** equipos de 2 (individual solo con autorización del instructor)
**Entrega:** al cierre del Día 5 · no alcanzaste → **entrega diferida a 48 h** con la misma rúbrica

---

## 1. Objetivo

Entregar una aplicación desplegable de forma **reproducible** en un clúster local limpio:
desde `kind create cluster` hasta la app en marcha en **menos de 15 minutos**, siguiendo tu
propio README.

## 2. Ruta express (la evaluada en este formato)

Con 50 min de aula se espera esto (puedes partir de `project/starter/` y del `lab08`):

1. **Repo Git** con los manifiestos de una app de **2 servicios** (web + API).
2. **Empaquetado con Helm**: un chart con `values-dev.yaml` y `values-staging.yaml`
   (ampliación con Kustomize → no evaluado).
3. **Configuración externa** (ConfigMap) y **secreto** (Secret) sin valores hardcodeados
   en los manifiestos.
4. **Exposición:** Ingress con host de prueba (o Service + documentación de cómo probarlo).
5. **Recursos** `requests/limits` y **una** demostración de rollback
   (`helm rollback` o `kubectl rollout undo`) con evidencia.
6. **Pipeline de validación y despliegue:** `bash ci.sh` local aceptado; con workflow de
   GitHub Actions corriendo = puntos extra (ver §8).
7. **README** con: arquitectura (texto o diagrama), comandos de reproducción paso a paso
   y checklist de limpieza.
8. **Evidencia de diagnóstico:** un despliegue fallido provocado + su resolución
   (comando y salida).

### 2.1 Ampliación opcional (no evaluada)
- Kustomize (base + overlays) como alternativa o complemento a Helm.
- Pipeline en la nube (GitHub Actions/GitLab CI) con job verde.
- Ingress con TLS, autoscaling, imágenes construidas por ti.

## 3. Restricciones

- Sin recursos de pago de nube: solo kind en local.
- Imágenes con **tag explícito** (nada de `latest`).
- Credenciales de ejemplo **solo** en Secret; nada de tokens reales en Git.
- El repo debe limpiarse: sin clústeres/releases huérfanos al final.
- Licencias/librerías: usar imágenes y charts públicos conocidos.

## 4. Estructura sugerida del repo

```
mi-proyecto/
├── README.md                 # requisito 7
├── app/                      # código o Dockerfile de la app (opcional si usas imágenes públicas)
├── deploy/
│   └── charts/mi-app/        # requisito 2 (o base/ + overlays/ en la ampliación)
├── ci.sh                     # requisito 6 (pipeline local)
├── .github/workflows/ci.yaml # requisito 6 ampliado (opcional)
└── evidence/
    ├── rollout.txt
    ├── rollback.txt
    └── diagnostico.md        # requisito 8
```

Puedes partir de `project/starter/` o de los labs 08/10.

## 5. Rúbrica (40 pts)

| Criterio | Pts | Indicador de 10/10 |
|---|---|---|
| Manifiestos y arquitectura | 10 | 2 servicios con labels correctos, YAML validado, sin valores hardcodeados, imágenes con tag fijo |
| Empaquetado multi-entorno (Helm) | 10 | Chart con `values-dev` + `values-staging`; cambiar de entorno no toca el chart |
| Config/secretos y exposición | 8 | ConfigMap + Secret usados, Ingress o Service probado y documentado |
| Rollback e higiene/limpieza | 6 | Evidencia de rollback + `requests/limits` + limpieza ejecutada |
| Docs y reproducibilidad | 6 | README que permite desplegar en <15 min desde `kind create cluster` |

**Umbrales:** ≥32 aprobado · ≥36 destacado · <28 recuperación (reespecificación del lab más débil).

## 6. Entrega y demo

- Repo entregado en el Git del aula **al cierre del Día 5** (diferido: 48 h).
- Demo **express de 2 min** por equipo: (1) arquitectura, (2) despliegue en vivo,
  (3) rollback, (4) limpieza.
- Revisión entre pares con checklist de 5 puntos del instructor (`03_estructura_instructor.md` §5.2).

## 7. Checklist de limpieza final (entregar firmado)

```bash
kind get clusters                       # solo curso-k8s o vacío
helm list -A                            # sin releases
kubectl get ns | grep -E 'lab|mi-'      # sin namespaces huérfanos
kind delete cluster --name curso-k8s
docker ps -a                            # sin nodos kind
kubectl config get-contexts
```

## 8. Criterios de evaluación de la demo (puntos extra)

| Señal | Puntos extra |
|---|---|
| El despliegue funciona desde un clúster recreado en vivo | +2 (techo 40) |
| Diagnóstico explicado con el flujo get→describe→events→logs | +1 |
| Pipeline rojo mostrado voluntariamente | +1 |
| Workflow de GitHub Actions con job verde en la nube | +1 (techo 40) |
