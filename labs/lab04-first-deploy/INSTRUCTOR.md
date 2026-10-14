# Guía del instructor · Lab 04 (M05)

**Duración:** 70 min de lab (30 min de teoría antes) · **Carpeta:** `labs/lab04-first-deploy/`
**Mensaje del bloque:** *"si no está en el YAML, no existe."*

---

## 1. Antes de clase

- [ ] Clúster `curso-k8s` activo, namespace `lab04` inexistente.
- [ ] Pizarra/diagrama: Deployment → ReplicaSet → Pod ← Service ← Endpoints.
- [ ] Tener `solution/` abierta en una pestaña aparte (no proyectarla).

## 2. Timeline sugerida

| Min | Instructor | Alumno |
|---|---|---|
| 0–20 | Teoría: Pod/Deployment/ReplicaSet/Service + YAML mínimo línea a línea | Notas |
| 20–30 | Demo: `apply` y lectura de `kubectl get all` | Observa |
| 30–65 | Rota de mesas (prioriza bloqueos >10 min) | Pasos 1–7 |
| 65–70 | Puesta en común del sabotaje (paso 7) | Comparten |

## 3. Demo clave (la del desired state)

```bash
kubectl create ns demo
kubectl create deployment d --image=nginx:1.27 -n demo
kubectl delete pod -n demo -l app=d --wait=0     # "sabotaje"
kubectl get pods -n demo -w                      # el Deployment lo recrea
```

Cerrar con la frase: **el control plane compara el estado real con el deseado y actúa.**

## 4. Qué explicar del YAML (línea a línea)

- `apiVersion/kind`: de qué API hablar y qué recurso es.
- `metadata.namespace`: **si no está, va a `default`** (error nº 1 del día).
- `spec.replicas`: deseado, no "cuántos hay".
- `spec.selector.matchLabels` **debe coincidir** con `spec.template.metadata.labels`.
- `spec.template.spec.containers[].image`: tag explícito.
- `Service.spec.selector` → mismatch = **sin endpoints** = el error de red más común.

## 5. Errores esperados en el aula

| Error | Qué decir / hacer |
|---|---|
| `selector` no coincide | "Dime dos comandos: `kubectl get pods --show-labels` y `kubectl get svc -o yaml`" |
| Pods `Pending` (equipo corto) | Libera RAM: `kind get clusters`, borra extras, `docker system prune -f` |
| Port-forward "ya en uso" | Cambia puerto: `kubectl port-forward svc/curso-web 8081:80` |
| `curl` vacío | ¿está el proceso `&`? ¿correcto el puerto? prueba `kubectl logs` |
| Alumno con `-n` olvidado | Hazle repetir la regla 2 en voz alta |

## 6. Comprobación de aprendizaje

Alguien debe poder responder **sin mirar**: "Si borro dos pods, ¿quién los rehace y cómo
lo sabe?". Esperado: el Deployment/ReplicaSet a partir del desired state en el YAML/API.

## 7. Entregable / checklist (5 pts)

- [ ] 3 archivos con nombres correctos y TODOs completados.
- [ ] `kubectl apply --dry-run=client` sin errores.
- [ ] `kubectl get all -n lab04` con 2 pods `Running` + Service + endpoints.
- [ ] `evidence.txt` con fecha, comando y salida.
- [ ] Namespace `lab04` borrado al final del día.

## 8. Uso de `solution/`

Abrir solo cuando:
- un alumno lleve >10 min con el mismo error de selector, o
- falte <5 min para el cierre y nadie tenga endpoints.

Comparar en pantalla: `spec.selector` vs `spec.template.metadata.labels`.

## 9. Cierre del Día 1

Recordar la rutina de limpieza (`01_plan_de_contenidos.md` §8): borrar namespaces,
destruir el clúster y recrearlo en <2 min. Mañana el foco pasa de "crear" a "cambiar".
