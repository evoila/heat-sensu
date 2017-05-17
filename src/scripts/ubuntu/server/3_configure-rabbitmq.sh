#!/bin/bash

ADDRESSES=${ADDRESSES}
VHOST=${VHOST:-sensu}
PORT=${PORT:-5672}
USER=${USER:-sensu}
PASSWORD=${PASSWORD}

# Write header

cat <<EOF > /etc/sensu/conf.d/rabbitmq.json
{
  "rabbitmq": [
EOF

# Write rabbit nodes

LIST=$(echo $ADDRESSES | sed 's/\[//' | sed 's/\]//' | sed 's/"//g' | sed 's/,//g')

for ADDR in $LIST; do
  cat <<EOF >> /etc/sensu/conf.d/rabbitmq.json
    {
      "host": "$ADDR",
      "port": $PORT,
      "vhost": "$VHOST",
      "user": "$USER",
      "password": "$PASSWORD",
      "heartbeat": 30,
      "prefetch": 50
    },
EOF
done

# Remove trailing comma for valid JSON
 
sed -i '$ s/,$//' /etc/sensu/conf.d/rabbitmq.json

# Write footer

cat <<EOF >> /etc/sensu/conf.d/rabbitmq.json
  ]
}
EOF

service sensu-server restart
