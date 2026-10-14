# Guía de configuración inicial

**Curso:** K8S-LOCAL-DEPLOY-01 · **Momento:** después de instalar, **antes del Día 1** (~20 min)
**Objetivo:** dejar el equipo "listo para clase": PATH, alias, Git, editor, hosts, primer clúster y limpieza.

---

## 1. Ruta de trabajo y PATH

```bash
# Linux / macOS / WSL2
mkdir -p ~/cursos && cd ~/cursos
# Clona (o copia) el repo del curso aquí
git clone <url-del-repo-del-curso> curso-k8s-local
cd curso-k8s-local

# Binarios instalados a mano en ~/.local/bin (solo si usaste BIN_DIR)
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc   # o ~/.zshrc
```

Comprueba que todo responde desde una terminal nueva:

```bash
command -v docker kind kubectl helm git
```

## 2. Alias y atajos recomendados

Añade a `~/.bashrc` o `~/.zshrc`:

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kga='kubectl get all'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias kctx='kubectl config use-context'
source ~/.bashrc   # o source ~/.zshrc
```

Completado de comandos (opcional pero recomendado):

```bash
# kubectl
kubectl completion bash | tee ~/.kubectl-completion.bash >/dev/null
echo 'source ~/.kubectl-completion.bash' >> ~/.bashrc
# helm
helm completion bash | tee ~/.helm-completion.bash >/dev/null
echo 'source ~/.helm-completion.bash' >> ~/.bashrc
```

## 3. Git

```bash
git config --global user.name  "Tu Nombre"
git config --global user.email "tu@email.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
```

Crea tu cuenta en el servicio de Git del aula (GitHub/GitLab) y añade la llave SSH:

```bash
ssh-keygen -t ed25519 -C "tu@email.com"
cat ~/.ssh/id_ed25519.pub     # pégalo en GitHub → Settings → SSH keys
ssh -T git@github.com         # prueba
```

## 4. Editor

```bash
# VS Code (recomendado)
code --version || echo "Instala VS Code: https://code.visualstudio.com"

# Atajo útil dentro de WSL/Linux: abrir el repo en VS Code con soporte remoto
code .
```

Extensiones sugeridas: *YAML*, *Kubernetes*, *Docker*, *GitLens*.

## 5. Primer clúster del curso

```bash
kind create cluster --name curso-k8s
kubectl cluster-info --context kind-curso-k8s
kubectl get nodes -o wide
```

Comprueba el contexto (error más frecuente del curso):

```bash
kubectl config get-contexts
kubectl config use-context kind-curso-k8s
```

Smoke test de 30 segundos:

```bash
kubectl create deployment check --image=nginx:1.27 --replicas=2
kubectl expose deployment check --port=80 --type=ClusterIP
kubectl run tmp --rm -it --image=busybox:1.36 -- wget -qO- check
kubectl delete deployment check service check
```

**Al terminar cada día borra el clúster** (simula infraestructura efímera):

```bash
kind delete cluster --name curso-k8s
```

## 6. Entrada local para Ingress (Día 2)

```bash
# Linux / WSL2 / macOS (con sudo)
echo "127.0.0.1 app.local" | sudo tee -a /etc/hosts
getent hosts app.local || ping -c1 app.local
```

Windows: edita `C:\Windows\System32\drivers\etc\hosts` como Administrador y añade
`127.0.0.1 app.local`.

## 7. Recursos y buen uso del equipo

| Ajuste | Recomendación |
|---|---|
| RAM | ≥ 4 GB libres antes de `kind create` |
| Docker Desktop / colima | 4 CPUs y 6 GB de memoria para la VM |
| Imágenes | No hace falta pre-descargar; si el wifi es malo, el instructor compartirá un `docker save/load` |
| Cierre de día | `kind delete cluster --name curso-k8s` + `docker system prune -f` |

## 8. Checklist final antes del Día 1

- [ ] `bash setup/verificacion.sh` → todo `[OK]`
- [ ] `kind create` + `kubectl get nodes` + `kind delete` funcionan
- [ ] Contexto `kind-curso-k8s` seleccionado
- [ ] Repo del curso clonado y `git status` limpio
- [ ] Git con nombre/email y acceso al repo del aula
- [ ] `app.local` en `/etc/hosts`
- [ ] Alias `k`, `kgp`, `kd`, `kl` funcionando
- [ ] Clúster borrado (RAM libre)

Si algún punto falla → [troubleshooting-setup.md](troubleshooting-setup.md)
