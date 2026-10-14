# Diagnóstico de despliegues (ESQUELETO)
**Pareja:** ____________  **Fecha:** ____________

> Por cada caso: síntoma → causa raíz → comando que lo demuestra → fix.

## Caso 1 · `broken/01-imagepull.yaml`

| Campo | Respuesta |
|---|---|
| Síntoma (`kubectl get pods`) | |
| Causa raíz | |
| Comando que lo demuestra | |
| Fix aplicado | |

## Caso 2 · `broken/02-selector.yaml`

| Campo | Respuesta |
|---|---|
| Síntoma | |
| Causa raíz | |
| Comando que lo demuestra | |
| Fix aplicado | |

## Caso 3 · `broken/03-pending.yaml`

| Campo | Respuesta |
|---|---|
| Síntoma | |
| Causa raíz | |
| Comando que lo demuestra | |
| Fix aplicado | |

## Caso 4 · `broken/04-oom.yaml`

| Campo | Respuesta |
|---|---|
| Síntoma | |
| Causa raíz | |
| Comando que lo demuestra | |
| Fix aplicado | |

## Seguridad

1. ¿Por qué `cluster-admin` para todos es un error?
   >
2. ¿Qué NO va en un Secret de Kubernetes y a dónde sí debería ir?
   >
3. ¿Por qué tag fijo e imagen de origen conocido?
   >

## `kubectl auth can-i`

| Pregunta | Respuesta esperada | Tu salida |
|---|---|---|
| `list pods` | yes | |
| `delete pods` | no | |
| `list secrets` | no | |
