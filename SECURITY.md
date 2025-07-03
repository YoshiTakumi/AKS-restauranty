
---

# `SECURITY.md`

```markdown
# Security and Compliance – Restauranty

This document summarizes the security controls, best practices, and compliance posture for the Restauranty project.

---

## 1. Secrets Management

- **Development:**  
  - Secrets (API keys, DB URIs, etc.) are stored in local `.env` files (never committed).
- **Production:**  
  - All sensitive environment variables are injected via **Kubernetes Secrets**.
  - Secrets are provisioned and managed via **GitHub Actions** pipeline.
  - No plaintext credentials are committed or logged at any point.

---

## 2. Authentication & Authorization

- All API endpoints (except `/auth/login` and `/auth/register`) require a valid **JWT token**.
- The `auth` microservice issues tokens. Other services (`discounts`, `items`) validate the JWT from the `Authorization` header.
- Role-based access can be enforced via JWT claims if required.

---

## 3. Network Security

- **Ingress:**  
  - Only the NGINX Ingress controller is exposed to the internet.
  - All other services have **ClusterIP** scope (not exposed externally).
- **NetworkPolicies:**  
  - Only the frontend can call backend APIs.
  - Only Prometheus (in `monitoring` namespace) can scrape API metrics.
  - Only Ingress controller pods can access the frontend pod.
  - All other pod-to-pod traffic is denied by default.

---

## 4. TLS/HTTPS

- All public endpoints use **HTTPS** via Cert-Manager and Let’s Encrypt.
- Certificates are provisioned and renewed automatically in Kubernetes using ClusterIssuer.
- TLS is enforced at the Ingress for all services (frontend, APIs, monitoring).

---

## 5. Container and Cluster Security

- All containers run as non-root users where possible.
- Images are rebuilt and redeployed on every pipeline run.
- Azure AKS provides node isolation, cluster RBAC, and cloud-native controls.
- **RBAC:**  
  - Access to the AKS cluster is controlled via Azure AD and Kubernetes RBAC.
  - No shared cluster admin credentials.
- **Image registry (ACR):**  
  - Images are stored securely in Azure Container Registry.

---

## 6. Logging & Monitoring

- All services log to stdout for Kubernetes aggregation.
- Prometheus scrapes custom metrics endpoints for all APIs.
- Grafana dashboards monitor system health and usage.
- Access to Grafana and Prometheus is HTTPS-protected and limited by network policies.

---

## 7. Compliance

- No sensitive data is committed to version control.
- Database is Azure Cosmos DB with at-rest encryption by default.
- All sensitive configs (Azure Blob, database URIs, JWT secrets) are managed via Kubernetes Secrets and CI/CD.

---

## 8. Recommendations

- Rotate secrets and credentials regularly.
- Review RBAC and network policies on every release.
- Use Azure Key Vault for extra secret protection if scaling up.
- Regularly audit CI/CD pipelines for secret leaks.

---

*For more information, see the main [README.md](./README.md) or open an issue for any security concern.*
