# Diagnóstico de despliegues — respuesta de referencia

**Pareja:** instructor · **Fecha:** ejemplo

## Caso 1 · `broken/01-imagepull.yaml`

| Campo | Respuesta |
|---|---|
| Síntoma | `0/1 ImagePullBackOff` (antes `ErrImagePull`) |
| Causa raíz | Tag inexistente: `nginx:1.27.999` no está en Docker Hub |
| Comando que lo demuestra | `kubectl describe pod -n lab12 -l app=fallo1` → `Failed to pull image ... not found` |
| Fix | Usar un tag real: `nginx:1.27` |

## Caso 2 · `broken/02-selector.yaml`

| Campo | Respuesta |
|---|---|
| Síntoma | Pods `Running` pero `kubectl get endpoints fallo2` vacío |
| Causa raíz | `Service.spec.selector: app=curso-web` no coincide con `app=fallo2` de los pods |
| Comando que lo demuestra | `kubectl get pods --show-labels -n lab12` vs `kubectl get svc fallo2 -o yaml` |
| Fix | Selector `app: fallo2` (o etiquetar los pods igual) |

## Caso 3 · `broken/03-pending.yaml`

| Campo | Respuesta |
|---|---|
| Síntoma | Pod `Pending` para siempre |
| Causa raíz | `resources.requests.cpu: "8"` supera la capacidad del nodo de kind |
| Comando que lo demuestra | `kubectl describe pod fallo3 -n lab12` → `Insufficient cpu` |
| Fix | Pedir `100m` (o lo que el nodo pueda dar) |

## Caso 4 · `broken/04-oom.yaml`

| Campo | Respuesta |
|---|---|
| Síntoma | `Running` con `RESTARTS` creciendo → `CrashLoopBackOff` |
| Causa raíz | `limits.memory: 16Mi` → el kernel mata el contenedor (`OOMKilled`) |
| Comando que lo demuestra | `describe` → `Last State: Terminated, Reason: OOMKilled, Exit Code: 137` |
| Fix | Subir el limit (p.ej. `128Mi`) y ajustar el request |

## Seguridad

1. `cluster-admin` para todos elimina el principio de mínimo privilegio: un error o
   compromiso afecta al clúster completo.
2. Los Secret de K8s no están cifrados por defecto (base64 ≠ cifrado): credenciales de
   producción van a un secret manager externo (Vault, KMS de la nube…).
3. Tag fijo = build reproducible y rollback posible; imagen de origen conocido reduce el
   riesgo de supply chain.

## `kubectl auth can-i`

| Pregunta | Esperado | Real |
|---|---|---|
| `list pods` | yes | yes |
| `delete pods` | no | no |
| `list secrets` | no | no |
