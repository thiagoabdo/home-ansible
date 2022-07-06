To get all this working you will need to install cloudflared as it is the only way I known to get the tunnel.json

This snippeds helped a lot, thanks https://itnext.io/using-cloudflare-tunnels-to-securely-expose-kubernetes-services-26713fb5da0a



```bash
# download the linux binary version for your VM
# source: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation

# download the binary file
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
# allow execution
chmod +x cloudflared
# move to the path
sudo mv cloudflared /usr/local/bin/

# test the executable
cloudflared --version
# you should see something like this: cloudflared version 2022.1.2 (built 2022-01-13-1311 UTC)

# log into your account
cloudflared tunnel login
# this gives you a link to authorize the login via your browser
# create a tunnel:
cloudflared tunnel create <NAME>
# this will show you the UUID for this tunnel, you should be able to confirm the creation of tunnel by the following:
cloudflared tunnel list

# create DNS rule to route traffic to your tunnel:
cloudflared tunnel route dns <NAME> <hostname>
# example: cloudflared tunnel route dns web-service secure.nima-dev.com
# here you can tunnel *.hostname and hostname, that way you do not to care about it anymore
```

This is configmap.yml
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloudflared-config
data:
  # custom init script
  config.yml: |
    tunnel: $CLOUDFLARED_TUNNEL_ID # this should be replaced with your tunnel id
    credentials-file: /etc/cloudflared/tunnel.json # this is the path we will mount the tunnel json file
    no-autoupdate: true

    ingress:
        - service: http://web.default.svc.cluster.local:80 # this should be the correct dns and port for your service
```

This is deployment.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloudflared-tunnel
spec:
  selector:
    matchLabels:
      app: cloudflared-tunnel
  template:
    metadata:
      labels:
        app: cloudflared-tunnel
    spec:
      volumes:
      - name: cloudflared-auth-volume
        secret:
          secretName: cloudflared-auth
      - name: cloudflared-config
        configMap:
          name: cloudflared-config
          items:
            - key: config.yml
              path: config.yml
      containers:
      - name: cloudflared-tunnel
        image: ghcr.io/nimamahmoudi/cloudflared:sha-58c4400
        volumeMounts:
          - name: cloudflared-auth-volume
            mountPath: /etc/cloudflared/tunnel.json
            subPath: tunnel.json
            readOnly: true
          - name: cloudflared-auth-volume
            mountPath: /etc/cloudflared/cert.pem
            subPath: cert.pem
            readOnly: true
          - name: cloudflared-config
            mountPath: /etc/cloudflared/config.yml
            subPath: config.yml
            readOnly: true
        env:
          - name: TUNNEL_NAME
            value: $CLOUDFLARED_TUNNEL_NAME # for example, web-service
```

```bash
# create namespace
kubectl create ns cloudflared

# create secret for tunnel.json and cert.pem
# filenames are important the name of the file will be the resulting name inside the k8s secret
kubectl create secret -n cloudflared generic cloudflared-auth \
  --from-file=./config/tunnel.json \
  --from-file=./config/cert.pem

# apply the configmap
kubectl apply -n cloudflared -f configmap.yml
# apply the deployment
kubectl apply -n cloudflared -f deployment.yml

# get the pod name after deployment
CFD_POD_NAME=$(kubectl get pods -n cloudflared --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep ^cloudflared-)
# get the logs to make sure everything is alright
kubectl logs $CFD_POD_NAME -n cloudflared
```

In case you ever need to update something:
```bash
kubectl rollout restart deployment -n cloudflared cloudflared-tunnel
```