# Intro

This is heavily inspired from https://github.com/khuedoan/homelab

It has some differences tho:
 - Khuedoan is using fedora atm. I am using rockylinux 9
 - Khuedoan is using grub to boot. I am ipxe only 


# boot.yml

## Intro

This playbook is responsible to install rockylinux and k3s.

## How to use it

Requirements for the ansible runner:
 - xorriso
 - python's netaddr
 - python's docker
 - python's docker-compose

Fixup your inventory var, add a k3s_token that is encrypted for you

```
ansible-vault encrypt_string --ask-vault-pass $(openssl rand -base64 32) --name 'k3s_token_base64
```

```
ansible-playbook --ask-vault-password --inventory inventory/${env}.yml boot.yml
```

After installing a new cluster you can get the Kubernetes config file using ssh.
```
MASTERIP=<MASTERIP>
scp root@$MASTERIP:/etc/rancher/k3s/k3s.yaml kubeconfig
sed -i "s/127.0.0.1/$MASTERIP/g" kubeconfig
```

Now if you do not have other kubeconfig's you can move this one to `~/.kube/config`
if you do have access to other clusters you may want to keep them separated.
In my case, it is `~/.kube/homeconfig` and I can changing `KUBECONFIG` environment variable to it.

# cluster.yml

## Intro

This playbook is responsible to install some stuff in the cluster, it should be run only once per cluster.

## How to use it

Requirements for the ansible runner:
 - `ansible-galaxy collection install kubernetes.core`
 - python's kubernetes

```
ansible-playbook --inventory inventory/${env}.yml cluster.yml
```