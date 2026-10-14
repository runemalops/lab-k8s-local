# Guía del instructor · Lab 12 (M14)

**Duración:** 40 min de lab (40 min de teoría antes) · **Carpeta:** `labs/lab12-debug/`
**Mensaje del bloque:** *"el 90 % del debugging es leer bien el describe."*

---

## 1. Antes de clase

- [ ] Clúster activo; ns `lab12` inexistente.
- [ ] Los 4 manifiestos rotos **verificados** en la máquina demo (que fallen como se espera).
- [ ] Ejercicio en parejas: parejas mixtas (terminal fuerte + débil, según pre-test).
- [ ] `solution/` lista (arreglos + RBAC).

## 2. Timeline sugerida

| Min | Instructor | Alumno |
|---|---|---|
| 0–15 | Teoría: matriz de fallos + seguridad (RBAC, SecurityContext, secretos) | Notas |
| 15–45 | Diagnóstico en parejas (4 casos) | Pasos 1–3 |
| 45–55 | RBAC y `auth can-i` | Pasos 4–5 |
| 55–60 | Puesta en común: tabla fallo → causa → fix | Comparan |

## 3. Los 4 casos (respuesta esperada)

| Caso | Síntoma | Causa | Fix |
|---|---|---|---|
| `01-imagepull.yaml` | `ImagePullBackOff` | tag inexistente (`nginx:1.27.999`) | tag válido (`nginx:1.27`) |
| `02-selector.yaml` | Service sin endpoints | selector ≠ labels del pod | alinear selector/labels |
| `03-pending.yaml` | Pod `Pending` | `cpu` request superior a la capacidad del nodo | bajar el request |
| `04-oom.yaml` | `OOMKilled` | limit de memoria demasiado bajo | subir limit / ajustar consumo |

## 4. Cómo dirigir la sesión

1. **Prohibido mirar la solución los primeros 15 min.**
2. Cuando una pareja lo resuelva, que explique en 60 s a la fila.
3. Insiste en el **comando que demuestra** la causa (no solo "lo arreglé").
4. Documentar en la "Pizarra de errores" los 2 fallos más repetidos del día.

## 5. Demo clave (RBAC)

```bash
kubectl auth can-i delete pods -n lab12 --as=system:serviceaccount:lab12:curso-viewer   # no
kubectl auth can-i list pods   -n lab12 --as=system:serviceaccount:lab12:curso-viewer   # yes
```

Frase: **"permiso mínimo, verificado"** (no basta con escribir el Role: hay que probarlo).

## 6. Comprobación de aprendizaje

Sin pista: "un pod en `CrashLoopBackOff` con exit code 137, ¿qué miras primero?"
Esperado: `describe` → `Last State: Reason: OOMKilled` → revisar limits.

## 7. Entregable / checklist

- [ ] `diagnostico.md` con los 4 casos (causa + evidencia + fix).
- [ ] `rbac.yaml` aplicado y las 3 respuestas de `auth can-i` correctas.
- [ ] `kubectl get pods -n lab12` sin pods rotos al final.
- [ ] Namespace `lab12` borrado y clúster destruido (cierre del curso).

## 8. Uso de `solution/`

Liberar cuando ≥70 % del aula haya arreglado 2 de 4 casos, o al quedar <5 min.
La solución incluye `fixed/` con los 4 manifiestos corregidos y `rbac.yaml` completo.

## 9. Cierre del curso

Recordar el checklist final: namespaces → releases de Helm → `kind delete cluster` →
`docker ps -a` limpio → kubeconfig sin restos. Conectar con continuidad (CKA/CKAD,
GitOps, nube) según `04_estructura_estudiante.md` §8.
