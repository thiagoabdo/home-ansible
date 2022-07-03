# Ingress controller

Basic nginx ingress controller, at the moment only one.

Create a namespace for it on Kubernetes with:

```bash
kubectl apply -f namespace.yml
```

To install the ingress controller run the following, remember to check if everything in values is correct.

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade -i  public -f public_values.yml -n ingress ingress-nginx/ingress-nginx
```