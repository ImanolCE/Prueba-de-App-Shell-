FROM node:20-alpine AS builder
WORKDIR /app

# Dependencias
COPY package*.json ./
RUN npm ci

# Código
COPY . .

# Versión BLUE para la PWA
ARG APP_VERSION=blue
ENV VITE_APP_VERSION=${APP_VERSION}

# Build de Vite (salida en /app/dist)
RUN npm run build

# ---- Stage de Nginx ----
FROM nginx:alpine

# Config SPA (fallback a index.html)
COPY docker/blue/default.conf /etc/nginx/conf.d/default.conf

# Copiar build estático
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
