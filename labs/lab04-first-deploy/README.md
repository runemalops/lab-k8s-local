# Lab 04 · Primer deployment declarativo

**Módulo:** M05 · **Día:** 1 · **Duración en aula:** 30 min (incluye la práctica de kubectl del M04)
**Guía:** alumno · **Carpeta:** `labs/lab04-first-deploy/`

---

## 🎯 Objetivo

Desplegar **nginx con manifiestos declarativos**: `Namespace` + `Deployment` + `Service`,
entender quién crea a quién y comprobarlo con `kubectl`.

## 🧰 Prerrequisitos

- Clúster `curso-k8s` activo y contexto correcto.
- Completados los labs 02 y 03.

## 📋 Pasos

### 1. Lee los YAML antes de tocar nada

```bash
cd labs/lab04-first-deploy
cat namespace.yaml deployment.yaml service.yaml
```

Identifica en cada archivo: `apiVersion`, `kind`, `metadata`, `spec`.
Y responde: ¿cómo sabe el Service a qué pods apunta?

### 2. Completa el esqueleto

Rellena los TODO en `deployment.yaml` (replicas, imagen con tag, labels del pod) y
en `service.yaml` (selector, puerto).

### 3. Valida antes de aplicar

```bash
kubectl apply --dry-run=client -f namespace.yaml
kubectl apply --dry-run=client -f deployment.yaml
kubectl apply --dry-run=client -f service.yaml
kubectl kustomize . 2>/dev/null || true   # no necesario aquí
```

### 4. Despliega

```bash
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

kubectl get all -n lab04
kubectl get pods -n lab04 -l app=curso-web -o wide
```

> ⚠️ **El namespace va primero.** Si aplicas la carpeta entera con `kubectl apply -f .`
> los archivos se procesan en orden alfabético y `deployment.yaml` se intentaría crear
> *antes* que su namespace → `namespaces "lab04" not found`.

Observa la cadena: `Deployment → ReplicaSet → Pods` y el `Service → Endpoints`.

### 5. Comprueba la conectividad

```bash
# a) Vía port-forward (desde tu terminal)
kubectl port-forward svc/curso-web 8080:80 -n lab04 &
sleep 2 && curl -s http://localhost:8080 | head -5

# b) DNS interno del clúster
kubectl run tmp --rm -it --image=busybox:1.36 -n lab04 -- \
  wget -qO- http://curso-web.lab04.svc.cluster.local
```

### 6. Escala y observa el ReplicaSet

```bash
kubectl scale deployment/curso-web --replicas=3 -n lab04
kubectl get rs -n lab04
kubectl get pods -n lab04 -w     # Ctrl+C para salir
kubectl scale deployment/curso-web --replicas=2 -n lab04
```

### 7. Sabotaje controlado (2 min)

```bash
kubectl delete pod -n lab04 -l app=curso-web --wait=0
kubectl get pods -n lab04 -l app=curso-web
```

**¿Qué reparó el clúster?** Anótalo: es el modelo declarativo en acción.

## 📦 Entregable

- `namespace.yaml`, `deployment.yaml`, `service.yaml` completos en esta carpeta.
- `evidence.txt` con la salida de:
  ```bash
  kubectl get all -n lab04
  kubectl get endpoints curso-web -n lab04
  ```

## ⚠️ Errores comunes

| Error | Causa | Fix |
|---|---|---|
| Pods en `Pending` | Poca RAM / nodos insuficientes | `kubectl describe pod` → mira eventos; borra clústeres viejos |
| `ImagePullBackOff` | Tag inexistente | `nginx:1.27` (no `nginx:1.27.9`) |
| Service sin endpoints | Selector ≠ labels del pod | `kubectl get pods --show-labels` y compara con `spec.selector` |
| `curl` no responde en port-forward | Proceso no arrancó / puerto ocupado | mira el mensaje de `port-forward` y usa otro puerto host |
| Todo en `default` | Olvidaste `-n lab04` | repite con `-n lab04` |

## 🧹 Limpieza (al final del día)

```bash
kubectl delete namespace lab04 --ignore-not-found
```

## 🔗 Siguiente

→ Día 2 · `labs/lab05-config/` — configuración y secretos.
