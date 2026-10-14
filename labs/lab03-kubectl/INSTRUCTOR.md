# Guía del instructor · Lab 03 (M04)

**Duración:** 50 min de lab (teoría 35 min antes) · **Carpeta:** `labs/lab03-kubectl/`

---

## 1. Antes de clase

- [ ] Clúster `curso-k8s` activo, sin pods basura en `default`.
- [ ] Cheatsheet de `solution/cheatsheet.md` impresa (solo para el instructor).

## 2. Timeline sugerida

| Min | Instructor | Alumno |
|---|---|---|
| 0–15 | Patrón `kubectl <verbo> <tipo> <nombre>` + verbos de lectura | Notas |
| 15–25 | Demo: `get -o yaml` → editar → `apply` | Observa |
| 25–45 | Rota de mesas | Pasos 1–6 del README |
| 45–50 | Puesta en común de cheatsheets | Comparan |

## 3. Demo clave

```bash
kubectl run demo --image=nginx:1.27
kubectl get pod demo -o yaml | less      # "esto es solo YAML"
kubectl describe pod demo | tail -5      # eventos: la parte más útil
kubectl delete pod demo
```

Mensaje: **`describe` te dice *qué pasó*; `logs` te dice *qué piensa la app*.**

## 4. Qué exigir en la cheatsheet

Que sea **accesible en 5 segundos** ante un error típico. Mínimo:

| Situación | Comando esperado |
|---|---|
| Ver pods de un namespace | `kubectl get pods -n <ns> -o wide` |
| Entender por qué un pod no arranca | `kubectl describe pod <p> -n <ns>` |
| Ver la app dentro | `kubectl logs <p> -n <ns>` / `exec -it -- sh` |
| Aplicar cambios | `kubectl apply -f <file>` |
| Filtrar | `kubectl get pods -l app=<x>` |
| Saber qué existe | `kubectl api-resources \| grep <palabra>` |

## 5. Errores esperados en el aula

| Error | Respuesta |
|---|---|
| `No resources found in default namespace` | "Lee el mensaje: estás en `default`" |
| `-n` olvidado de forma sistemática | Recuerda la regla 2: un namespace por ejercicio |
| Confunden tipo con nombre | `kubectl explain pod.spec.containers` para ver la estructura |
| `exec` sin `-it` / con `--` mal colocado | Forma canónica: `kubectl exec <p> -- <cmd>` |

## 6. Comprobación de aprendizaje

Reto de 60 s: "sin buscar en internet, muéstrame (a) los eventos de un pod, (b) sus
variables de entorno, (c) qué réplicas tiene el deployment `smoke`". Verifica en pantalla.

## 7. Entregable / checklist

- [ ] `cheatsheet.md` con **10 comandos** y una línea de propósito por cada uno.
- [ ] Ningún pod suelto: `kubectl get pods` → `No resources found` (o pods propios borrados).
- [ ] El alumno sabe decir en qué contexto está: `kubectl config current-context`.

## 8. Sobre `solution/`

- `solution/cheatsheet.md` es **una** respuesta válida; admite variantes.
- Liberar solo si el aula está estancada (>10 min) o al cerrar el bloque.

## 9. Cierre

Recuerda al grupo: los comandos de hoy son los mismos contra EKS/GKE. Solo cambia el
contexto.
