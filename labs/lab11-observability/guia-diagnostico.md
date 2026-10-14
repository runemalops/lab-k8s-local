# Guía de diagnóstico (1 página) — ESQUELETO

**Flujo base:** `get` → `describe` → `events` → `logs` → `exec`.

## Árbol de decisión

```
kubectl get pods -n <ns>
│
├─ STATUS: Pending
│   └─ describe → Events
│       ├─ "Insufficient cpu/memory" → ________________________________
│       └─ "no nodes available"      → ________________________________
│
├─ STATUS: ImagePullBackOff
│   └─ describe → Events
│       ├─ tag inexistente           → ________________________________
│       └─ registry inaccesible      → ________________________________
│
├─ STATUS: CrashLoopBackOff
│   ├─ kubectl logs --previous       → ________________________________
│   └─ Exit Code
│       ├─ 1 / 127                   → ________________________________
│       └─ 137                       → ________________________________
│
├─ Running pero reinicia (RESTARTS > 0)
│   └─ ________________________________ → ________________________________
│
└─ Service sin endpoints
    ├─ selector ≠ labels             → ________________________________
    └─ puerto mal mapeado            → ________________________________
```

## Comandos que no puedo olvidar

1. ________________________________
2. ________________________________
3. ________________________________
4. ________________________________
5. ________________________________

## Mis 3 errores del curso y cómo los resolví

| Error | Qué hice | Fix |
|---|---|---|
| | | |
| | | |
| | | |
