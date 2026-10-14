# Mi cheat-sheet de kubectl

**Nombre:** ______________  **Fecha:** ______________

> Escribe el comando y, a la derecha, para qué lo usarías. Mínimo 10.

| # | Situación | Mi comando |
|---|---|---|
| 1 | Ver todos los pods de un namespace | |
| 2 | Ver pods con sus IPs y nodos | |
| 3 | Saber por qué un pod no arranca | |
| 4 | Ver los logs de un pod | |
| 5 | Entrar a un contenedor | |
| 6 | Ver las variables de entorno | |
| 7 | Aplicar un manifiesto | |
| 8 | Borrar un recurso | |
| 9 | Filtrar por etiqueta | |
| 10 | Descubrir tipos de recursos del clúster | |

**Bonus (elige 3):**

- Ver el YAML vivo de un recurso:
- Ver eventos del namespace:
- Ver el historial de cambios (`last-applied-configuration`):
- Explicar un campo sin salir de la terminal:
- Ver cuántos recursos de un tipo hay en todos los namespaces:

**Reglas que me llevo:**

1. Patrón: `kubectl ______ <verbo> <tipo> <nombre> [-n <namespace>]`
2. Olvidar `-n` equivale a buscar en el namespace equivocado.
3. `describe` ≠ `logs`: eventos de Kubernetes vs salida de la app.
