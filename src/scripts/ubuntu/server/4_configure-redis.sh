#!/bin/bash

ADDRESSES=${ADDRESSES}
PORT=${PORT:-26379}
PASSWORD=${PASSWORD}
MASTER=${MASTER}

# Write header

cat <<EOF > /etc/sensu/conf.d/redis.json
{
  "redis": {
    "password": "$PASSWORD",
    "master": "$MASTER",
    "sentinels": [
EOF

# Write redis nodes

LIST=$(echo $ADDRESSES | sed 's/\[//' | sed 's/\]//' | sed 's/"//g' | sed 's/,//g')

for ADDR in $LIST; do
  cat <<EOF >> /etc/sensu/conf.d/redis.json
      {
        "host": "$ADDR",
        "port": $PORT
      },
EOF
done

# Remove trailing comma for valid JSON

sed -i '$ s/,$//' /etc/sensu/conf.d/redis.json

# Write footer

cat <<EOF >> /etc/sensu/conf.d/redis.json
    ]
  }
}
EOF

service sensu-server restart
