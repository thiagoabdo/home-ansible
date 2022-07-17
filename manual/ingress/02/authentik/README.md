
kubectl create namespace authentik
helm repo add authentik https://charts.goauthentik.io
helm repo update
helm upgrade --install authentik authentik/authentik -f values.yaml -n authentik

# change password in https://<ingress you've specified>/if/flow/initial-setup/

# inside authentik, create a Provider typed ProxyProvider.
# Create and attach an application to it
# Create an outpost integration
# Create an outpost that attaches to everything else, if you want the outpost_ingress to work out of the box call it `mainoutpost`

kubectl apply -n authentik -f outpost_ingress.yaml