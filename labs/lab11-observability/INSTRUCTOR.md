# Guía del instructor · Lab 11 (M13)

**Duración:** 30 min de lab (25 min de teoría antes) · **Carpeta:** `labs/lab11-observability/`
**Mensaje del bloque:** *"diagnóstico > memorización."*

---

## 1. Antes de clase

- [ ] Clúster activo; ns `lab11` inexistente.
- [ ] Demo cronometrada: CrashLoopBackOff resuelto en vivo **sin tocar el teclado del alumno**.
- [ ] Pizarra con el flujo: `get → describe → events → logs → exec`.

## 2. Timeline sugerida

| Min | Instructor | Alumno |
|---|---|---|
| 0–10 | Teoría: señales (logs/events/métricas) y el flujo | Notas |
| 10–20 | Demo en vivo del pod roto | Observa |
| 20–35 | Rota de mesas | Pasos 1–5 |
| 35–40 | Puesta en común del árbol de decisión | Comparan |

## 3. Demo clave (la que no se salta)

```bash
kubectl apply -f labs/lab11-observability/broken-crashloop.yaml
kubectl get pods -n lab11                       # 0/1 CrashLoopBackOff
kubectl describe pod -n lab11 -l app=curso-web-roto | grep -A5 Events
kubectl logs -n lab11 -l app=curso-web-roto --previous
```

Narración: *"primero el estado, luego el por qué, luego la historia (previous), y solo
después entrar al contenedor."*

## 4. Qué exigir en el árbol de decisión

Un camino claro por síntoma:

| Síntoma | Pregunta 1 | Pregunta 2 | Acción |
|---|---|---|---|
| `Pending` | ¿eventos de scheduling? | ¿peticiones vs capacidad? | ajustar resources / más nodos |
| `ImagePullBackOff` | ¿tag correcto? | ¿registry accesible? | corregir imagen |
| `CrashLoopBackOff` | ¿`--previous`? | ¿exit code? | arreglar comando/config |
| `OOMKilled` | ¿limit? | ¿pico real? | subir limit o optimizar |
| Service sin endpoints | ¿selector? | ¿pod Ready? | corregir labels |

## 5. Errores esperados en el aula

| Error | Qué decir |
|---|---|
| "No veo eventos" | `--sort-by=.lastTimestamp` y mira el namespace |
| `--previous` devuelve vacío | El pod no ha reiniciado todavía (espera 30 s) |
| Se van directo a `exec` | Detenles: "el contenedor no arranca, no hay qué ejecutar" |

## 6. Comprobación de aprendizaje

Reto relámpago: en parejas, un pod roto distinto (del lab12) y diagnóstico en <3 min
con el flujo completo.

## 7. Entregable / checklist

- [ ] `guia-diagnostico.md` con ≥5 síntomas y su camino.
- [ ] `evidence.txt` con describe + `logs --previous` del pod roto.
- [ ] Namespace `lab11` borrado al cierre.

## 8. Uso de `solution/`

`solution/guia-diagnostico.md` es referencia. Liberar al cerrar el bloque (mejor como
plantilla final que los alumnos enriquecen con sus casos).
