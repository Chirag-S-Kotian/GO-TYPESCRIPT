# DevSecOps-Ready Full Stack Boilerplate

<p align="center">
  <img src="client/public/gologo.svg" alt="Go Logo" width="60"/>
  <img src="client/public/next.svg" alt="Next.js Logo" width="60"/>
  <img src="client/public/postgres.svg" alt="Postgres Logo" width="60"/>
</p>

<p align="center">
  <a href="https://github.com/ck117/devsecops-boilerplate/actions"><img src="https://github.com/ck117/devsecops-boilerplate/workflows/CI/badge.svg" alt="CI Status"></a>
  <a href="https://github.com/ck117/devsecops-boilerplate/blob/main/LICENSE"><img src="https://img.shields.io/github/license/ck117/devsecops-boilerplate.svg" alt="License"></a>
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome">
</p>

---

A modern, production-ready full stack application with:
- **Go REST API** backend
- **Next.js** frontend
- **PostgreSQL** database
- **Docker** & **Kubernetes** ready
- Designed for **DevSecOps**: CI/CD, SAST, container scanning, GitOps, and cloud-native deployment

---

## 🚀 Features
- Modular codebase: `backend/` (Go), `client/` (Next.js), `k8s/` (Kubernetes manifests)
- Local development with Docker Compose
- Cloud deployment with Kubernetes (GKE-ready)
- Persistent database storage
- Ready for GitHub Actions, ArgoCD, Helm, Prometheus, Grafana, Terraform

## 🗂️ Project Structure
```
backend/    # Go REST API
client/     # Next.js frontend
k8s/        # Kubernetes manifests (modular)
compose.yaml# Docker Compose for local dev
```

## 🛠️ Installation & Local Development
1. **Clone & Fork**
   ```sh
   git clone https://github.com/ck117/devsecops-boilerplate.git
   cd devsecops-boilerplate
   ```
   Click "Fork" on GitHub to create your own copy.

2. **Build & Run Locally**
   ```sh
   docker compose up --build
   ```
   - Frontend: http://localhost:3000
   - Backend: http://localhost:8000
   - DB: localhost:5432 (user/pass: postgres)

## ☸️ Kubernetes Deployment
1. **Push your images** to Docker Hub or GCR
2. **Update image fields** in `k8s/*/deployment.yaml`
3. **Apply manifests**:
   ```sh
   kubectl apply -f k8s/postgres/pvc.yaml
   kubectl apply -f k8s/postgres/deployment.yaml
   kubectl apply -f k8s/postgres/service.yaml
   kubectl apply -f k8s/backend/deployment.yaml
   kubectl apply -f k8s/backend/service.yaml
   kubectl apply -f k8s/frontend/deployment.yaml
   kubectl apply -f k8s/frontend/service.yaml
   ```

## 🔒 DevSecOps Ready
- **CI/CD**: GitHub Actions templates ready
- **Security**: SAST, container scanning, secrets management
- **Monitoring**: Prometheus & Grafana integration
- **GitOps**: ArgoCD & Helm compatible
- **IaC**: Terraform for GCP infra (see `/iac` if present)

## 🤝 Contributing
- Fork the repo and create your branch from `main`
- Open a pull request with a clear description
- All contributions are welcome!

## 📄 License
[MIT](LICENSE)

---

<p align="center">
  <img src="client/public/globe.svg" width="40"/>
  <img src="client/public/vercel.svg" width="40"/>
  <img src="client/public/window.svg" width="40"/>
</p>
