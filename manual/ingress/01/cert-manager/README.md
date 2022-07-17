kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.8.2 --set installCRDs=true --set prometheus.enabled=false 

# In the future we should have certmanager origin CA working or Letsencrypt with dns records. At the moment tho we can use this:
kubectl apply -f self-signed.yaml

# This is not working at the moment because it can only issue certificates to the namespace that the originissuer leaves. 
# Tbh is probably better to have Letencrypt working, that way we can set up local access as well.

kubectl apply -f deploy/crds
kubectl apply -f deploy/rbac
kubectl apply -f deploy/manifests

create a secret with: https://github.com/cloudflare/origin-ca-issuer#adding-an-originissuer

kubectl apply -f service-key.yaml -f issuer.yaml -n origin-ca-issuer

kubectl apply -f self-signed.yaml