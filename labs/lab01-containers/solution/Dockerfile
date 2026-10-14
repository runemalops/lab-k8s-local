FROM nginx:1.27

LABEL org.opencontainers.image.title="curso-web" \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.authors="Instructor K8S-LOCAL-DEPLOY-01 <curso@example.com>"

# nginx sirve desde /usr/share/nginx/html en la imagen oficial
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
