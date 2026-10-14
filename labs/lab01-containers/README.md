# Lab 01 · Contenedores, imágenes y artefactos de deployment

**Módulo:** M01 · **Día:** 1 · **Duración:** 25–30 min (bloque de 1 h con teoría)
**Guía:** alumno · **Carpeta:** `labs/lab01-containers/`

---

## 🎯 Objetivo

Producir una **imagen desplegable**: un contenedor con tu app estática, etiquetada con
una versión explícita y ejecutable en local. Al terminar sabrás qué hay dentro de una
imagen y por qué `build once, deploy anywhere`.

## 🧰 Prerrequisitos

- Tooling instalado y `bash setup/verificacion.sh` en verde.
- Docker corriendo (`docker info` sin errores).
- **No hace falta** clúster todavía (se crea en el lab 02).

## 📋 Pasos

### 1. Prepara la app

Entra al lab y revisa el esqueleto:

```bash
cd labs/lab01-containers
ls -la
```

Tienes `index.html` (nuestra "aplicación") y un `Dockerfile` **incompleto**.

### 2. Completa el Dockerfile

Rellena los TODO de `Dockerfile`:

| TODO | Qué poner | Pista |
|---|---|---|
| `# TODO(1)` | imagen base | una imagen oficial de nginx con tag fijo |
| `# TODO(2)` | dónde copiar el contenido | directorio público por defecto de nginx |
| `# TODO(3)` | metadata | quién mantiene esta imagen |

> **Regla de oro:** nunca uses `latest` como tag en entregables.

### 3. Construye y etiqueta

```bash
docker build -t curso-web:1.0 .
docker images | grep curso-web
```

### 4. Ejecuta

```bash
docker run --rm -d --name curso-web -p 8080:80 curso-web:1.0
curl -s http://localhost:8080 | head -5
docker logs curso-web
```

> Fíjate en el orden del mapeo de puertos: **`-p host:contenedor`**.

### 5. Observa las capas y versiones

```bash
docker history curso-web:1.0
docker inspect -f '{{.Config.Labels}}' curso-web:1.0 2>/dev/null || true
```

Ahora cambia una frase en `index.html`, vuelve a construir con el tag `1.1` y compara:

```bash
docker build -t curso-web:1.1 .
docker history curso-web:1.1
```

### 6. (Bonus) Llévalo a tu clúster

Si ya tienes el clúster `curso-k8s` (lo veremos en el lab 02):

```bash
kind load docker-image curso-web:1.0 --name curso-k8s
docker rmi curso-web:1.1   # practica limpieza
```

### 7. Limpieza

```bash
docker rm -f curso-web 2>/dev/null || true
```

No borres `curso-web:1.0` si la vas a usar en los labs siguientes.

## 📦 Entregable

- `Dockerfile` completo en `labs/lab01-containers/`.
- `index.html` con tu contenido propio.
- Línea en `evidence.txt` con la salida de:
  ```bash
  docker images | grep curso-web ; docker history curso-web:1.0
  ```

## ⚠️ Errores comunes

| Error | Causa | Fix |
|---|---|---|
| `COPY failed: no source files` | Build desde el directorio equivocado | ejecuta `docker build` donde está el `Dockerfile` (usa `.` al final) |
| El navegador no muestra tu HTML | Puerto mal mapeado | `-p 8080:80` = host 8080 → contenedor 80 |
| `manifest unknown` al hacer pull | tag inexistente en el registry | revisa el tag (`nginx:1.27`, no `nginx:1.27.9`) |
| Etiqueta `latest` por defecto | Olvidaste el `-t ...:1.0` | Reconstruye con tag explícito |
| Imagen ocupa mucho | Capas de `apt-get` sin limpiar | Une comandos en un solo `RUN` con `&&` |

## 🔗 Siguiente

→ `labs/lab02-kind/` — crear tu primer clúster local con kind.
