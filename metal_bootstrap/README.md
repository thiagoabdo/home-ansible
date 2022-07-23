Atm this is a copy from https://github.com/khuedoan/homelab
but in the future, it should change how it is building the images

Requirements:
 - xorriso
 - python's netaddr
 - python's docker
 - python's docker-compose


To run this to create a format a cluster and install k3s.


```
ansible-playbook --inventory inventory/${env}.yml boot.yml
```
