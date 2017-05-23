#!/bin/bash

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

# Install Uchiwa
yum install -y uchiwa

# Enable the Uchiwa service on system boot
systemctl enable uchiwa.service
