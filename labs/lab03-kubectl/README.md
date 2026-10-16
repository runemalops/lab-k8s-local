# Lab 03 · kubectl: la brújula diaria

**Módulo:** M04 · **Día:** 1 · **Duración:** 50 min · **Modalidad: ASÍNCRONO** (opcional; en aula la práctica de kubectl va dentro del lab04)
**Guía:** alumno · **Carpeta:** `labs/lab03-kubectl/`

---

## 🎯 Objetivo

Usar `kubectl` para **observar, inspeccionar y modificar** recursos sin memorizar cien
comandos. Sales de aquí con tu cheat-sheet de 10 comandos.

## 🧰 Prerrequisitos

- Clúster `curso-k8s` corriendo y contexto correcto:
  ```bash
  kubectl config use-context kind-curso-k8s && kubectl get nodes
  ```

## 📋 Pasos

### 1. Crea un pod de práctica

```bash
kubectl run practica --image=nginx:1.27 --labels="app=practica,tipo=demo" -n default
kubectl get pods
kubectl get pod practica -o wide
kubectl get pod practica -o yaml | head -30
```

### 2. Inspéccionalo

```bash
kubectl describe pod practica
kubectl get pod practica --show-labels
kubectl logs practica
kubectl exec practica -- ps aux
kubectl exec practica -- env | sort
```

### 3. Localiza y selecciona

```bash
kubectl get pods --show-labels
kubectl get pods -l tipo=demo
kubectl get pods -l 'app in (practica,otra)'
kubectl api-resources | head -20
kubectl api-resources | grep -i ingress
```

### 4. Modifica y restaura

Copia el YAML actual, edítalo y aplícalo:

```bash
kubectl get pod practica -o yaml > pod-copia.yaml
# edit pod-copia.yaml: añade la anotación  descripcion: "mi primer pod"
kubectl apply -f pod-copia.yaml
kubectl get pod practica -o jsonpath='{.metadata.annotations}' ; echo
```

> **Cuándo NO usar `kubectl edit`:** cuando otra persona/Git es la fuente de verdad.
> Si lo editas directamente, el siguiente `kubectl apply` lo sobreescribe (lo veremos en M06).

### 5. Etiquetas y borrado

```bash
kubectl label pod practica entorno=demo --overwrite
kubectl get pods -l entorno=demo
kubectl delete pod practica
kubectl get pods
```

### 6. Práctica relámpago (5 min)

1. Crea un pod `tmp` con `kubectl run tmp --image=busybox:1.36 -- echo hola`.
2. Mira sus logs **antes de que desapareca** si usas `--rm -it`.
3. Descubre cuántos tipos de recursos soporta el clúster: `kubectl api-resources | wc -l`.

## 📦 Entregable

Tu **cheat-sheet personal de 10 comandos kubectl**: copia y completa
`skeleton/cheatsheet.md` → guárdalo como `cheatsheet.md` en esta carpeta.
Debe incluir como mínimo: `get`, `describe`, `logs`, `exec`, `apply`, `delete`,
`explain`, `get -o yaml`, `-l`, `api-resources`.

## ⚠️ Errores comunes

| Error | Causa | Fix |
|---|---|---|
| `No resources found` | Olvidaste `-n` y estás en otro namespace | `kubectl get pods -n <ns>` / revisa `kubectl config view --minify` |
| `Error from server (NotFound)` | Tipo o nombre mal escritos | `kubectl api-resources \| grep <tipo>` |
| `pod not found` tras `--rm` | El pod ya se borró | ejecuta los comandos en orden o quita `--rm` |
| `command terminated with exit code 126` | Comando no ejecutable en la imagen | prueba con `sh` o `env` |
| Contexto equivocado | Otro clúster activo | `kubectl config current-context` |

## 🔗 Siguiente

→ `labs/lab04-first-deploy/` — tu primer deployment declarativo.
