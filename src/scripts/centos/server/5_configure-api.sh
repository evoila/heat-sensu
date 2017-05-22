#!/bin/bash

BIND_PORT=${BIND_PORT:-4567}

PRIMARY_NIC=$(route -n | grep -E "^0.0.0.0" | awk '{print $8}')
PRIMARY_ADDR=$(ip addr show dev $PRIMARY_NIC | grep -E "inet " | awk '{print $2}' | cut -d '/' -f1)

cat <<EOF > /etc/sensu/conf.d/api.json
{
  "api": {
    "host": "$PRIMARY_ADDR",
    "bind": "0.0.0.0",
    "port": $BIND_PORT
  }
}
EOF

service sensu-api restart
