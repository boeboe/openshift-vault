#!/usr/bin/dumb-init /bin/sh

set -e

CONSUL_CONFIG_FILE="${CONSUL_CONFIG_FILE:-/consul/config/consul.json}"

echo "Going to start consul with the following config file (${CONSUL_CONFIG_FILE}):"
echo
cat ${CONSUL_CONFIG_FILE} | sed 's/^/  /'
echo
echo

echo "$@"
exec "$@"