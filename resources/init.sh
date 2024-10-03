#!/bin/bash
set -x

ssh_port=$1
cd /home/ubuntu

# sshd
curl https://raw.githubusercontent.com/motojouya/develop-gce/main/resources/sshd_config.tmpl -O
cp sshd_config.tmpl /etc/ssh/sshd_config
systemctl restart ssh

# ssh port
curl https://raw.githubusercontent.com/motojouya/develop-gce/main/resources/ssh.socket.tmpl -O
sed -e s/{%port%}/$ssh_port/g ssh.socket.tmpl > ssh.socket.init
cp ssh.socket.init /lib/systemd/system/ssh.socket
systemctl restart ssh.socket
systemctl daemon-reload
# again but mystery
systemctl restart ssh.socket
systemctl daemon-reload

# home
mkdir .ssh
curl -L https://raw.githubusercontent.com/motojouya/develop-gce/main/resources/ssh_config.tmpl -o .ssh/config
curl https://raw.githubusercontent.com/motojouya/vimrc/master/.vimrc -O
curl https://raw.githubusercontent.com/motojouya/vimrc/master/.bashrc -O
curl https://raw.githubusercontent.com/motojouya/vimrc/master/.tmux.conf -O
chown -R ubuntu:ubuntu .

# apt
apt-get update
apt-get install -y jq tmux tree xauth git silversearcher-ag sqlite3 curl wget

# node
curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt-get install -y nodejs
npm install -g npx typescript typescript-language-server

# litestream
wget https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.deb
dpkg -i litestream-v0.3.13-linux-amd64.deb
# 
# # apt again
# apt-get install -y ca-certificates
# apt-get install -y gnupg
# apt-get install -y software-properties-common
# 
# # docker
# mkdir -m 0755 -d /etc/apt/keyrings # install?
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# chmod a+r /etc/apt/keyrings/docker.asc
# 
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
#   tee /etc/apt/sources.list.d/docker.list > /dev/null
# apt-get update
# apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# 
# gpasswd -a ubuntu docker
# systemctl restart docker
# 
# # terraform
# curl -fsSL https://apt.releases.hashicorp.com/gpg | \
#   gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
# # gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
# echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
#   tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
# apt update
# apt-get install terraform
