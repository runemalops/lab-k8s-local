# Guía del instructor · Lab 02 (M03)

**Duración:** 15 min de lab (Día 1; teoría kind/kubectl 10 min antes) · **Carpeta:** `labs/lab02-kind/`

---

## 1. Antes de clase

- [ ] Clúster `curso-k8s` **borrado** en la máquina demo (para crearlo en vivo con cronómetro).
- [ ] `kind get clusters` vacío y `kubectl config get-contexts` limpio.
- [ ] Verificar que `kind-config.yaml` del lab crea el clúster en <2 min en la máquina demo.

## 2. Timeline sugerido

| Min | Instructor | Alumno |
|---|---|---|
| 0–10 | Teoría: kind, nodos como contenedores, kubeconfig/contextos | Notas |
| 10–15 | Demo: crear clúster con cronómetro visible | Observa |
| 15–35 | Rota entre mesas | Ejecuta pasos 1–5 del README |

## 3. Demo clave (la que no se salta)

```bash
kind create cluster --name curso-k8s --config kind-config.yaml
docker ps --filter name=curso-k8s     # los nodos SON contenedores
kubectl get nodes -o wide             # la misma realidad, vista kubectl
kubectl config view --minify          # qué mira kubectl cuando "elige clúster"
```

> Mensaje del día: **`kubectl` no "sabe" nada: lee un kubeconfig y habla con la API
> server del clúster que le indique el contexto activo.**

## 4. Variante de conmutación (paso 3) — por qué importa

Es el ejercicio que previene el error nº 1 del curso ("kubectl apunta a otro clúster").
Asegúrate de que **todos** los alumnos vean la salida cambiar de `kind-practica` a
`kind-curso-k8s` antes de continuar.

## 5. Errores esperados en el aula

| Error | Fix guiado |
|---|---|
| `Cannot connect to the Docker daemon` | Arrancar runtime; en WSL2: `wsl --shutdown` y reabrir Ubuntu |
| Clúster `NotReady` eterno | Poca RAM → `kind delete cluster --all` y reintentar con el config mínimo |
| Contexto `kind-practica` activo tras borrar ese clúster | `kubectl config use-context kind-curso-k8s` |
| Clústeres duplicados por nombres distintos | Regla 1: **solo** `curso-k8s` |
| `permission denied` en Docker | `sudo usermod -aG docker $USER` + logout/login |

## 6. Comprobación de aprendizaje (3 preguntas)

1. ¿Qué borras con `kind delete cluster`? → El clúster completo (nodos, estados); las
   imágenes de Docker **no** se borran.
2. ¿Se pierde algo si borro el clúster? → Sí: todo lo desplegado. Por eso todo vive en Git.
3. ¿Por qué el día se cierra con delete? → Practica infraestructura efímera y libera 2–4 GB.

## 7. Entregable / checklist

- [ ] `kubectl get nodes -o wide` con los dos nodos (o 1 + worker) del clúster `curso-k8s`.
- [ ] Dos contextos visibles en `kubectl config get-contexts`.
- [ ] Ciclo delete → create cronometrado en `evidence.txt` (<2 min).
- [ ] Respuesta a la pregunta sobre `docker ps` vs `kubectl get nodes`.
- [ ] Sin clústeres extra al final del ejercicio (`kind get clusters`).

## 8. Sobre `kind-config.yaml`

- `solution/kind-config.yaml` añade `extraPortMappings` 80/443 → `localhost` y un worker.
- Úsalo como **opción avanzada**: si el aula es lenta, crea el clúster con
  `kind create cluster --name curso-k8s` (1 nodo, mínimo consumo).
- En el lab 06 (Ingress) se soportan **ambos** caminos: port-forward (siempre funciona)
  o `localhost:80` (si usaste este config).

## 9. Cierre

Antes del bloque siguiente: pide a todos `kind get clusters` → debe aparecer **solo**
`curso-k8s`.
