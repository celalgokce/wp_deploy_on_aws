# 🚀 WordPress on Kubernetes with Enterprise Security

Production-ready WordPress deployment on Kubernetes using Helm charts, SOPS encryption, and Infrastructure as Code principles.

## 📋 Project Overview

This project demonstrates a complete WordPress application deployment with MySQL database on Kubernetes, featuring enterprise-grade secret management and multi-environment support.

**Live Demo:** `http://localhost:30693` (Docker Desktop)

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   NodePort      │────│   WordPress     │────│     MySQL       │
│  (Port 30693)   │    │   (Deployment)  │    │  (StatefulSet)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
    Local Access           Kubernetes                Persistent
                          Service Mesh                Storage
```

## 🔐 Security Features

- **SOPS Encryption**: Secrets encrypted with Age encryption (zero plain-text passwords in Git)
- **Helm Secrets Integration**: Runtime secret decryption
- **Resource Management**: CPU/Memory limits for security
- **Multi-Environment Separation**: Dev/staging/prod isolation

## 📦 Tech Stack

- **Kubernetes**: Container orchestration (Docker Desktop)
- **Helm**: Package management and templating
- **SOPS + Age**: Secret encryption
- **MySQL**: Database (Bitnami chart)
- **WordPress**: Application (official image)

## 🚀 Quick Start

### Prerequisites
- Docker Desktop with Kubernetes enabled
- Helm 3.x
- SOPS
- Age encryption
- kubectx/kubens (optional)

### Deployment
```bash
# Clone repository
git clone <your-repo>
cd wordpress-on-k8s

# Switch to Docker Desktop context
kubectx docker-desktop

# Deploy WordPress
helm secrets install wordpress-local wordpress/ \
  -f wordpress/values.yaml \
  -f values-local.yaml \
  -f wordpress/secrets/database.yaml

# Access WordPress
open http://localhost:30693
```

## 📁 Project Structure

```
wordpress-on-k8s/
├── .sops.yaml                    # SOPS encryption config
├── values-local.yaml             # Docker Desktop overrides
├── wordpress/
│   ├── Chart.yaml                # Helm chart metadata + MySQL dependency
│   ├── values.yaml               # Base configuration
│   ├── secrets/
│   │   └── database.yaml         # Encrypted database credentials
│   └── templates/
│       ├── deployment.yaml       # WordPress deployment
│       ├── service.yaml          # NodePort service
│       ├── secret.yaml           # Secret management
│       └── _helpers.tpl          # Template helpers
```

## 🎯 Key Features

### Environment-Specific Configurations
- **Local Development**: Docker Desktop with NodePort (port 30693)
- **Resource Optimization**: Memory/CPU tuned for local environment
- **Storage Management**: Hostpath storage for local persistence

### Security Best Practices
- **No plain-text secrets** in repository
- **Age encryption** for future-proof security
- **Selective encryption** (only sensitive fields)
- **Runtime secret injection**

### Infrastructure as Code
- **Helm templating** for reusable deployments
- **Version-controlled** infrastructure
- **Dependency management** with Chart.lock
- **Multi-environment** support ready

## 🔧 Management Commands

```bash
# Check deployment status
kubectl get pods
kubectl get svc

# View logs
kubectl logs deployment/wordpress-local
kubectl logs wordpress-local-mysql-0

# Update deployment
helm secrets upgrade wordpress-local wordpress/ \
  -f wordpress/values.yaml \
  -f values-local.yaml \
  -f wordpress/secrets/database.yaml

# Cleanup
helm uninstall wordpress-local
```

## 💰 Cost Optimization

**Migration Impact:**
- **Before**: AWS EKS (~$876/year)
- **After**: Docker Desktop ($0/year)
- **Savings**: 100% cost reduction for development

## 📚 Learning Outcomes

### Core Kubernetes Skills
- Pod, Deployment, Service, PVC management
- Resource limits and health checks
- Storage classes and persistent volumes
- Multi-environment deployment strategies

### Advanced DevOps Practices
- **Helm Chart Development**: Templates, helpers, dependencies
- **Secret Management**: SOPS encryption workflow
- **Infrastructure as Code**: Version-controlled deployments
- **Debugging**: Pod troubleshooting and log analysis

### Cloud & Platform Skills
- AWS EKS experience and cost optimization
- Docker Desktop Kubernetes setup
- Cloud-to-local migration strategies
- Performance tuning for different environments

## 🎯 Next Steps

- [ ] SSL/TLS implementation with cert-manager
- [ ] Monitoring setup (Prometheus + Grafana)
- [ ] GitOps workflow with ArgoCD
- [ ] Multi-environment structure (dev/staging/prod)
- [ ] Backup and disaster recovery

## 📈 Professional Skills Gained

This project demonstrates **mid-level DevOps engineering** capabilities:

✅ **Production-ready Kubernetes deployments**  
✅ **Enterprise-grade secret management**  
✅ **Infrastructure as Code practices**  
✅ **Cost optimization and migration strategies**  
✅ **Multi-environment deployment patterns**  
✅ **Advanced troubleshooting and debugging**  

## 🤝 Contributing

This project showcases modern DevOps practices and can serve as a template for similar WordPress deployments on Kubernetes.

---

**Built with ❤️ using modern DevOps practices**
