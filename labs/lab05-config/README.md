# Lab 05 · Configuración y secretos

**Módulo:** M07 · **Día:** 2 · **Duración:** 45 min (bloque de 1.5 h con teoría)
**Guía:** alumno · **Carpeta:** `labs/lab05-config/`

---

## 🎯 Objetivo

Sacar la configuración y las credenciales **fuera de la imagen**: `ConfigMap` para texto,
`Secret` para datos sensibles, inyectados como variables de entorno **y** como archivos.

## 🧰 Prerrequisitos

- Clúster `curso-k8s` activo y contexto correcto.
- Leído el bloque de teoría de M07 (ConfigMap, Secret, `envFrom`, volúmenes).

## 📋 Pasos

### 1. Inspecciona los manifiestos

```bash
cd labs/lab05-config
cat configmap.yaml secret.yaml deployment.yaml
```

Localiza: ¿dónde se inyecta el ConfigMap como **env** y como **archivo**? ¿y el Secret?

### 2. Completa los TODO

| Archivo | TODO |
|---|---|
| `configmap.yaml` | clave `APP_ENV`, clave `GREETING` y archivo `index.html` |
| `secret.yaml` | `stringData` con usuario y contraseña de ejemplo |
| `deployment.yaml` | `envFrom`, `secretKeyRef`/`secretRef` y el `volumeMount` del ConfigMap |

### 3. Valida y despliega

```bash
kubectl apply --dry-run=client -f configmap.yaml
kubectl apply --dry-run=client -f secret.yaml
kubectl apply --dry-run=client -f deployment.yaml

kubectl apply -f namespace.yaml && sleep 2
kubectl apply -f configmap.yaml -f secret.yaml -f deployment.yaml
kubectl get all -n lab05
```

### 4. Comprueba las dos vías de inyección

```bash
# a) variables de entorno
POD=$(kubectl get pods -n lab05 -l app=curso-web -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n lab05 $POD -- env | grep -E 'APP_ENV|GREETING|DB_'

# b) archivos montados
kubectl exec -n lab05 $POD -- ls -la /etc/app-secret
kubectl exec -n lab05 $POD -- cat /etc/app-secret/username
kubectl exec -n lab05 $POD -- cat /usr/share/nginx/html/index.html

# c) la página refleja el ConfigMap
kubectl port-forward svc/curso-web 8080:80 -n lab05 &
sleep 2 && curl -s http://localhost:8080 | head -8
```

### 5. Cambio de configuración en caliente

1. Edita `configmap.yaml` (cambia el saludo del `index.html`).
2. `kubectl apply -f configmap.yaml`
3. Espera ~60 s y vuelve a hacer `curl` → **el archivo ya cambió** (el kubelet lo sincroniza).
4. Ahora cambia `APP_ENV` (variable de entorno) y aplica:
   ```bash
   kubectl apply -f configmap.yaml
   kubectl exec -n lab05 $POD -- env | grep APP_ENV   # NO cambió
   kubectl rollout restart deployment/curso-web -n lab05
   kubectl rollout status deployment/curso-web -n lab05
   kubectl exec -n lab05 $POD -- env | grep APP_ENV   # ahora sí
   ```

**Conclusión que debes anotar:** los archivos se propagan solos; las **env vars requieren
restart**.

### 6. Buenas prácticas del Secret

```bash
kubectl get secret -n lab05 -o yaml          # base64 ≠ cifrado
echo "ZGVtby1wYXNzd29yZC0xMjM=" | base64 -d   # ¡cualquiera lo lee!
```

Responde en `evidence.txt`: ¿por qué un Secret en Git es un problema?

## 📦 Entregable

- `configmap.yaml`, `secret.yaml`, `deployment.yaml` completos (valores de ejemplo).
- `evidence.txt` con:
  - salida de `kubectl exec ... env | grep APP_ENV` **antes y después** del rollout restart,
  - salida de `kubectl get secret -n lab05 -o yaml`.

## ⚠️ Errores comunes

| Error | Causa | Fix |
|---|---|---|
| Env vars no cambian tras editar ConfigMap | Falta restart | `kubectl rollout restart deployment/...` |
| Clave de Secret inválida en `env.name` | Guiones/normalización | usa claves en `SCREAMING_SNAKE_CASE` o `envFrom` |
| Secret "NoSecretData"/vacío | Usaste `data` en vez de `stringData` | usa `stringData` con texto plano |
| `invalid syntax` en YAML | sangrado o dos puntos | `kubectl apply --dry-run=client -f <file>` |
| Archivo no montado | `volumeMounts` sin `volumes` (o al revés) | ambos deben estar declarados |

## 🧹 Limpieza

```bash
kubectl delete namespace lab05 --ignore-not-found
```

## 🔗 Siguiente

→ `labs/lab06-ingress/` — exponer servicios dentro y fuera del clúster.
