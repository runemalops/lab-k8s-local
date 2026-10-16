# Guía del instructor · Lab 05 (M07)

**Duración:** 30 min de lab (Día 2; teoría M06+M07 25 min antes) · **Carpeta:** `labs/lab05-config/`
**Mensaje del bloque:** *"la imagen es inmutable; la configuración no."*

---

## 1. Antes de clase

- [ ] Clúster activo; namespace `lab05` inexistente.
- [ ] Tener a mano `echo <base64> | base64 -d` como demo de "el Secret no está cifrado".
- [ ] Slides: tabla "¿qué va en ConfigMap, qué va en Secret, qué NO va en ninguno".

## 2. Timeline sugerida

| Min | Instructor | Alumno |
|---|---|---|
| 0–20 | Teoría: ConfigMap vs Secret, `env` vs volumen, `stringData` | Notas |
| 20–30 | Demo: desplegar + cambiar ConfigMap + restart | Observa |
| 30–45 | Rota de mesas | Pasos 1–6 |
| 45–60* | *si el bloque alarga* | puesta en común del paso 5 |

## 3. Demo clave (la de la propagación)

```bash
kubectl create configmap demo --from-literal=SALUDO=hola -n lab05
# aplicar el lab completo y luego:
kubectl set env deployment/curso-web -n lab05 --from=configmap/demo SALUDO
# vs editar el YAML y apply → drift
```

Frase de cierre: **los cambios de configuración también son deployments: versiona,
aplica y reinicia de forma controlada.**

## 4. Puntos que hay que destacar

1. **`stringData` vs `data`:** `stringData` acepta texto plano y K8s lo convierte.
2. **base64 ≠ cifrado** (demo con `base64 -d`).
3. **Archivos vs env:** el volumen se actualiza solo (~60 s); la env **no** → `rollout restart`.
4. **Qué NO va en un Secret de K8s:** claves de producción reales, tokens de cloud,
   datos con requisitos de cumplimiento → en producción va a un secret manager externo.
5. Nada de credenciales en la imagen (ese es el error que evitamos).

## 5. Errores esperados en el aula

| Error | Fix guiado |
|---|---|
| Env no cambia tras apply | "¿Cuántos pods tiene tu deployment? Reinicia: `rollout restart`" |
| `keys in data must consist of alphanumeric...` | clave inválida (`DB_PASSWORD`, no `db-password`) |
| YAML roto | `kubectl apply --dry-run=client -f <file>` antes de aplicar |
| El alumno monta el Secret y se olvida de `volumes` | Repasa estructura: `spec.template.spec.volumes` + `volumeMounts` |
| Confunde `secretRef` con `secretKeyRef` | Uno apunta a todo el Secret (con `envFrom`), otro a una clave concreta |

## 6. Comprobación de aprendizaje

"Tu compañero desplegó la app con la config dentro de la imagen. ¿Qué le dices?"
Esperado: externalizar a ConfigMap/Secret, versionar en Git, aplicar con rollout.

## 7. Entregable / checklist

- [ ] 3 manifiestos completos, sin credenciales hardcodeadas en el Deployment.
- [ ] `evidence.txt` con env antes/después del `rollout restart`.
- [ ] Demo de `base64 -d` sobre el Secret.
- [ ] Namespace `lab05` borrado al terminar.

## 8. Uso de `solution/`

Liberar cuando un alumno lleve >10 min con la inyección o al quedar <5 min.
Espejar en pantalla `deployment.yaml` ↔ `solution/deployment.yaml` (líneas de `envFrom`
y `volumeMounts`).

## 9. Conexión con el proyecto final

El requisito 3 del proyecto exige "ConfigMap + Secret sin valores hardcodeados":
este lab es exactamente ese punto (criterio "Config/secretos y exposición", 8 pts).
