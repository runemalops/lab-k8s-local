# Lab 07 · Ciclo de vida del despliegue: recursos, rollout y rollback

**Módulo:** M09 · **Día:** 2 · **Duración en aula:** 10 min (versión *express*: rollout → fallo → rollback; el lab completo de 60 min es **ASÍNCRONO**)
**Guía:** alumno · **Carpeta:** `labs/lab07-rollout/`

---

## 🎯 Objetivo

Controlar una actualización **versionada** y recuperarte de un release malo:
`requests/limits`, health probes, `rollout status/history/undo` y versionado de imágenes.

## 🧰 Prerrequisitos

- Clúster `curso-k8s` activo.
- Labs 04 y 05 entendidos.

## 📋 Pasos

### 1. Revisa el manifiesto

Completa `deployment.yaml`:

| TODO | Qué falta |
|---|---|
| 1 | `resources.requests` y `limits` |
| 2 | `readinessProbe` |
| 3 | `livenessProbe` |
| 4 | Tag de imagen inicial (`nginx:1.27.0`) |

```bash
kubectl apply -f namespace.yaml && sleep 2
kubectl apply -f deployment.yaml
kubectl rollout status deployment/curso-web -n lab07
kubectl get pods -n lab07 -o wide
```

### 2. Mira los recursos asignados

```bash
kubectl describe deployment curso-web -n lab07 | grep -A5 "Limits\|Requests"
kubectl top pod -n lab07 2>/dev/null || echo "metrics-server no instalado (opcional en local)"
```

### 3. Rollout a una versión nueva

```bash
kubectl set image deployment/curso-web -n lab07 web=nginx:1.27.1
kubectl rollout status deployment/curso-web -n lab07
kubectl rollout history deployment/curso-web -n lab07
```

Observa: pods viejos terminando y nuevos arrancando (**RollingUpdate**).

> 💡 **Bonus:** el historial no dice qué cambió (`CHANGE-CAUSE: <none>`). Anota el cambio
> para que el historial sea útil:
> ```bash
> kubectl annotate deployment curso-web -n lab07 \
>   kubernetes.io/change-cause="imagen 1.27.0 -> 1.27.1" --overwrite
> kubectl rollout history deployment/curso-web -n lab07
> ```

### 4. Rollout fallido → rollback

```bash
kubectl set image deployment/curso-web -n lab07 web=nginx:1.27.99
kubectl rollout status deployment/curso-web -n lab07 --timeout=90s   # fallará
kubectl get pods -n lab07                      # mira ImagePullBackOff
kubectl describe pod -n lab07 -l app=curso-web | grep -A3 "Warning"
```

Recupéralo:

```bash
kubectl rollout undo deployment/curso-web -n lab07
kubectl rollout status deployment/curso-web -n lab07
kubectl rollout history deployment/curso-web -n lab07
```

### 5. Imperativo vs declarativo

1. Aplica el cambio con `set image` (imperativo) y guarda el YAML vivo:
   ```bash
   kubectl get deployment curso-web -n lab07 -o yaml > deployment-live.yaml
   ```
2. Aplica tu `deployment.yaml` (declarativo) → vuelve a la versión del archivo.
3. Compara: `diff <(grep -E 'image:' deployment-live.yaml) <(grep -E 'image:' deployment.yaml)`

**Conclusión:** `set image` es útil en emergencias; **Git es la fuente de verdad**.

### 6. (Bonus) Provoca un OOMKilled

```bash
kubectl patch deployment curso-web -n lab07 --type=json -p='[{"op":"replace","path":"/spec/template/spec/containers/0/resources/limits/memory","value":"32Mi"}]'
kubectl rollout status deployment/curso-web -n lab07
kubectl get pods -n lab07     # verás RESTARTS y OOMKilled en describe
kubectl rollout undo deployment/curso-web -n lab07
```

## 📦 Entregable

- `deployment.yaml` con resources y probes completos.
- `evidence.txt` con:
  - `kubectl rollout history deployment/curso-web -n lab07` (mínimo 2 revisiones),
  - evidencia del rollback tras el tag inexistente.

## ⚠️ Errores comunes

| Error | Causa | Fix |
|---|---|---|
| `ImagePullBackOff` | Tag inexistente o typo | `describe pod` → corregir imagen |
| `rollout status` se queda "waiting" | Probes mal calibradas o app rota | `describe` + `logs`; `rollout undo` |
| OOMKilled | limits demasiado bajos | sube el limit o revisa el consumo |
| Reinicios infinitos | livenessProbe demasiado agresiva | sube `initialDelaySeconds` / baja `periodSeconds` |
| El deployment "olvida" el cambio | Alguien aplicó un YAML viejo | Git es la fuente de verdad; vuelve a aplicar la versión buena |

## 🧹 Limpieza

```bash
kubectl delete namespace lab07 --ignore-not-found
```

## 🔗 Siguiente

→ Día 3 · `labs/lab08-helm/` — empaquetar estos despliegues.
