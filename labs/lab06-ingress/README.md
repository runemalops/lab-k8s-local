# Lab 06 · Exposición: Service, DNS e Ingress

**Módulo:** M08 · **Día:** 2 · **Duración en aula:** 20 min (el controlador ingress-nginx ya está instalado)
**Guía:** alumno · **Carpeta:** `labs/lab06-ingress/`

---

## 🎯 Objetivo

Exponer dos servicios (**web** y **api**) **dentro y fuera** del clúster con un Ingress
basado en paths (`app.local/` y `app.local/api`), y comprobar el DNS interno.

## 🧰 Prerrequisitos

- Clúster `curso-k8s` activo.
- Labs 04 y 05 entendidos (Deployment + Service).

## 📋 Pasos

### 1. Instala el controlador Ingress (ingress-nginx para kind)

```bash
cd labs/lab06-ingress
bash install-ingress.sh
kubectl get pods -n ingress-nginx
```

Espera a que el pod del controlador esté `Running` y `1/1`.

### 2. Despliega la app de dos servicios

Revisa y completa `apps.yaml` (deployment + service de `web` y de `api`), luego:

```bash
kubectl apply -f namespace.yaml && sleep 2
kubectl apply -f apps.yaml
kubectl get all -n lab06
```

### 3. Comprueba el DNS interno

```bash
kubectl run tmp --rm -i --restart=Never --image=busybox:1.36 -n lab06 -- \
  wget -qO- --timeout=5 http://web.lab06.svc.cluster.local
kubectl run tmp --rm -i --restart=Never --image=busybox:1.36 -n lab06 -- \
  wget -qO- --timeout=5 http://api.lab06.svc.cluster.local
```

¿Notas la forma del nombre? `<servicio>.<namespace>.svc.cluster.local`

### 4. Crea el Ingress

Completa el TODO de `ingress.yaml` (backends de `/` y `/api`) y aplica:

```bash
kubectl apply -f ingress.yaml
kubectl get ingress -n lab06
kubectl describe ingress curso-web -n lab06
```

### 5. Pruébalo desde fuera

**Opción A — si creaste el clúster con `kind-config.yaml` (puertos 80/443):**

```bash
curl -s -H "Host: app.local" http://localhost/ | head -5
curl -s -H "Host: app.local" http://localhost/api
```

**Opción B — port-forward al controlador (funciona siempre):**

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
# en otra terminal:
curl -s -H "Host: app.local" http://localhost:8080/ | head -5
curl -s -H "Host: app.local" http://localhost:8080/api
```

**Opción C — entrada en `/etc/hosts`:** `127.0.0.1 app.local` (ver
`setup/configuracion-inicial.md` §6) y luego `curl http://app.local/api`.

### 6. Observa lo que NO funciona

```bash
kubectl get svc curso-web -n lab04 2>/dev/null   # si aún existe un lab04
# Un ClusterIP NO es alcanzable desde fuera del clúster:
curl -s --max-time 3 http://$(kubectl get svc web -n lab06 -o jsonpath='{.spec.clusterIP}') || echo "Correcto: no se puede alcanzar desde fuera"
```

### 7. Errores provocados (2 min)

1. Cambia el path del Ingress a `/wrong` y aplica → `curl /api` ya no responde (404).
2. Vuelve a aplicar la versión buena.

## 📦 Entregable

- `apps.yaml` + `ingress.yaml` completos.
- `evidence.txt` con la salida de los dos `curl` (uno para `/` y otro para `/api`).

## ⚠️ Errores comunes

| Error | Causa | Fix |
|---|---|---|
| `404 default backend` | Host o path no coinciden | `curl -H "Host: app.local"`; revisa `spec.rules[].host` |
| Controlador `Pending`/`Error` | Manifest incompatible | reinstala con `bash install-ingress.sh` |
| `ingressClassName` vacío | Falta `ingressClassName: nginx` | añádelo al Ingress |
| `Service "x" has no ingress` (en describe) | Backend inexistente o puerto mal | `kubectl get svc -n lab06` |
| El Service responde pero la app no | Deployment sin labels del selector | `kubectl get pods --show-labels` |
| 404 con path bien | Orden de las reglas / pathType | usa `Prefix` y `/api` antes que `/` |

## 🧹 Limpieza

```bash
kubectl delete namespace lab06 --ignore-not-found
# el controlador (ns ingress-nginx) lo puedes dejar para el resto del día
```

## 🔗 Siguiente

→ `labs/lab07-rollout/` — ciclo de vida del despliegue.
