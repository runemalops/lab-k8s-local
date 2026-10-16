# Guía del instructor · Lab 06 (M08)

**Duración:** 20 min de lab (Día 2; teoría M08 15 min antes; **ingress-nginx ya instalado desde T-1**) · **Carpeta:** `labs/lab06-ingress/`
**Mensaje del bloque:** *"dentro del clúster hay DNS; fuera hace falta una puerta."*

---

## 1. Antes de clase (importante)

- [ ] Clúster creado con `labs/lab02-kind/kind-config.yaml` **o** saber que el fallback es port-forward.
- [ ] Instalar ingress-nginx **antes** del bloque para que la imagen ya esté descargada:
  `bash labs/lab06-ingress/install-ingress.sh`
- [ ] Comprobar en la máquina demo: `curl -H "Host: app.local" http://localhost/` responde.
- [ ] Tener `solution/ingress.yaml` lista (no proyectar).

## 2. Timeline sugerida

| Min | Instructor | Alumno |
|---|---|---|
| 0–15 | Teoría: types de Service, DNS del clúster, Ingress + controller | Notas |
| 15–25 | Demo: instalar controlador y mostrar describe del Ingress | Observa |
| 25–40 | Rota de mesas | Pasos 1–6 |
| 40–45 | Puesta en común (paso 7 del README) | Comparten |

## 3. Demo clave

```bash
kubectl get ingress -n lab06 -o yaml | grep -A5 rules
curl -s -H "Host: app.local" http://localhost/api   # "otro servicio, misma puerta"
```

Ideas a fijar:
1. El Ingress **no escucha nada**: rutea en el controlador (nginx).
2. `path` + `pathType` definen el emparejamiento (`Prefix` vs `Exact`).
3. El DNS `<svc>.<ns>.svc.cluster.local` es lo que hace que "microservicios" sea viable.

## 4. Errores esperados en el aula

| Error | Qué decir |
|---|---|
| `404` con el host correcto | "Mira `kubectl describe ingress`: ¿el path que pruebas está en las reglas?" |
| Controlador en `ContainerCreating` | Descarga de imagen lenta → esperar / usar la imagen precargada |
| `connection refused` en localhost:80 | Clúster sin `extraPortMappings` → **Opción B (port-forward)** |
| Funciona con curl pero no con el navegador | Falta la entrada en `/etc/hosts` (§6 de configuracion-inicial) |
| DNS interno falla | `kubectl run tmp --image=busybox:1.36 -- nslookup kubernetes.default` |

## 5. Errores provocados del paso 7

Úsalos para que **lean el describe**:

- path `/wrong` → `describe ingress` muestra la regla nueva y el curl da 404.
- Borrar el Service `api` → `kubectl describe ingress` avanza a "no service" → volver a aplicar.

## 6. Entregable / checklist

- [ ] Controlador `1/1 Running` en `ingress-nginx`.
- [ ] `apps.yaml` con web + api (2 deployments + 2 services).
- [ ] `ingress.yaml` con host `app.local`, `/` y `/api`.
- [ ] `evidence.txt` con los dos `curl` correctos.
- [ ] Namespace `lab06` borrado al cierre.

## 7. Variantes y fallbacks

| Situación | Variante |
|---|---|
| Puerto 80 ocupado en el equipo | port-forward (Opción B) |
| Clúster mínimo (1 nodo, sin config) | port-forward siempre |
| Sin permisos para editar `/etc/hosts` | `curl -H "Host: app.local"` |
| Aula sin internet para el manifest | manifest copiado en `install-ingress.sh` como fallback local (ver nota del script) |

## 8. Sobre `solution/`

- `solution/apps.yaml` y `solution/ingress.yaml` son la referencia.
- Liberar si >10 min de bloqueo con el mismo error o si el controlador no levanta.

## 9. Cierre

Conectar con M15: en nube, el Ingress apunta a un **LoadBalancer** gestionado; los
manifiestos son prácticamente los mismos.
