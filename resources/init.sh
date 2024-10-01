#!/bin/bash
set -x

# definitions
ssh_port=$1

# start configurations
cd /home/ubuntu

# sshd
curl https://raw.githubusercontent.com/motojouya/develop-gce/main/resources/sshd_config.tmpl -O
sed -e s/{%port%}/$ssh_port/g sshd_config.tmpl > sshd_config.init
cp sshd_config.init /etc/ssh/sshd_config
systemctl restart sshd

# home
mkdir .ssh
curl -L https://raw.githubusercontent.com/motojouya/develop-gce/main/resources/ssh_config.tmpl -o .ssh/config
curl https://raw.githubusercontent.com/motojouya/vimrc/master/.vimrc -O
curl https://raw.githubusercontent.com/motojouya/vimrc/master/.bashrc -O
curl https://raw.githubusercontent.com/motojouya/vimrc/master/.tmux.conf -O
chown -R ubuntu:ubuntu .

# apt
apt-get update
apt-get install -y jq
apt-get install -y tmux
apt-get install -y tree
apt-get install -y xauth
apt-get install -y git
apt-get install -y silversearcher-ag
apt-get install -y sqlite3

# node
curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt-get install -y nodejs
npm install -g npx
npm install -g typescript typescript-language-server

# litestream
curl https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.deb -O
dpkg -i litestream-v0.3.13-linux-amd64.deb

# apt again
apt-get install -y gnupg
apt-get install -y software-properties-common

# docker
apt-get install -y \
    ca-certificates \
    curl \
    gnupg
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

gpasswd -a ubuntu docker
systemctl restart docker

# curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
# chmod +x /usr/local/bin/docker-compose

# install docker
dnf install -y docker
systemctl enable --now docker
systemctl status docker
usermod -aG docker $username
docker info

sudo dnf install -y docker
sudo systemctl enable --now docker
docker info

DOCKER_CONFIG=${DOCKER_CONFIG:-/usr/local/lib/docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
docker compose version
# dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
# dnf --releasever=36 install -y docker-buildx-plugin docker-compose-plugin
# gpasswd -a $username docker
# systemctl restart docker

# terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
# gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
apt update
apt-get install terraform
