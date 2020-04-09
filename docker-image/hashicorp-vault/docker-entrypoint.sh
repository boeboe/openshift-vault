#!/usr/bin/dumb-init /bin/sh

set -e

VAULT_CONFIG_TEMPLATE_FILE="${VAULT_CONFIG_TEMPLATE_FILE:-/vault/template/vault.template.json}"
VAULT_CONFIG_FILE="${VAULT_CONFIG_FILE:-/vault/config/vault.json}"

if [ ! -f ${VAULT_CONFIG_TEMPLATE_FILE} ]; then
    echo "Could not find ${VAULT_CONFIG_TEMPLATE_FILE}"
    exit 1
else
    echo "Going to use ${VAULT_CONFIG_TEMPLATE_FILE} for ENV substitution"
    echo
    env
    echo
    echo
fi

envsubst <${VAULT_CONFIG_TEMPLATE_FILE} >${VAULT_CONFIG_FILE}

echo "Going to start vault with the following config file (${VAULT_CONFIG_FILE}):"
echo
cat ${VAULT_CONFIG_FILE} | sed 's/^/  /'
echo
echo

echo "$@"
exec "$@"