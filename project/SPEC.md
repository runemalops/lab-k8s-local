# Proyecto final · Especificación y rúbrica

**Curso:** K8S-LOCAL-DEPLOY-01 · **Módulo:** M16 · **Día:** 4 (2.5 h + 30 min de evaluación)
**Formato:** equipos de 2 (individual solo con autorización del instructor)

---

## 1. Objetivo

Entregar una aplicación desplegable de forma **reproducible y automatizada** en un
clúster local limpio: desde `kind create cluster` hasta la app en marcha en **menos de
15 minutos**, siguiendo tu propio README.

## 2. Requisitos (obligatorios)

1. **Repo Git** con los manifiestos de una app de **2 servicios** (web + API).
2. **Empaquetado** con Helm **o** Kustomize, parametrizable en al menos `dev` y `staging`.
3. **Configuración externa** (ConfigMap) y **secreto** (Secret) sin valores hardcodeados
   en los manifiestos.
4. **Exposición:** Ingress con host de prueba (o Service si no hay controlador) +
   documentación de cómo probarlo.
5. **Recursos** `requests/limits` y **al menos una** demostración de rollout/rollback.
6. **Pipeline CI/CD** (GitHub Actions o GitLab CI) que valide (`kubeconform` o
   `kubectl apply --dry-run=client`), despliegue al clúster y tenga **job verde**.
7. **README** con: arquitectura (texto o diagrama), comandos de reproducción paso a paso
   y checklist de limpieza.
8. **Evidencia de diagnóstico:** un despliegue fallido provocado + su resolución
   (comando y salida).

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
│   ├── base/  o  charts/    # requisito 2
│   └── overlays/ o values-*.yaml
├── .github/workflows/ci.yaml # requisito 6
└── evidence/
    ├── rollout.txt
    ├── rollback.txt
    └── diagnostico.md        # requisito 8
```

Puedes partir de `project/starter/` o de los labs 08/09/10.

## 5. Rúbrica (40 pts)

| Criterio | Pts | Indicador de 10/10 |
|---|---|---|
| Manifiestos y arquitectura | 10 | 2 servicios con labels correctos, YAML validado, sin valores hardcodeados, imágenes con tag fijo |
| Empaquetado multi-entorno | 10 | Base + 2 entornos funcionales; cambiar de entorno no toca la base |
| CI/CD | 8 | Pipeline valida y despliega; falla ante manifiesto inválido; job verde documentado |
| Exposición/escalado | 6 | Ingress/Service probado + réplicas o escalado configurado y demostrado |
| Docs, higiene y limpieza | 6 | README reproducible + checklist de limpieza ejecutado |

**Umbrales:** ≥32 aprobado · ≥36 destacado · <28 recuperación (reespecificación del lab más débil).

## 6. Entrega y demo

- Repo entregado en el Git del aula antes de las 16:00 del Día 4.
- Demo de **5 min** por equipo: (1) arquitectura, (2) despliegue en vivo, (3) rollback,
  (4) pipeline, (5) limpieza.
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

## 8. Criterios de evaluación de la demo

| Señal | Puntos extra |
|---|---|
| El despliegue funciona desde un clúster recreado en vivo | +2 (techo 40) |
| Diagnóstico explicado con el flujo get→describe→events→logs | +1 |
| Pipeline rojo mostrado voluntariamente | +1 |
