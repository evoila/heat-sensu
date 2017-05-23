#!/bin/bash

ENVIRONMENT=${ENVIRONMENT:-production}
SUBSCRIPTIONS=${SUBSCRIPTIONS:-[]}
BIND_ADDR=${BIND_ADDR:-127.0.0.1}
BIND_PORT=${BIND_PORT:-3030}

PRIMARY_NIC=$(route -n | grep -E "^0.0.0.0" | awk '{print $8}')
PRIMARY_ADDR=$(ip addr show dev $PRIMARY_NIC | grep -E "inet " | awk '{print $2}' | cut -d '/' -f1)

HOSTNAME=$(hostname -s)

cat <<EOF > /etc/sensu/conf.d/client.json
{
  "client": {
    "name": "$HOSTNAME",
    "address": "$PRIMARY_ADDR",
    "environment": "$ENVIRONMENT",
    "subscriptions": $SUBSCRIPTIONS,
    "socket": {
      "bind": "$BIND_ADDR",
      "port": $BIND_PORT
    },
    "keepalive": {
      "thresholds": {
        "warning": 30,
        "critical": 40
      }
    }
  }
}
EOF

service sensu-client restart
