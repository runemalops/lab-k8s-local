# Instalación en Windows (WSL2 + Ubuntu)

**Curso:** K8S-LOCAL-DEPLOY-01 · **SO:** Windows 10 21H2+ / Windows 11 (64 bits)
**Regla de oro:** todo el curso se hace **dentro de WSL2 (Ubuntu)**, nunca en PowerShell.

## Opción A — Instalador automático (recomendada)

1. Abre **PowerShell como Administrador** (clic derecho → "Ejecutar como administrador").
2. Ejecuta:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\setup\install-windows.ps1
```

3. Si Windows pide **reiniciar**, reinicia y repite el paso 2.
4. Abre **Ubuntu** (menú inicio) y dentro ejecuta:

```bash
bash /tmp/curso-k8s-setup/verificacion.sh
# o, si clonaste el repo dentro de WSL:
bash setup/verificacion.sh
```

El script habilita WSL2 + la plataforma de VM, instala Ubuntu, prepara `curl`/`git` y lanza `install-linux.sh` dentro de WSL.

## Opción B — Instalación manual

```powershell
# PowerShell como Administrador
wsl --install -d Ubuntu        # reinicia si lo pide
```

Tras el reinicio, completa la creación de usuario de Ubuntu y luego:

```bash
# Dentro de Ubuntu (WSL2)
sudo apt-get update && sudo apt-get install -y curl git ca-certificates
bash setup/install-linux.sh
bash setup/verificacion.sh
```

## Requisitos de Windows

| Requisito | Cómo comprobarlo |
|---|---|
| Virtualización activada en BIOS (VT-x / AMD-V) | `msinfo32` → "Virtualización habilitada" |
| WSL2 instalado | `wsl --status` en PowerShell |
| ≥ 8 GB RAM (16 recomendados) | `msinfo32` |
| ≥ 10 GB libres en C: | Explorador de archivos |
| Windows actualizado | actualizaciones opcionales |

## Errores típicos en Windows

| Síntoma | Causa / Fix |
|---|---|
| `wsl: se produjo una error` al instalar | Falta "Plataforma de máquina virtual" → `wsl --install` de nuevo o activa la feature en "Activar características de Windows" |
| Los comandos no funcionan | Estás en **PowerShell**: abre **Ubuntu** |
| `docker: Cannot connect...` | Docker Desktop no está corriendo o no está configurado con backend WSL2 |
| `kind create` falla / mucho consumo | Cierra WSL: `wsl --shutdown`, vuelve a abrir Ubuntu |
| El repo está en `C:\` y "no lo ve" Linux | Clónalo en el filesystem de Linux: `git clone <repo> ~/curso-k8s-local` |
| Acceso al navegador a `localhost:8080` desde Windows | Funciona con WSL2 (puerto forwarding automático); si no, usa `curl` dentro de WSL |

## Alternativa sin WSL2 (modo compatible)

Si tu equipo/empresa no permite WSL2: instala **Docker Desktop for Windows con backend WSL2** o usa **Rancher Desktop**; si tampoco es posible, avisa al instructor en **T-5** para asignarte pareja o el modo `minikube` con `--driver=docker`.

## Verificación final

```bash
bash setup/verificacion.sh
```

Siguiente paso → [configuracion-inicial.md](configuracion-inicial.md)
