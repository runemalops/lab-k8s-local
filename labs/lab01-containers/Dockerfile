# TODO(1): imagen base oficial de nginx con TAG EXPLÍCITO (nunca :latest)
FROM __BASE_IMAGE__

# Metadatos de la imagen (quién la mantiene)
# TODO(3): sustituye los valores
LABEL org.opencontainers.image.title="curso-web" \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.authors="TU_NOMBRE <tu@email>"

# El contenido de nuestra app va al directorio público por defecto de nginx
# TODO(2): copia index.html al path correcto
COPY index.html __DEST_PATH__

EXPOSE 80
