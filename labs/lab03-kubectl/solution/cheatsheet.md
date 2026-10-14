# Mi cheat-sheet de kubectl — respuesta de referencia

**Criterio:** 10 comandos útiles + propósito claro. Variantes válidas.

| # | Situación | Comando |
|---|---|---|
| 1 | Ver pods de un namespace | `kubectl get pods -n <ns>` |
| 2 | Ver pods con IPs y nodo | `kubectl get pods -n <ns> -o wide` |
| 3 | Saber por qué un pod no arranca | `kubectl describe pod <nombre> -n <ns>` |
| 4 | Ver los logs | `kubectl logs <nombre> -n <ns>` (`--previous` si reinició) |
| 5 | Entrar al contenedor | `kubectl exec -it <nombre> -n <ns> -- sh` |
| 6 | Variables de entorno | `kubectl exec <nombre> -n <ns> -- env` |
| 7 | Aplicar manifiestos | `kubectl apply -f <archivo>` (valida antes con `--dry-run=client`) |
| 8 | Borrar recursos | `kubectl delete -f <archivo>` / `kubectl delete pod <nombre> -n <ns>` |
| 9 | Filtrar por etiqueta | `kubectl get pods -l app=<valor> -n <ns>` |
| 10 | Descubrir recursos | `kubectl api-resources \| grep -i <palabra>` |

**Bonus:**

```bash
kubectl get pod <n> -o yaml            # YAML vivo del recurso
kubectl get events -n <ns> --sort-by=.lastTimestamp
kubectl get pod <n> -o jsonpath='{.metadata.annotations}'
kubectl explain pod.spec.containers.resources
kubectl get all -A
```

**Reglas:**

1. `kubectl <verbo> <tipo> <nombre> [-n <namespace>]`
2. Olvidar `-n` = buscar en `default`.
3. `describe` = eventos de K8s · `logs` = salida de la app.
