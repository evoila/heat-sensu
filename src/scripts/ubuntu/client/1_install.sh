#!/bin/bash

export DEBIAN_FRONTEND="noninteractive"

PLUGINS=${PLUGINS:-'[]'}


# Install sensu
wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | sudo apt-key add -

CODENAME=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d "=" -f2)
echo "deb     https://sensu.global.ssl.fastly.net/apt $CODENAME main" | sudo tee /etc/apt/sources.list.d/sensu.list

apt-get update
apt-get install -y sensu

cat <<EOF > /etc/default/sensu
EMBEDDED_RUBY=true
export TMPDIR=/var/run/sensu
EOF

# Install sensu plugins
PROXY_OPTION=''
if [ ! -z $http_proxy ]; then
  PROXY_OPTION="-x $http_proxy"
fi

LENGTH=$(echo ${PLUGINS} | jq 'length')
LAST_INDEX=$((LENGTH-1))

for I in `seq 0 $LAST_INDEX`; do
  PLUGIN=$(echo $PLUGINS | jq -r ".[$I]" )
  sensu-install -v $PROXY_OPTION -p $PLUGIN
done
