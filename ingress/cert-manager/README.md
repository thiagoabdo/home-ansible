kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.8.2 --set installCRDs=true --set prometheus.enabled=false 
kubectl apply -f deploy/crds
kubectl apply -f deploy/rbac
kubectl apply -f deploy/manifests

create a secret with: https://github.com/cloudflare/origin-ca-issuer#adding-an-originissuer

kubectl apply -f service-key.yaml -f issuer.yaml