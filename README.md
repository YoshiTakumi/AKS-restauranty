## Table of Contents
1. [Project Overview](#project-overview)
2. [Project Structure](#project-structure)
3. [Running Locally](#running-locally)
4. [Environment Variables & Secrets](#environment-variables--secrets)
5. [Docker Compose & HAProxy](#docker-compose--haproxy)
6. [Deployment](#deployment)
7. [Kubernetes Orchestration](#kubernetes-orchestration)
8. [Infrastructure Provisioning (Terraform)]
9. [CI/CD Pipeline](#cicd-pipeline)
10. [Monitoring & Logging](#monitoring--logging)
11. [Security & Compliance](#security--compliance)
12. [Final Notes](#final-notes)

---

## Project Overview

**Restauranty** is a production-ready, microservices-based restaurant management app, fully deployed on Azure Kubernetes Service (AKS) with CI/CD, observability, and strong security practices.  
**Features:**
- 3 Node.js microservices (`auth`, `discounts`, `items`)
- 1 React frontend (`client`)
- MongoDB (local) / Azure Cosmos DB (production)
- Azure Blob Storage for images
- Automated deployments via GitHub Actions and Azure Container Registry (ACR)
- Real DNS and HTTPS (Let's Encrypt)
- Full monitoring (Prometheus + Grafana)
- NetworkPolicies, Kubernetes Secrets, and best-practice security

---

## Project Structure
├── aks-tf/ # Terraform for AKS, ACR, Cosmos DB, Blob
│ ├── main.tf
│ ├── variables.tf
│ ├── terraform.tfvars
├── backend/
│ ├── auth/ # Auth microservice (Node.js, JWT)
│ ├── discounts/ # Discounts microservice
│ └── items/ # Items microservice (Azure Blob integration)
├── client/ # React frontend app
├── docker-compose.yml # Local multi-container orchestration
├── haproxy.cfg # Local reverse proxy for unified routing
├── k8s/ # Kubernetes manifests (deployments, ingress, policies)
│ ├── auth-deployment.yaml
│ ├── discounts-deployment.yaml
│ ├── items-deployment.yaml
│ ├── frontend-deployment.yaml
│ ├── ingress.yaml
│ ├── networkpolicy-*.yaml
│ └── cluster-issuer.yaml.template
├── grafana-ingress/ # Helm chart for Grafana ingress
├── prometheus-ingress/ # Helm chart for Prometheus ingress
├── .github/
│ └── workflows/
│ └── ci-cd.yaml # GitHub Actions pipeline
└── README.md

---

## Running Locally

1. **Clone the repo:**
   ```sh
   git clone https://github.com/YoshiTakumi/AKS-restauranty.git
   cd AKS-restauranty
2. Create .env files for each microservice and the frontend (see .env.example).

3. Start everything with Docker Compose:
    docker-compose up --build
   Launches all services + MongoDB + HAProxy for unified routing on port 80.

4. Access the app:
    Open http://localhost

    All API calls from the frontend are routed via HAProxy (see haproxy.cfg) to the correct backend.

---

## Environment variables and secrets
Each service uses its own .env file.

Never commit actual secrets!

Examples:

SECRET, MONGODB_URI, AZURE_STORAGE_CONNECTION_STRING, etc.

Frontend uses REACT_APP_SERVER_URL

All secrets in production are handled via Kubernetes Secrets and GitHub Actions secrets.

---

## Docker Compose & HAProxy
See provided docker-compose.yml and haproxy.cfg.

HAProxy unifies all services under a single port (80), using path-based routing:

/api/auth → auth

/api/discounts → discounts

/api/items → items

/ → client

---

## Deployment
Azure Services Used
    AKS: Main Kubernetes cluster

    ACR: Azure Container Registry for images

    Cosmos DB: MongoDB API

    Azure Blob: For images/data

    DNS: Custom domains for all endpoints

    Ingress & HTTPS
    NGINX Ingress unifies all services under one domain.

    DNS records (app.yorgos.site, grafana.yorgos.site, prometheus.yorgos.site) point to Ingress IP.

    Cert-Manager and Let’s Encrypt provide automatic TLS certificates for all endpoints.

---

## Kubernetes Orchestration
Each service has its own Deployment and Service YAML in k8s/.

Single Ingress resource unifies all API/backend/frontend routes.

Helm is used for Prometheus and Grafana Ingress resources (customizable).


---

## Infrastructure Provisioning (Terraform)

All core Azure infrastructure for Restauranty is provisioned automatically via Terraform (`aks-tf/`):

- **Resource Group:** Central container for all cloud resources
- **Azure Kubernetes Service (AKS):** Managed K8s cluster for running all microservices, frontend, and monitoring workloads
- **Azure Container Registry (ACR):** Stores and serves Docker images; AKS is granted pull permissions
- **Azure Cosmos DB (MongoDB API):** Production NoSQL database for all services (with database and collection managed as code)
- **Azure Blob Storage:** (add if you manage it in Terraform, or clarify as “external” if not)
- **DNS:** (add if you manage DNS via Terraform; if not, mention it’s managed separately)

**Terraform outputs important connection strings and endpoints:**
- AKS kubeconfig (for `kubectl` access)
- ACR login server (for image pushes/pulls)
- Cosmos DB connection string (for secure app/database connection)


---

## CI/CD Pipeline
GitHub Actions automates the build, push, and deploy for every commit to main.

Pipeline:

Build/test all Node.js/React services

Build/push Docker images to ACR

Create/update Kubernetes Secrets for each service

Deploy to AKS (kubectl apply -f k8s/)

Upgrade Helm charts for monitoring

Apply ClusterIssuer for HTTPS

Roll out deployments

Secrets (DB URIs, API keys, etc.) are set via GitHub repository secrets.

---

## Monitoring & Logging
Prometheus & Grafana (via Helm) run in the monitoring namespace.

Accessible at https://grafana.yorgos.site and https://prometheus.yorgos.site

Custom dashboards and scrape configs are defined.

Services log to stdout for aggregation by Kubernetes (optionally, integrate with Azure Monitor).


---

## Security & Compliance
Kubernetes NetworkPolicies: Only allowed pods can reach API pods; only Ingress can reach frontend; only Prometheus can scrape metrics.

HTTPS everywhere: Cert-manager and Let’s Encrypt for auto-renewed TLS.

Secrets in Kubernetes: Managed via CI/CD, never committed.

RBAC: Default Kubernetes RBAC and Azure AD recommended for access control.

See SECURITY.md for full security details.





