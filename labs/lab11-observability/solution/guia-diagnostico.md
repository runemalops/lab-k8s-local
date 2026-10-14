# Guía de diagnóstico (1 página) — respuesta de referencia

**Flujo base:** `kubectl get` → `describe` → `events` → `logs` (`--previous`) → `exec`.
Siempre **primero el estado**, luego **el por qué**, luego **la historia**.

---

## Árbol de decisión

```
kubectl get pods -n <ns>
│
├─ STATUS: Pending
│   └─ kubectl describe pod <p> -n <ns>  → Events
│       ├─ "Insufficient cpu/memory"  → baja peticiones o libera recursos
│       ├─ "no nodes available"       → sin capacidad de scheduling
│       └─ volumen/affinity           → revisa volumes, nodos y taints
│
├─ STATUS: ImagePullBackOff / ErrImagePull
│   └─ describe → Events ("Failed to pull image")
│       ├─ tag inexistente / typo     → corrige la imagen (tag explícito)
│       └─ registry inaccesible       → red/proxy/credenciales
│
├─ STATUS: CrashLoopBackOff
│   ├─ kubectl logs <p> --previous    → última salida antes de morir
│   ├─ describe → Last State: Exit Code
│   │   ├─ 1 / 127  → comando o path mal (config/app rota)
│   │   ├─ 137      → OOMKilled o kill externo
│   │   └─ 126/127  → binario no ejecutable
│   └─ fix → vuelve a aplicar el manifiesto bueno (Git)
│
├─ STATUS: Running pero reinicia (RESTARTS > 0)
│   └─ livenessProbe fallando → sube initialDelaySeconds / revisa la app
│
├─ STATUS: Running, pero la app no responde
│   ├─ kubectl logs <p>                → errores de la app
│   ├─ kubectl exec <p> -- env / ls    → configuración y secrets
│   └─ kubectl get endpoints <svc>     → ¿tiene endpoints?
│
└─ Service sin endpoints
    ├─ selector ≠ labels del pod       → kubectl get pods --show-labels
    ├─ pod no Ready (probes)           → describe del pod
    └─ puerto mal mapeado              → targetPort del contenedor
```

## Comandos de bolsillo

```bash
kubectl get pods -n <ns> -o wide
kubectl describe pod <p> -n <ns> | tail -20
kubectl get events -n <ns> --sort-by=.lastTimestamp
kubectl logs <p> -n <ns> --previous --tail=50
kubectl exec -it <p> -n <ns> -- sh
kubectl get endpoints <svc> -n <ns>
kubectl top pods -n <ns>   # si hay metrics-server
```

## Reglas

1. **No adivines:** el `describe` casi siempre dice la causa en `Events`.
2. `logs` sin `--previous` puede estar vacío si el contenedor nunca llegó a arrancar.
3. Si 3 alumnos tienen el mismo error → demo grupal del instructor.
4. Documenta cada error en `notes-errors.md`: *qué hice → qué esperaba → qué pasó → fix*.
