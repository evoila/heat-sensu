#!/bin/bash

PLUGINS=${PLUGINS:-'[]'}

# Create the YUM repository file for Sensu Core repository
cat <<EOF > /etc/yum.repos.d/sensu.repo
[sensu]
name=sensu
baseurl=https://sensu.global.ssl.fastly.net/yum/\$releasever/\$basearch/
gpgcheck=0
enabled=1
EOF

if [ ! -z $http_proxy ]; then
  PROXY_USER=$(echo $http_proxy | sed -r "s#http://([^:]+):[^:]+@.*\$#\1#")
  PROXY_PASS=$(echo $http_proxy | sed -r "s#http://[^:]+:([^:]+)@.*\$#\1#")
  PROXY_URL=$(echo $http_proxy | sed -r "s#(http://)[^:]+:[^:]+@(.*$)#\1\2#")
  cat <<EOF >> /etc/yum.repos.d/sensu.repo
proxy=$PROXY_URL
proxy_username=$PROXY_USER
proxy_password=$PROXY_PASS
EOF
fi

# Install sensu
yum install -y sensu

cat <<EOF > /etc/default/sensu
EMBEDDED_RUBY=true
export TMPDIR=/var/run/sensu
EOF

# Install sensu plugins
PROXY_OPTION=''
if [ ! -z $http_proxy ]; then
  PROXY_OPTION="-x $http_proxy"
fi

LENGTH=$(echo ${PLUGINS} | /usr/bin/jq 'length')
LAST_INDEX=$((LENGTH-1))

for I in `seq 0 $LAST_INDEX`; do
  PLUGIN=$(echo $PLUGINS | /usr/bin/jq -r ".[$I]" )
  sensu-install -v $PROXY_OPTION -p $PLUGIN
done

# Enable Sensu Client service on boot
systemctl enable sensu-client.service
