# Guía del instructor · Lab 01 (M01)

**Duración:** 25–30 min de lab dentro del bloque de 1 h · **Formato:** teoría 35 min + lab 25 min
**Carpeta:** `labs/lab01-containers/` (esqueleto) · `solution/` (respuesta)

> Regla de aula: **no entregar el Dockerfile resuelto antes de 15 min de esfuerzo.**

---

## 1. Antes de clase

- [ ] `bash setup/verificacion.sh` en verde en la máquina demo.
- [ ] Imágenes base ya presentes: `docker pull nginx:1.27` (ahorra minutos en el wifi del aula).
- [ ] Slides de M01 cargadas; pizarra con "imagen ≠ contenedor ≠ artefacto".

## 2. Timeline sugerido

| Min | Qué hace el instructor | Qué hace el alumno |
|---|---|---|
| 0–5 | Explica capas, tag vs digest, registry | Escucha / toma nota |
| 5–15 | Demo en vivo: `docker build` de ejemplo | Observa |
| 15–25 | Lanza el lab | Rellena los TODO del `Dockerfile` |
| 25–30 | Revisa 2–3 pantallas y cierra dudas | Muestra `docker history` |

## 3. Demo del instructor (30 s, para proyectar)

```bash
cd labs/lab01-containers
sed -i.bak 's|__BASE__|nginx:1.27|' /dev/null 2>/dev/null  # solo referencia visual
docker build -t demo:1.0 . && docker run --rm -p 9090:80 demo:1.0
```

Foco del comentario: cada instrucción del Dockerfile = una capa cacheable.

## 4. Puntos que no se pueden saltar

1. **Tag explícito**: es la semilla de todo el versionado de despliegues (Día 2, M09).
2. **`-p host:contenedor`**: error #1 de puertos en todo el curso.
3. **Capas y caché**: explica por qué el segundo build es instantáneo y por qué
   copiar el código *al final* del Dockerfile mejora la caché.
4. **Imagen ≠ artefacto de deploy**: la imagen es versionada, inmutable y transportable.

## 5. Errores esperados en el aula

| Error visto | Respuesta corta para el alumno |
|---|---|
| `COPY failed` | "¿En qué directorio estás? `pwd`" |
| Puerto ocupado | "Cambia el host: `-p 8081:80`" |
| Pull lento | Usa la imagen ya descargada: `docker pull nginx:1.27` en la máquina demo o USB del instructor |
| `latest` en el YAML | "Recuerda la regla 4 del laboratorio: tag explícito siempre" |

## 6. Comprobación de aprendizaje (1 min, de pie)

Preguntas rápidas:
1. Si borras el contenedor, ¿desaparece la imagen? → No.
2. ¿Qué pasa si dos contenedores mapean el mismo puerto host? → Error de bind.
3. ¿Por qué `:latest` rompe el rollback? → Porque el tag no identifica una versión.

## 7. Entregable y checklist (aplicar a los 5 pts)

- [ ] `Dockerfile` con base `nginx:1.27` (u otra oficial) y `COPY` al path correcto.
- [ ] `index.html` propio (no el de ejemplo).
- [ ] Tags `1.0` y `1.1` visibles en `docker images`.
- [ ] `evidence.txt` con `docker history` (fecha + comando + salida).
- [ ] Contenedor detenido al terminar (`docker ps` sin `curso-web`).

## 8. Respuesta/contenido de `solution/`

`solution/Dockerfile` contiene la versión completa; `solution/index.html` un ejemplo
de contenido. **Abrir solo** cuando:
- al menos el 70 % del aula haya construido su imagen, o
- un alumno lleve >10 min bloqueado con el mismo error.

## 9. Enlace con el resto del curso

- La imagen `curso-web:1.0` se reutiliza en el lab 07 (rollout) si el alumno la carga
  en kind con `kind load docker-image`.
- Si un alumno termina antes: que etiquete una `1.2` y compare `docker diff`.
