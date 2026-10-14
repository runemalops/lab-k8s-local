# Guía del instructor · Lab 10 (M12)

**Duración:** 70 min de lab + 30 min de demo GitOps · **Carpeta:** `labs/lab10-cicd/`
**Mensaje del bloque:** *"lo que no está automatizado, no existe."*
**Riesgo del bloque:** es el más frágil del curso → ten preparado el **fallback offline**.

---

## 1. Antes de clase (crítico)

- [ ] Probar el workflow completo en el repo del instructor (un push real) **T-1**.
- [ ] `bash labs/lab10-cicd/ci.sh` en verde en la máquina demo.
- [ ] Fallback offline listo: `ci.sh` documentado y probado (no depende de GitHub).
- [ ] Cuentas de GitHub del aula creadas y con el workflow ya en `main` (si el wifi es dudoso).
- [ ] Slides de GitOps (Flux/ArgoCD) descargadas para la demo.

## 2. Timeline sugerida

| Min | Instructor | Alumno |
|---|---|---|
| 0–20 | Teoría: fases del pipeline, validación, entornos | Notas |
| 20–35 | Demo: push → Actions verde en vivo | Observa |
| 35–70 | Rota de mesas (completan workflow o usan ci.sh) | Pasos 1–5 |
| 70–100 | Demo GitOps + discusión | Comparan modelos |

## 3. Demo clave

```bash
bash labs/lab10-cicd/ci.sh          # verde en local
# romper a propósito y ver el fallo
sed -i 's/nginx:1.27/nginx:1.27.999/' labs/lab10-cicd/manifests/deployment.yaml
bash labs/lab10-cicd/ci.sh || echo "JOB ROJO (esperado)"
git checkout labs/lab10-cicd/manifests/deployment.yaml
```

Frase: **"el pipeline es tu red de seguridad: falla antes, no después."**

## 4. Puntos clave

1. Fases: `validate` → `build` → `push` → `deploy` → `verify`. (En este lab simplificamos a validate + deploy.)
2. **Nunca** desplegar sin comprobar (`rollout status`).
3. El clúster en CI es **efímero**: se crea y se tira en cada job (kind en el runner).
4. Secretos de CI: kubeconfig/registry como *secrets* del sistema, nunca en el repo.
5. GitOps (Flux/ArgoCD) = el clúster lee Git; push-based = el pipeline escribe en el clúster.

## 5. Fallbacks (preparados, no improvisados)

| Fallo | Fallback |
|---|---|
| GitHub caído / sin cuenta | `bash labs/lab10-cicd/ci.sh` (misma lógica) |
| Actions no disponibles por cuota | Workflow en GitLab CI (misma estructura, ver variante abajo) |
| Sin internet | Pipeline 100 % local con `ci.sh` + evidencia de terminal |
| Runner muy lento | `SKIP_DEPLOY=1 ci.sh` y despliegue manual posterior |

**Variante GitLab (resumen):** `validate` con `image: alpine/k8s` y `deploy` con
`services: [docker:dind]` + kind; misma lógica de jobs.

## 6. Comprobación de aprendizaje

"Tu pipeline despliega siempre. ¿Qué dos cosas faltan para confiar en él?"
Esperado: validación de esquema + comprobación post-deploy (+ revisión humana).

## 7. Entregable / checklist

- [ ] Workflow con `validate` y `deploy` (o `ci.sh` documentado como pipeline).
- [ ] Evidencia verde + **evidencia roja** (validación fallida).
- [ ] 5 líneas sobre mejoras para producción.
- [ ] Namespace `lab10` borrado al cierre.

## 8. Uso de `solution/`

`solution/.github/workflows/ci.yaml` es la referencia. Liberar al cerrar el bloque o
si ≥3 alumnos están bloqueados con lo mismo (regla: demo grupal).

## 9. Conexión con el proyecto

Requisito 6 del proyecto: pipeline que valide (`kubeconform`), despliegue y tenga job
verde. Este lab entrega ese punto de la rúbrica (8 pts).
