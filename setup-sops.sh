#!/bin/bash
set -e

echo "🔐 SOPS + ArgoCD Integration Setup"
echo "=================================="

# Check prerequisites
echo "Checking prerequisites..."
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not found"; exit 1; }
command -v sops >/dev/null 2>&1 || { echo "❌ sops not found"; exit 1; }
command -v age >/dev/null 2>&1 || { echo "❌ age not found"; exit 1; }

# Check age key exists
if [ ! -f "age-key.txt" ]; then
    echo "❌ age-key.txt not found. Run: age-keygen -o age-key.txt"
    exit 1
fi

echo "✅ Prerequisites OK"

# 1. Create SOPS age key secret in ArgoCD namespace
echo "Creating SOPS age key secret..."
kubectl create secret generic sops-age-key \
  --from-file=age-key.txt \
  --namespace=argocd \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ SOPS age key secret created"

# 2. Patch ArgoCD repo server with SOPS support
echo "Patching ArgoCD repo server..."
kubectl patch deployment argocd-repo-server -n argocd --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/initContainers/-",
    "value": {
      "name": "install-sops",
      "image": "alpine:3.18",
      "command": ["/bin/sh", "-c"],
      "args": [
        "echo Installing SOPS and Age... && apk add --no-cache curl && curl -L https://github.com/mozilla/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64 -o /tools/sops && chmod +x /tools/sops && curl -L https://github.com/FiloSottile/age/releases/download/v1.1.1/age-v1.1.1-linux-amd64.tar.gz | tar -xzC /tmp && cp /tmp/age/age /tools/ && chmod +x /tools/age && echo SOPS and Age installed successfully"
      ],
      "volumeMounts": [
        {
          "name": "tools",
          "mountPath": "/tools"
        }
      ]
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/env/-",
    "value": {
      "name": "SOPS_AGE_KEY_FILE",
      "value": "/sops-keys/age-key.txt"
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/env/-", 
    "value": {
      "name": "PATH",
      "value": "/tools:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/volumeMounts/-",
    "value": {
      "name": "sops-age-key",
      "mountPath": "/sops-keys",
      "readOnly": true
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/volumeMounts/-",
    "value": {
      "name": "tools",
      "mountPath": "/tools"
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/volumes/-",
    "value": {
      "name": "sops-age-key",
      "secret": {
        "secretName": "sops-age-key",
        "defaultMode": 420
      }
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/volumes/-",
    "value": {
      "name": "tools",
      "emptyDir": {}
    }
  }
]'

echo "✅ ArgoCD repo server patched"

# 3. Wait for rollout
echo "Waiting for ArgoCD repo server rollout..."
kubectl rollout status deployment/argocd-repo-server -n argocd --timeout=300s

echo "✅ ArgoCD repo server updated"

# 4. Test SOPS integration
echo "Testing SOPS integration..."
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}')

kubectl exec $REPO_POD -n argocd -- sh -c '
if command -v sops >/dev/null 2>&1 && command -v age >/dev/null 2>&1 && [ -f "$SOPS_AGE_KEY_FILE" ]; then
    echo "✅ SOPS integration successful"
    exit 0
else
    echo "❌ SOPS integration failed"
    exit 1
fi
' && echo "🎉 SOPS setup completed successfully!" || echo "❌ SOPS setup failed"

echo ""
echo "Next steps:"
echo "1. Update gitops/applications/wordpress-app.yaml with your GitHub repo URL"
echo "2. git add . && git commit -m 'Setup SOPS integration' && git push"
echo "3. kubectl apply -f gitops/projects/wordpress-project.yaml"
echo "4. kubectl apply -f gitops/applications/wordpress-app.yaml"
