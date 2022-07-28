# Intro

Here we have the terraform files to build the cluster after you built it with ansible. 

You should login in terraform cloud

Get api keys for cloudflare

Get api keys for hashicorp vault (maybe)

Terraform will them deploy argo and everything we need :) 

TODO: Make ansible create terraform tfvars file form encrypted vault!


# Requirements

Terraform cloud account

Cloudflare account

Domain name pointing to cloudflare nameservers

# Howto

```
export KUBECONFIG=~/.kube/homeconfig
export ENV=prod
ansible-playbook -i ../metal/inventories/$ENV.yml --ask-vault-password namespaces.yml
ansible-playbook -i ../metal/inventories/$ENV.yml --ask-vault-password config.yml
terraform apply
```

If you are using a freenom domain you will not be able to create dns via cloudflare api (in this case terraform), you need to manually create them. 

The workaround is to create a "*" record and proxy that to the cluster, disable external dns and letsencrypt (we can use self-signed certificate since this is only for communication between the cluster and cloudflare that should be done via a secure tunnel anyway)
