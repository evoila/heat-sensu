#!/bin/bash

export DEBIAN_FRONTEND="noninteractive"

# Install sensu
wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | sudo apt-key add -

CODENAME=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d "=" -f2)
echo "deb https://sensu.global.ssl.fastly.net/apt $CODENAME main" | sudo tee /etc/apt/sources.list.d/sensu.list

apt-get update
apt-get install -y uchiwa
