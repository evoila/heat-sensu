#!/bin/bash

BIND_PORT=${BIND_PORT:-3000}
SITES=${SITES:-[]}

# Write header

cat <<EOF > /etc/sensu/uchiwa.json
{
  "sensu": [
EOF

BLOCKS=$(echo $SITES | sed 's/\[//' | sed 's/\]//' | sed 's/"//g' | sed 's/,//')

for BLOCK in $BLOCKS; do

  SITE=$(echo $BLOCK | cut -d ';' -f1)
  HOST=$(echo $BLOCK | cut -d ';' -f2)
  PORT=$(echo $BLOCK | cut -d ';' -f3)

  cat <<EOF >> /etc/sensu/uchiwa.json
    {
      "name": "$SITE",
      "host": "$HOST",
      "port": $PORT,
      "timeout": 10
    },
EOF

done

sed -i '$ s/,$//' /etc/sensu/uchiwa.json

cat <<EOF >> /etc/sensu/uchiwa.json
  ],
  "uchiwa": {
    "host": "0.0.0.0",
    "port": $BIND_PORT,
    "refresh": 10
  }
}
EOF

service uchiwa restart
