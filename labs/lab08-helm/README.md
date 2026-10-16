# Lab 08 · Helm: empaquetando despliegues

**Módulo:** M10 · **Día:** 3 · **Duración en aula:** 75 min (40 min parte 1 + 35 min parte 2)
**Guía:** alumno · **Carpeta:** `labs/lab08-helm/`

---

## 🎯 Objetivo

Convertir los manifiestos sueltos del Día 2 en un **chart parametrizado y versionado**
con dos archivos de values (`dev` y `staging`) y ciclo `install → upgrade → rollback`.

## 🧰 Prerrequisitos

- Clúster `curso-k8s` activo, namespace `lab06` **borrado** (el Ingress exige host+path únicos).
- `helm version --short` → `v3.16.x`.

## 📋 Pasos

### 1. Mira un chart ya generado

```bash
cd labs/lab08-helm
helm create plantilla-demo
find plantilla-demo -type f | sort
cat plantilla-demo/values.yaml | head -30
rm -rf plantilla-demo        # era solo para mirar
```

### 2. Completa el esqueleto del chart

En `chart/` encuentra los TODO y complétalos:

| Archivo | TODO |
|---|---|
| `templates/web-deployment.yaml` | `replicas` desde values, imagen compuesta, `env` con `range`, `resources` |
| `templates/web-service.yaml` | puerto desde values |
| `templates/api-deployment.yaml` | crea el deployment del servicio api (patrón del web) |
| `templates/api-service.yaml` | crea el service del api |
| `templates/ingress.yaml` | Ingress **solo si** `.Values.ingress.enabled` |

### 3. Valida siempre antes de instalar

```bash
helm lint chart/
helm template web chart/ | head -40
helm template web chart/ -f chart/values-dev.yaml > /tmp/rendered.yaml
```

> Regla de oro: **`helm template` antes que `helm install`**. Si el render está mal,
> no toques el clúster.

### 4. Instala por entornos

```bash
kubectl apply -f namespace-lab08.yaml   # o: kubectl create ns lab08

helm upgrade --install web ./chart -n lab08 -f ./chart/values-dev.yaml
kubectl get all -n lab08

helm upgrade web ./chart -n lab08 -f ./chart/values-staging.yaml
kubectl get deploy -n lab08 -o wide
```

### 5. Rollback de Helm

```bash
helm list -n lab08
helm history web -n lab08
helm rollback web 1 -n lab08
helm status web -n lab08 | head -10
```

### 6. Valora el coste

Responde en `evidence.txt`:
- ¿Qué gana el despliegue con Helm respecto a los YAML sueltos?
- ¿Qué pierde (complejidad, estado, curva de aprendizaje)?

## 📦 Entregable

- Chart funcional en `chart/` (con `api` e `ingress` incluidos).
- `values-dev.yaml` y `values-staging.yaml` con diferencias reales (réplicas, tag, ingress).
- `evidence.txt` con `helm history` (≥2 revisiones) y la salida de `helm template`.

## ⚠️ Errores comunes

| Error | Causa | Fix |
|---|---|---|
| `YAML parse error` al instalar | Plantilla rota | `helm template` para ver el render |
| `host ... is already defined` | Otro Ingress usa el mismo host+path | borra el ns del lab anterior o usa otro host |
| Valores no aplican | Olvidaste `-f values-x.yaml` o el `--set` | `helm get values web -n lab08` |
| Release "pending-install" | Instalación interrumpida | `helm uninstall web -n lab08` |
| Nombres raros (`web-curso-web-web`) | release + nombre del chart | normal; puedes sobreescribir con `nameOverride` |

## 🧹 Limpieza

```bash
helm uninstall web -n lab08
kubectl delete namespace lab08 --ignore-not-found
```

## 🔗 Siguiente

→ `labs/lab09-kustomize/` — la alternativa "YAML puro" al empaquetado.
