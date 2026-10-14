# Lab 11 · Observabilidad del despliegue

**Módulo:** M13 · **Día:** 4 · **Duración:** 30 min (bloque de 1 h con teoría)
**Guía:** alumno · **Carpeta:** `labs/lab11-observability/`

---

## 🎯 Objetivo

Responder "¿qué está pasando con mi despliegue?" en minutos, con el flujo
**`get → describe → events → logs → exec`** y un árbol de decisión de una página.

## 🧰 Prerrequisitos

- Clúster `curso-k8s` activo.

## 📋 Pasos

### 1. Despliega algo sano (tu referencia)

```bash
cd labs/lab11-observability
kubectl apply -f namespace.yaml
kubectl apply -f healthy.yaml
kubectl get pods -n lab11 -o wide
kubectl describe pod -n lab11 -l app=curso-web | tail -8
```

Fíjate: `Ready 1/1`, eventos sin `Warning`, `RESTARTS 0`.

### 2. Provoca un CrashLoopBackOff

```bash
kubectl apply -f broken-crashloop.yaml
kubectl get pods -n lab11
kubectl describe pod -n lab11 -l app=curso-web-roto | tail -12
kubectl logs -n lab11 -l app=curso-web-roto --tail=20
kubectl logs -n lab11 -l app=curso-web-roto --previous --tail=20
```

Responde:
- ¿Cuántos reinicios lleva?
- ¿Qué dice el evento `Back-off restarting failed container`?
- ¿Qué diferencia hay entre `logs` y `logs --previous`?

### 3. Compara sano vs roto

```bash
kubectl get pods -n lab11
kubectl get events -n lab11 --sort-by=.lastTimestamp | tail -10
```

### 4. Crea tu árbol de decisión

Completa `guia-diagnostico.md` (tiene el esqueleto). Debe caber en **una página** y cubrir:
`Pending`, `ImagePullBackOff`, `CrashLoopBackOff`, `OOMKilled`, Service sin endpoints y
`Error`/`ErrImagePull`.

### 5. Bonus: eventos y métricas

```bash
kubectl top nodes 2>/dev/null || echo "metrics-server no está instalado en kind (opcional)"
kubectl get events -n lab11 --field-selector type=Warning
```

## 📦 Entregable

- `guia-diagnostico.md` completada (árbol de decisión de 1 página).
- `evidence.txt` con la salida de `describe` y `logs --previous` del pod roto.

## ⚠️ Errores comunes

| Error | Causa | Fix |
|---|---|---|
| Mirar solo logs actuales | El contenedor ya reinició | usa `--previous` |
| Ignorar events | Hay "ruido" | `kubectl get events --sort-by=.lastTimestamp` |
| Saltar a `exec` | El contenedor ni arranca | primero describe/events |
| Confundir `Error` con `CrashLoopBackOff` | Fases distintas del fallo | mira `STATUS` y `RESTARTS` |

## 🧹 Limpieza

```bash
kubectl delete namespace lab11 --ignore-not-found
```

## 🔗 Siguiente

→ `labs/lab12-debug/` — los 6 fallos más comunes y seguridad básica.
