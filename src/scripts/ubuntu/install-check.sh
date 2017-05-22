#!/bin/bash

NAME=${NAME}
COMMAND=${COMMAND}
SUBSCRIBERS=${SUBSCRIBERS}
STANDALONE=${STANDALONE}
INTERVAL=${INTERVAL}
RESTART_SERVICES=${RESTART_SERVICES:-'["server", "client"]'}

# Setup environment variables for use in command evaluation
PRIMARY_NIC=$(route -n | grep -E "^0.0.0.0" | awk '{print $8}')
PRIMARY_ADDR=$(ip addr show dev $PRIMARY_NIC | grep -E "inet " | awk '{print $2}' | cut -d '/' -f1)

# Evaluate command string
CMD=$( eval echo $COMMAND )

FILE="/etc/sensu/conf.d/check-$NAME.json"
cat <<EOF > $FILE
{
  "checks": {
    "$NAME": {
      "command": "${CMD}",
      "subscribers": ${SUBSCRIBERS},
      "interval": ${INTERVAL},
      "standalone": $(echo $STANDALONE | tr '[:upper:]' '[:lower:]')
    }
  }
}
EOF

# Restart services
LENGTH=$(echo ${RESTART_SERVICES} | jq 'length')
LAST_INDEX=$((LENGTH-1))

for I in `seq 0 $LAST_INDEX`; do
  SERVICE=$(echo $RESTART_SERVICES | jq -r ".[$I]" )
  service sensu-$SERVICE restart
done
