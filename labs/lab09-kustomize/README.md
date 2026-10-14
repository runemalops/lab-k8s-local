# Lab 09 · Kustomize y multi-entorno

**Módulo:** M11 · **Día:** 3 · **Duración:** 45 min (bloque de 1.5 h con teoría)
**Guía:** alumno · **Carpeta:** `labs/lab09-kustomize/`

---

## 🎯 Objetivo

Mantener **una base** de manifiestos y dos **overlays** (`dev` y `staging`) que la
transforman sin duplicar archivos: `kubectl apply -k` con resultados distintos.

## 🧰 Prerrequisitos

- Clúster `curso-k8s` activo.
- `kubectl kustomize --help` funciona (viene embebido; no necesitas binario extra).

## 📋 Pasos

### 1. Construye la base

```bash
cd labs/lab09-kustomize
kubectl kustomize base
```

Revisa `base/deployment.yaml`, `base/service.yaml` y `base/kustomization.yaml`.
¿Qué le añade `labels` a todos los recursos?

### 2. Completa el overlay `dev`

Rellena los TODO de `overlays/dev/kustomization.yaml` (namespace, etiqueta de entorno,
patch de réplicas/env, tag de imagen) y valida:

```bash
kubectl kustomize overlays/dev > /tmp/dev.yaml
grep -E "namespace:|replicas:|image:|entorno:|APP_ENV" /tmp/dev.yaml
```

### 3. Completa el overlay `staging`

Igual que `dev`, pero: 3 réplicas, recursos mayores y tag más reciente en
`overlays/staging/deployment-patch.yaml` y `kustomization.yaml`.

```bash
kubectl kustomize overlays/staging > /tmp/staging.yaml
diff /tmp/dev.yaml /tmp/staging.yaml | head -40
```

### 4. Despliega los dos entornos

```bash
kubectl apply -k overlays/dev
kubectl apply -k overlays/staging

kubectl get pods -n lab09-dev -o wide
kubectl get pods -n lab09-staging -o wide
kubectl get deploy curso-web -n lab09-staging -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

### 5. Comprueba que la base no se tocó

```bash
git status
kubectl kustomize base | grep -c replicas
```

**Regla:** cambiar un entorno **nunca** debe modificar `base/`.

### 6. Helm vs Kustomize (10 min de reflexión)

Responde en `evidence.txt`:

| Pregunta | Helm | Kustomize |
|---|---|---|
| ¿Entrego un paquete a un equipo externo? | | |
| ¿Los entornos viven en el mismo repo Git? | | |
| ¿Necesito valores en tiempo de instalación? | | |

## 📦 Entregable

- Estructura `base/` + `overlays/dev` + `overlays/staging` completa.
- `evidence.txt` con la salida de `kubectl kustomize` de ambos overlays y los pods de
  los dos namespaces.

## ⚠️ Errores comunes

| Error | Causa | Fix |
|---|---|---|
| `namespaces "lab09-dev" not found` | El overlay fija namespace pero no lo crea | añade `namespace.yaml` a `resources` |
| El patch no hace nada | GVK/name no coinciden | `metadata.name` debe ser el del base (`curso-web`) |
| "No veo el cambio" | Olvidaste regenerar | `kustomize build` es en tiempo de aplicación |
| Cambié la base por error | Mala separación | deshaz con Git y mueve el cambio al overlay |
| Error con `patches` | Sintaxis antigua (`patchesStrategicMerge`) | usa `patches: - path: archivo.yaml` |

## 🧹 Limpieza

```bash
kubectl delete namespace lab09-dev lab09-staging --ignore-not-found
```

## 🔗 Siguiente

→ `labs/lab10-cicd/` — automatizar esto en un pipeline.
