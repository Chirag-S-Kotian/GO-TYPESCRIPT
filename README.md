# DevSecOps-Ready Full Stack Project

This project is a modern, containerized full stack application with a Go REST API backend, Next.js frontend, and PostgreSQL database. It is structured for production-grade DevSecOps workflows and cloud-native deployment.

## Codebase Structure

- **backend/**: Go REST API (Dockerized)
- **client/**: Next.js frontend (Dockerized)
- **k8s/**: Kubernetes manifests (modular, organized by service)
- **compose.yaml**: Local development with Docker Compose

## Key Features

- **Go Backend**: CRUD API, connects to PostgreSQL
- **Next.js Frontend**: User management UI, API integration
- **PostgreSQL**: Official image, persistent storage
- **Dockerized**: Production-ready Dockerfiles for both services
- **Kubernetes-Ready**: Modular manifests for scalable cloud deployment

## Quick Start (Local)
```sh
docker compose up --build
```

## Kubernetes Deployment
1. Push your images to Docker Hub or GCR
2. Update image fields in `k8s/*/deployment.yaml`
3. Apply manifests:
```sh
kubectl apply -f k8s/postgres/pvc.yaml
kubectl apply -f k8s/postgres/deployment.yaml
kubectl apply -f k8s/postgres/service.yaml
kubectl apply -f k8s/backend/deployment.yaml
kubectl apply -f k8s/backend/service.yaml
kubectl apply -f k8s/frontend/deployment.yaml
kubectl apply -f k8s/frontend/service.yaml
```

---

- **Secure by Design**: Ready for CI/CD, SAST, container scanning, and GitOps
- **Cloud Native**: Built for GKE, ArgoCD, Helm, Prometheus, Grafana, and Terraform
