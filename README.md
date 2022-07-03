# Home configuration

I am not sure how this will be used at this moment, it will be something!


# How to reproduce my config
1. Agent Machine:
	1. Install Ansible, Kubectl, Helm
	1. A place for store sensitive files (TODO)
1. Basic server configuration:
	1. Install a vanilla arch-linux
	1. Created an unprivilledged user
	1. Installed openssh, zsh, gmrl-zsh, vim, git and python
	1. Configured internet access
	1. Install K3S using the repo linked as a submodule under "initial/"
1. Ingress:
	1. Created a free domain and a free account in cloudflare, point them togheter
	1. Install cloudlflared to creata a tunnel and bypass cgnat/nat/ISP bs docs in "ingress/cloudflared/".
	1. Add Ingress controller
	1. TODO Add Certmanager to allow *full (strict)* from Cloudflared
	1. Echo-server
1. Storage:
	1. TODO
1. Services:
	1. TODO


# Objectives (possible roles)
- Configure K3S
- Configure an github-runner in kubernetes

