# `apps/frontend` DevOps Showcase Portal

Aplikasi Web UI modern berbasis **Single Page Application (SPA)** yang di-serve menggunakan **Nginx Alpine**. Dirancang untuk menggantikan `backend-go` sebagai workload utama pada pipeline CI/CD Jenkins, GitOps ArgoCD, dan Envoy Gateway API.

---

## ­ƒîƒ Fitur Utama

- **Live Telemetry & Metadata Injection**: Mengambil data nomor build Jenkins (`BUILD_NUMBER`), Git SHA (`COMMIT_SHA`), dan commit message dari endpoint `/healthz` yang dibuat otomatis saat docker build.
- **Micro Web Server Nginx**: Berukuran ultra-ringan (~20MB), mengelola static file serving, MIME types, gzip compression, dan SPA routing fallback (`try_files $uri $uri/ /index.html;`).
- **DevSecOps Ready**: Kompatibel dengan pemindaian kerentanan Aqua Security Trivy pada stage Jenkins CI.
- **Envoy Gateway Ingress**: Dirutekan langsung oleh Kubernetes Gateway API ke port 80 pada `http://localhost`.

---

## ­ƒøá´©Å Menjalankan Secara Lokal (Development)

```bash
# 1. Jalankan unit/smoke test
npm test

# 2. Jalankan server lokal sederhana
npx serve .
# Buka di browser: http://localhost:3000
```

---

## ­ƒÉ│ Docker Build & Container Testing

```bash
# Build multi-stage image dengan build argument CI
docker build \
  --build-arg BUILD_NUMBER=1 \
  --build-arg COMMIT_SHA=manual-local \
  --build-arg "COMMIT_MESSAGE=Manual local build" \
  -t frontend:1 .

# Jalankan container
docker run -d -p 80:80 --name frontend-ui frontend:1

# Uji health check & metadata JSON
curl -i http://localhost/healthz

# Buka tampilan UI di browser
# http://localhost
```
