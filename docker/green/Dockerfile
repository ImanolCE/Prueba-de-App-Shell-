FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# Versión GREEN para la PWA
ARG APP_VERSION=green
ENV VITE_APP_VERSION=${APP_VERSION}

RUN npm run build

FROM nginx:alpine
COPY docker/green/default.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
