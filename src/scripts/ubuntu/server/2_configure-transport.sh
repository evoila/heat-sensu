#!/bin/bash

TRANSPORT_NAME=${TRANSPORT_TYPE:-rabbitmq}

cat <<EOF > /etc/sensu/conf.d/transport.json
{
  "transport": {
    "name": "$TRANSPORT_NAME",
    "reconnect_on_error": true
  }
}
EOF
