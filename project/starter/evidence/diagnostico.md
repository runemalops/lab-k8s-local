# Diagnóstico de un despliegue fallido (plantilla)

**Fecha:** ____________  **Equipo:** ____________

## Qué provocé

```bash
# comando exacto que usaste para romperlo
```

## Qué esperaba vs qué pasó

| | |
|---|---|
| Esperaba | |
| Pasó | |

## Diagnóstico (flujo get → describe → events → logs)

```bash
kubectl get pods -n mi-app
kubectl describe pod -n mi-app -l app=web | tail -15
kubectl logs -n mi-app -l app=web --previous --tail=20
```

Salida relevante:

```
pega aquí la salida
```

## Causa raíz

>

## Fix

```bash
# comando de la solución
```

## Evidencia de que quedó sano

```bash
kubectl get pods -n mi-app
```
