# Multi-Stage Build: Builder & Runtime
FROM node:22-alpine AS builder
WORKDIR /app

# Injeksi metadata dari Jenkins CI / Docker BuildKit
ARG BUILD_NUMBER=1
ARG COMMIT_SHA=local-dev
ARG COMMIT_MESSAGE="Initial frontend deployment"
ARG APP_VERSION=1.0.0

COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci; elif [ -f package.json ]; then npm install; fi

COPY . .

# Generate file healthz.json berisi metadata CI/CD
RUN echo "{\"status\":\"UP\",\"application\":\"frontend-devops-portal\",\"version\":\"${APP_VERSION}\",\"build_number\":\"${BUILD_NUMBER}\",\"commit_sha\":\"${COMMIT_SHA}\",\"commit_message\":\"${COMMIT_MESSAGE}\",\"timestamp\":\"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\",\"gateway\":\"envoy-gateway-api\"}" > /app/healthz.json

# Stage 2: Nginx Web Server Runtime
FROM nginx:1.27-alpine-slim

# Patch celah keamanan (CVE) OS packages untuk lolos scan Trivy
RUN apk update && apk upgrade --no-cache

# Hapus konfigurasi dan file bawaan nginx
RUN rm -rf /etc/nginx/conf.d/* /usr/share/nginx/html/*

# Pasang konfigurasi nginx kustom
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Salin static assets dan healthz.json
COPY --from=builder /app/index.html /usr/share/nginx/html/index.html
COPY --from=builder /app/style.css /usr/share/nginx/html/style.css
COPY --from=builder /app/app.js /usr/share/nginx/html/app.js
COPY --from=builder /app/healthz.json /usr/share/nginx/html/healthz.json

EXPOSE 80

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]