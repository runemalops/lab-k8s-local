# Mi proyecto final — K8S-LOCAL-DEPLOY-01

**Equipo:** ____________  **Fecha:** ____________

> Reemplaza este texto. Este README es el **requisito 7** de la rúbrica: otra persona
> debe poder reproducir tu despliegue siguiéndolo, sin preguntarte nada.

## 1. Qué desplegamos

| Servicio | Imagen | Puerto | Qué hace |
|---|---|---|---|
| web | | | |
| api | | | |

## 2. Arquitectura

```
aquí va un diagrama o una descripción:
Ingress (host: ______) → web / api → ConfigMap + Secret
```

## 3. Requisitos previos

- [ ] Tooling instalado (`bash setup/verificacion.sh` en verde)
- [ ] Clúster local: `kind create cluster --name curso-k8s`
- [ ] (opcional) entrada en `/etc/hosts`: `127.0.0.1 <tu-host>`

## 4. Despliegue paso a paso

```bash
# 1) validar
kubectl kustomize deploy/overlays/dev > /tmp/render.yaml   # o helm template ...

# 2) desplegar
kubectl apply -f /tmp/render.yaml                           # o helm upgrade --install ...

# 3) comprobar
kubectl get all -n mi-app
kubectl rollout status deployment/web -n mi-app
```

## 5. Cómo probarlo

```bash
curl -H "Host: <tu-host>" http://localhost/api
```

## 6. Rollout y rollback (evidencia)

```bash
# rollout
# rollback
```

Ver `evidence/rollout.txt`.

## 7. Pipeline CI/CD

- Archivo: `.github/workflows/ci.yaml`
- Qué valida: ______________
- Evidencia: ______________ (captura verde + roja)

## 8. Diagnóstico de un despliegue fallido

Ver `evidence/diagnostico.md`.

## 9. Checklist de limpieza

```bash
kubectl delete ns mi-app --ignore-not-found
helm list -A                    # si usaste helm
kind delete cluster --name curso-k8s
docker ps -a
```

- [ ] Namespaces borrados
- [ ] Releases de Helm borrados
- [ ] Clúster destruido
- [ ] `docker ps -a` sin restos
