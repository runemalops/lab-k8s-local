# Lab 12 · Debugging de despliegues fallidos y seguridad básica

**Módulo:** M14 · **Día:** 4 · **Duración:** 40 min (bloque de 2 h con teoría)
**Guía:** alumno · **Carpeta:** `labs/lab12-debug/`

---

## 🎯 Objetivo

Diagnosticar y **arreglar 4 despliegues rotos** (entregados rotos a propósito) y aplicar
el mínimo viable de seguridad: `ServiceAccount` + `Role` + `RoleBinding` con permisos
acotados y verificados con `kubectl auth can-i`.

## 🧰 Prerrequisitos

- Clúster `curso-k8s` activo.
- Lab 11 completado (flujo de diagnóstico).

## 📋 Parte 1 · Práctica de diagnóstico (en parejas)

### 1. Crea el namespace y mira los manifiestos

```bash
cd labs/lab12-debug
kubectl apply -f namespace.yaml
ls broken/
```

### 2. Diagnostica y arregla cada uno

Para **cada** archivo de `broken/`, completa la tabla de `diagnostico.md`:
síntoma → causa raíz → comando que lo demuestra → fix.

| # | Archivo | Síntoma esperado |
|---|---|---|
| 1 | `01-imagepull.yaml` | `ImagePullBackOff` |
| 2 | `02-selector.yaml` | Service sin endpoints |
| 3 | `03-pending.yaml` | Pod `Pending` |
| 4 | `04-oom.yaml` | `OOMKilled` / CrashLoop |

```bash
kubectl apply -f broken/01-imagepull.yaml
kubectl get pods -n lab12 -w        # Ctrl+C
kubectl describe pod -n lab12 -l app=fallo1 | tail -8
# ...repite con cada uno (usa un label distinto por caso)
```

Guarda las versiones arregladas en `fixed/` (créala tú) y vuelve a aplicarlas hasta
verlas `Running` o con endpoints.

### 3. Comprueba tus arreglos

```bash
kubectl get pods -n lab12
kubectl get endpoints -n lab12
kubectl top pods -n lab12 2>/dev/null || true
```

## 📋 Parte 2 · Seguridad básica

### 4. RBAC de mínimo privilegio

Revisa y completa `rbac.yaml` (ServiceAccount + Role que solo permite `get/list` de pods
+ RoleBinding):

```bash
kubectl apply --dry-run=client -f rbac.yaml
kubectl apply -f rbac.yaml
```

### 5. Verifica con `kubectl auth can-i`

```bash
kubectl auth can-i list pods -n lab12 --as=system:serviceaccount:lab12:curso-viewer
kubectl auth can-i delete pods -n lab12 --as=system:serviceaccount:lab12:curso-viewer
kubectl auth can-i list secrets -n lab12 --as=system:serviceaccount:lab12:curso-viewer
```

Esperado: `yes`, `no`, `no`.

### 6. Buenas prácticas de secretos y contexto

Responde en `diagnostico.md`:
- ¿Por qué `cluster-admin` a todo el equipo es un error?
- ¿Qué NO debería ir en un `Secret` de Kubernetes y a dónde sí debería ir?
- ¿Por qué las imágenes deben llevar tag fijo y origen conocido?

## 📦 Entregable

- `diagnostico.md` completo (4 casos: síntoma, causa, evidencia, fix).
- `rbac.yaml` funcional con las 3 respuestas de `auth can-i`.
- `evidence.txt` con `kubectl get pods -n lab12` final (todo sano o arreglado).

## ⚠️ Errores comunes

| Error | Causa | Fix |
|---|---|---|
| "Arreglé" cambiando el label del Service y no del pod | Selectores en dos lados | el selector debe coincidir con el label del pod |
| Suben el limit de memoria sin mirar | Causa raíz era el consumo | `describe` → mira `Last State: Reason: OOMKilled` |
| `auth can-i` da siempre `yes` | Falta `--as=system:serviceaccount:...` | copia el prefijo completo |
| RBAC "funciona" pero con permisos de más | Role demasiado amplio | solo `get`, `list` en `pods` |
| Borraron el namespace y perdieron todo | Era esperado: el ns es la unidad de limpieza | reaplica desde tu repo |

## 🧹 Limpieza (final del curso)

```bash
kubectl delete namespace lab12 --ignore-not-found
kind delete cluster --name curso-k8s
kubectl config get-contexts
```

## 🔗 Siguiente

→ Proyecto final: `project/SPEC.md`
