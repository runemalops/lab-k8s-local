# Guía del instructor · Lab 09 (M11)

**Duración:** 45 min · **Modalidad: ASÍNCRONO** (ampliación opcional; en aula solo la comparación Helm vs Kustomize en el cierre del Día 3) · **Carpeta:** `labs/lab09-kustomize/`
**Mensaje del bloque:** *"base + overlays: configurar sin duplicar."*

---

## 1. Antes de clase

- [ ] Clúster activo; namespaces `lab09-dev`/`lab09-staging` inexistentes.
- [ ] `kubectl kustomize base` funciona en la máquina demo.
- [ ] Tener a mano `kubectl kustomize overlays/dev | diff - overlays/staging` para la demo.

## 2. Timeline sugerida

| Min | Instructor | Alumno |
|---|---|---|
| 0–15 | Teoría: base/overlays, patches, images, cuándo Helm vs Kustomize | Notas |
| 15–25 | Demo: `kustomize build` de dev y staging lado a lado | Observa |
| 25–40 | Rota de mesas | Pasos 1–5 |
| 40–45 | Puesta en común (tabla Helm vs Kustomize) | Comparten |

## 3. Demo clave

```bash
kubectl kustomize overlays/dev     | grep -E "namespace:|replicas:|image:"
kubectl kustomize overlays/staging | grep -E "namespace:|replicas:|image:"
kubectl apply -k overlays/dev && kubectl apply -k overlays/staging
```

Idea central: **el mismo código, dos realidades**, y la base intacta.

## 4. Puntos clave

1. `kustomize build` no guarda estado: lo que ves aplicado es lo que se generó **ahora**.
2. El `namespace:` del kustomization **no crea** el namespace → hay que llevar `namespace.yaml`.
3. `patches` identifica recursos por GVK + name; un typo silencia el patch.
4. `images:` reescribe tags sin tocar el YAML base.
5. Diferencia con Helm: Kustomize **no tiene estado de release** (no hay `rollback` natico).

## 5. Errores esperados en el aula

| Error | Qué decir |
|---|---|
| `namespaces "..." not found` | "El namespace también es despliegue: créalo" |
| Patch sin efecto | `kubectl kustomize base \| grep name` para copiar el nombre exacto |
| Confusión base vs overlay | `git diff` como brújula |
| `commonLabels` deprecado | Mostrar `labels:` (versión 5) y citar el nombre antiguo |

## 6. Comprobación de aprendizaje

"Sin tocar `base/`, consigue que staging use 5 réplicas y el tag `1.27.1`".
Verificar con `kubectl kustomize overlays/staging | grep replicas`.

## 7. Entregable / checklist

- [ ] `kubectl kustomize` de ambos overlays sin errores.
- [ ] Pods Running en `lab09-dev` (1 réplica) y `lab09-staging` (3 réplicas).
- [ ] Imágenes distintas entre entornos (verificable con `-o jsonpath`).
- [ ] `git status` limpio respecto a `base/` al terminar.
- [ ] Namespaces borrados al cierre.

## 8. Uso de `solution/`

`solution/overlays/` es la referencia completa (incluye `namespace.yaml`).
Liberar si >10 min de bloqueo o al cerrar el bloque.

## 9. Debate sugerido (3 min)

"¿Helm o Kustomize?" → respuestas esperadas:
- Paquete distribuible / valores en runtime → Helm.
- Multi-entorno en el mismo repo / revisión por PR → Kustomize.
- Muchos: los dos conviven en empresas reales.
