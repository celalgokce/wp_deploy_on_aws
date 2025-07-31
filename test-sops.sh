#!/bin/bash

echo "🧪 SOPS Integration Test"
echo "======================="

# Test local SOPS decryption
echo "Testing local SOPS decryption..."
if sops -d wordpress/secrets/database.yaml >/dev/null 2>&1; then
    echo "✅ Local SOPS decryption works"
else
    echo "❌ Local SOPS decryption failed"
    exit 1
fi

# Test ArgoCD SOPS integration
echo "Testing ArgoCD SOPS integration..."
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}')

if [ -z "$REPO_POD" ]; then
    echo "❌ ArgoCD repo server pod not found"
    exit 1
fi

kubectl exec $REPO_POD -n argocd -- sh -c '
echo "SOPS_AGE_KEY_FILE: $SOPS_AGE_KEY_FILE"
echo "PATH: $PATH"

if command -v sops >/dev/null 2>&1; then
    echo "✅ SOPS binary found: $(which sops)"
    sops --version
else
    echo "❌ SOPS binary not found"
    exit 1
fi

if command -v age >/dev/null 2>&1; then
    echo "✅ Age binary found: $(which age)"
else
    echo "❌ Age binary not found"  
    exit 1
fi

if [ -f "$SOPS_AGE_KEY_FILE" ]; then
    echo "✅ Age key file found: $SOPS_AGE_KEY_FILE"
else
    echo "❌ Age key file not found"
    exit 1
fi
'

echo "🎉 SOPS integration test completed!"
