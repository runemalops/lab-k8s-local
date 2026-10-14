# Guía del instructor · Lab 07 (M09)

**Duración:** 60 min de lab (45 min de teoría antes) · **Carpeta:** `labs/lab07-rollout/`
**Mensaje del bloque:** *"un deployment es un proceso, no un comando."*

---

## 1. Antes de clase

- [ ] Clúster activo; `nginx:1.27.0` y `nginx:1.27.1` **precargados** en la máquina demo
      (`docker pull` + `kind load docker-image` si el wifi es lento).
- [ ] Demo del rollback cronometrada (<30 s de "uh oh" a "vuelta a la normalidad").
- [ ] `solution/deployment.yaml` lista.

## 2. Timeline sugerida

| Min | Instructor | Alumno |
|---|---|---|
| 0–20 | Teoría: requests/limits, QoS, RollingUpdate, maxSurge/maxUnavailable | Notas |
| 20–35 | Demo: rollout v2 → fallo → undo en vivo | Observa |
| 35–55 | Rota de mesas | Pasos 1–6 |
| 55–60 | Puesta en común del bonus OOMKilled | Comparten |

## 3. Demo clave (cronómetro visible)

```bash
kubectl set image deployment/curso-web -n lab07 web=nginx:1.27.99   # "hola producción"
kubectl rollout status deployment/curso-web -n lab07                # bloqueo visible
kubectl rollout undo deployment/curso-web -n lab07                  # <5 s
```

Frase: **el rollback no es un plan B: es una habilidad que practicas antes de necesitarla.**

## 4. Qué no se puede saltar

1. **requests ≠ limits** (requests = garantía/planificación; limit = techo).
2. **readiness vs liveness**: una saca del balance; la otra reinicia.
3. **Tags inmutables**: `1.27.1` identifica un build; `latest` no.
4. **Historial limitado** (`revisionHistoryLimit`, por defecto 10).
5. `set image` genera una revisión: se puede deshacer, pero **no queda en Git**.

## 5. Errores esperados en el aula

| Error | Qué decir |
|---|---|
| `ImagePullBackOff` esperado (paso 4) | "Es el ejercicio: leé `describe` y cuenta la historia" |
| `rollout status` cuelgado | ¿probes? ¿imagen? → `kubectl describe pod` |
| OOMKilled en el bonus | "Tu limit era 32Mi; nginx necesita más" |
| Historial con 1 sola revisión | No habían cambios previos; aplica la imagen 1.27.1 primero |
| Alumno pierde el deployment | `kubectl apply -f deployment.yaml` desde su repo |

## 6. Comprobación de aprendizaje

Sin mirar la pantalla: "Está en producción la versión 2 y el error es nuevo. ¿Qué tres
comandos ejecutas?" Esperado: `get pods`, `describe pod`, `rollout history` → `undo`.

## 7. Entregable / checklist

- [ ] `deployment.yaml` con `resources` (requests+limits) y ambas probes.
- [ ] `rollout history` con ≥2 revisiones en `evidence.txt`.
- [ ] Evidencia del rollback tras el tag inexistente.
- [ ] Deployment en estado `Available` al terminar.
- [ ] Namespace `lab07` borrado al cierre.

## 8. Uso de `solution/`

Liberar si un alumno lleva >10 min con probes o si la demo colectiva ya mostró el YAML.
La solución incluye probes razonables para nginx (no son las únicas válidas).

## 9. Conexión con el proyecto

Requisito 5 del proyecto: "requests/limits y al menos una estrategia de rollout/rollback
demostrada" → este lab es esa evidencia.
