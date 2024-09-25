#!/bin/bash
set -x

# definitions
ssh_port=$1

# start configurations
cd /home/ubuntu

# ssh config
curl https://raw.githubusercontent.com/motojouya/develop-gce/main/resources/sshd_config.tmpl -O
sed -e s/{%port%}/$ssh_port/g sshd_config.tmpl > sshd_config.init
cp sshd_config.init /etc/ssh/sshd_config
systemctl restart sshd

apt-get update
apt-get install -y jq
apt-get install -y tmux
apt-get install -y tree
apt-get install -y xauth

# apt-add-repository -y ppa:mizuno-as/silversearcher-ag
# apt-get update -y
apt-get install -y silversearcher-ag

apt-get install -y nvme-cli

# apt-get install -y nodejs
# apt-get install -y npm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs
npm install --global yarn
npm install -g npx
npm install -g typescript typescript-language-server

# install docker
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

# # others
# /home/$username/.fzf/install --bin

# config
mkdir .ssh
curl -L https://raw.githubusercontent.com/motojouya/develop-gce/main/resources/ssh_config.tmpl -o .ssh/config
curl https://raw.githubusercontent.com/motojouya/vimrc/master/.vimrc -O
curl https://raw.githubusercontent.com/motojouya/vimrc/master/.bashrc -O
curl https://raw.githubusercontent.com/motojouya/vimrc/master/.tmux.conf -O
chown -R ubuntu:ubuntu .

