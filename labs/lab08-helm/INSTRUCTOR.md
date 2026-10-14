# Guía del instructor · Lab 08 (M10)

**Duración:** 60 min (manejo básico) + 50 min (plantillas y entornos) · **Carpeta:** `labs/lab08-helm/`
**Mensaje del bloque:** *"empaquetar es decidir qué es configurable y qué no."*

---

## 1. Antes de clase

- [ ] `helm version --short` → v3.16.x.
- [ ] Namespace `lab08` inexistente y `lab06` borrado (choque de host en Ingress).
- [ ] Repo de charts accesible: `helm repo list` / demo de `helm search repo nginx`.
- [ ] `solution/curso-web/` lista en una pestaña aparte.

## 2. Timeline sugerida

| Min | Instructor | Alumno |
|---|---|---|
| 0–20 | Teoría: chart/values/release/repository, SemVer | Notas |
| 20–30 | Demo: `helm create`, podar, `install` | Observa |
| 30–60 | Rota de mesas (paso 2 del README) | Completan el esqueleto |
| 60–70 | Plantillas: `range`, condicionales, `--set` | Observa |
| 70–110 | Lab de entornos y rollback | Pasos 3–6 |
| 110–120 | Debate: ¿cuándo SÍ usar Helm? | Discusión |

## 3. Demo clave

```bash
helm template web ./chart -f ./chart/values-dev.yaml | grep -E "replicas|image:"
helm upgrade --install web ./chart -n lab08 -f ./chart/values-staging.yaml
helm rollback web 1 -n lab08
```

Frase: **`helm template` es tu red de seguridad: renderiza sin tocar el clúster.**

## 4. Puntos clave a exigir

1. `helm lint` + `helm template` **antes** de `install`.
2. `--set web.replicaCount=5` vs `-f values-x.yaml` (y que `--set` no persiste en Git).
3. `helm history` / `helm rollback` como habilidad (no como curiosidad).
4. Release names únicos por namespace; `helm list -A` como rutina.
5. **Helm ≠ siempre:** si el despliegue es solo YAML con 2 entornos, Kustomize es más simple.

## 5. Errores esperados en el aula

| Error | Fix guiado |
|---|---|
| `parse error` / `YAML parse error` | `helm template` y mira el render |
| `host ... already defined` | falta borrar `lab06` u otro host en values |
| Release stuck en `pending-install` | `helm uninstall` y reinstalar |
| Templates con sangrado incorrecto | `{{- include ... | nindent 4 }}` (espacio antes de `{{`) |
| Valores que no se aplican | `helm get values web -n lab08` para ver qué está activo |

## 6. Comprobación de aprendizaje

Reto: "cambia el host del Ingress **solo** en staging sin tocar `values.yaml`".
Respuesta esperada: editar `values-staging.yaml` y `helm upgrade`.

## 7. Entregable / checklist

- [ ] `helm lint chart/` sin errores.
- [ ] Chart con **4 manifiestos** (web/api deployment+service) + Ingress condicional.
- [ ] `values-dev.yaml` y `values-staging.yaml` con diferencias reales.
- [ ] `evidence.txt`: `helm history` con ≥2 revisiones + salida de `helm template`.
- [ ] `helm uninstall` y ns borrado al cierre.

## 8. Uso de `solution/`

- `solution/curso-web/` es el chart completo de referencia.
- Liberar si un alumno lleva >15 min con el render, o al cerrar el primer bloque.

## 9. Conexión con el proyecto

Requisito 2 del proyecto: "empaquetado con Helm o Kustomize parametrizable en dev y
staging". Este lab entrega ese 60 % del requisito; Kustomize (lab 09) es la alternativa.
