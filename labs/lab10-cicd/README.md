# Lab 10 · CI/CD: el pipeline que despliega

**Módulo:** M12 · **Día:** 3 · **Duración:** 70 min + 30 min demo (bloque de 2.5 h con teoría)
**Guía:** alumno · **Carpeta:** `labs/lab10-cicd/`

---

## 🎯 Objetivo

Automatizar **validar → desplegar → comprobar** con un pipeline (GitHub Actions) y tener
una alternativa local (`ci.sh`) para cuando el runner no esté disponible.

## 🧰 Prerrequisitos

- Cuenta en GitHub/GitLab con el repo del curso (o un fork).
- Clúster `curso-k8s` activo para el pipeline local.

## 📋 Pasos

### 1. Ejecuta el pipeline local

```bash
cd labs/lab10-cicd
bash ci.sh
```

Esto hace exactamente las 4 fases del pipeline: render → validar → (kubeconform) →
desplegar y comprobar. Debe terminar con `[OK] Pipeline local superado`.

### 2. Comprueba la validación (job rojo simulado)

```bash
sed -i.bak 's/nginx:1.27/nginx:1.27.999/' manifests/deployment.yaml
bash ci.sh || echo "¡Fallo detectado como se esperaba!"
mv manifests/deployment.yaml.bak manifests/deployment.yaml
```

> Este es el paso que protege la rama principal: **si el manifiesto es inválido, no llega
> al clúster**.

### 3. Completa el workflow de GitHub Actions

Rellena los TODO de `.github/workflows/ci.yaml`:

| TODO | Qué poner |
|---|---|
| 1 | `kubectl kustomize "$KUSTOMIZE_DIR" > rendered.yaml` |
| 2 | descarga de `kubeconform` y `./kubeconform -summary rendered.yaml` |
| 3 | `uses: helm/kind-action@v1.10.0` con `cluster_name: curso-k8s` |
| 4 | render + `kubectl apply -f rendered.yaml` |
| 5 | `kubectl rollout status deployment/curso-web -n "$NS" --timeout=180s` |

Pista: `solution/.github/workflows/ci.yaml` tiene la versión completa (úsala solo si
llevas >15 min).

### 4. Publícalo en GitHub

```bash
git add .github/workflows/ci.yaml
git commit -m "ci: pipeline de validación y despliegue a kind"
git push origin main
```

Mira la pestaña **Actions**: el job `validate` debe quedar **verde**.

### 5. Provoca un job rojo

Edita un manifiesto con un error (por ejemplo `replicas: "dos"`), haz push a una rama y
abre un PR. El job `validate` debe fallar. **Sube la captura** (esa es la evidencia roja).

### 6. Demo del instructor (GitOps)

Observa la demo de Flux/ArgoCD: en lugar de "push → aplica", el clúster **observa Git**
y aplica solo. Apunta 3 diferencias con tu pipeline.

## 📦 Entregable

- Workflow `.github/workflows/ci.yaml` completo en tu repo.
- `evidence.txt` con: captura del **job verde** + captura del **job rojo** de validación.
- Nota de 5 líneas: ¿qué añadirías para un entorno de producción? (ambientes, revision
  por humanos, secretos, aprobaciones…).

## ⚠️ Errores comunes

| Error | Causa | Fix |
|---|---|---|
| Job rojo en "Kustomize build" | YAML mal renderizado | ejecuta `kubectl kustomize` en local |
| `no matching manifest` | Ruta relativa incorrecta | revisa `KUSTOMIZE_DIR` |
| `kind create` falla en el runner | Recursos del runner | usa `helm/kind-action` (ya optimiza) |
| Deploy sin comprobación | Falta `rollout status` | el pipeline no debe dar verde sin comprobar |
| Kubeconfig no encontrado | Esperabas un clúster externo | en este lab el clúster **se crea en el job** |

## 🧹 Limpieza

```bash
kubectl delete namespace lab10 --ignore-not-found
```

## 🔗 Siguiente

→ Día 4 · `labs/lab11-observability/` — diagnosticar lo que acaba de desplegar.
