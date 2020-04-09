#!/usr/bin/env bash

# set -x

GREEN='\033[1;32m'
BLUE='\033[0;34m'
RED='\033[1;31m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo 'Usage: bootstrap.sh <environment>'
    echo '    <environment> should be one of the following: '
    echo '        wccl-lab1 : Leuven LAB'
    echo '        wccl-tda1 : Leuven TDA'
    echo '        wccl-pro1 : Leuven PRO'
    echo '        wccm-tda1 : Mechelen LAB'
    echo '        wccm-pro1 : Mechelen PRO'
    exit 0
else
    export CLUSTER=$1
    echo -e "${GREEN}Going to bootstrap Vault in cluster ${CLUSTER}.${NC}"
fi

echo -e "${GREEN}Checking/waiting for last Vault POD readiness${NC}"
VAULT_POD_1=`oc get pods --selector=component=vault -o jsonpath='{.items[0].metadata.name}'`
while ! oc get pods ${VAULT_POD_1} | grep Running | grep 1/1 &>/dev/null; do
    echo -n "."
    sleep 1
done

VAULT_POD_2=`oc get pods --selector=component=vault -o jsonpath='{.items[1].metadata.name}'`
while ! oc get pods ${VAULT_POD_2} | grep Running | grep 1/1 &>/dev/null; do
    echo -n "."
    sleep 1
done

VAULT_POD_3=`oc get pods --selector=component=vault -o jsonpath='{.items[2].metadata.name}'`
while ! oc get pods ${VAULT_POD_3} | grep Running | grep 1/1 &>/dev/null; do
    echo -n "."
    sleep 1
done
echo

echo -e "${GREEN}Going to initialize vault POD instance ${VAULT_POD_1}${NC}"
EXECUTE_INIT="oc exec -it ${VAULT_POD_1} -- vault init"
INIT_RES=`${EXECUTE_INIT} 2>&1`

VAULT_UNSEAL_KEY_1=`echo "${INIT_RES}" | sed -n -e "s/Unseal Key 1: //p" 2>/dev/null`
VAULT_UNSEAL_KEY_2=`echo "${INIT_RES}" | sed -n -e "s/Unseal Key 2: //p" 2>/dev/null`
VAULT_UNSEAL_KEY_3=`echo "${INIT_RES}" | sed -n -e "s/Unseal Key 3: //p" 2>/dev/null`
VAULT_UNSEAL_KEY_4=`echo "${INIT_RES}" | sed -n -e "s/Unseal Key 4: //p" 2>/dev/null`
VAULT_UNSEAL_KEY_5=`echo "${INIT_RES}" | sed -n -e "s/Unseal Key 5: //p" 2>/dev/null`
VAULT_ROOT_TOKEN=`echo "${INIT_RES}" | sed -n -e "s/Initial Root Token: //p" 2>/dev/null`

echo -e "${GREEN}New Vault Root Token: ${VAULT_ROOT_TOKEN}${NC}"

echo ${VAULT_UNSEAL_KEY_1} > output-${CLUSTER}/.vault-unseal-keys
echo ${VAULT_UNSEAL_KEY_2} >> output-${CLUSTER}/.vault-unseal-keys
echo ${VAULT_UNSEAL_KEY_3} >> output-${CLUSTER}/.vault-unseal-keys
echo ${VAULT_UNSEAL_KEY_4} >> output-${CLUSTER}/.vault-unseal-keys
echo ${VAULT_UNSEAL_KEY_5} >> output-${CLUSTER}/.vault-unseal-keys
echo ${VAULT_ROOT_TOKEN} > output-${CLUSTER}/.vault-root-token

echo -e "${GREEN}Going to unseal the Vault instances${NC}"
EXECUTE_UNSEAL_1="oc exec -it ${VAULT_POD_1} -- vault unseal "
EXECUTE_UNSEAL_2="oc exec -it ${VAULT_POD_2} -- vault unseal "
EXECUTE_UNSEAL_3="oc exec -it ${VAULT_POD_3} -- vault unseal "

UNSEAL_RES=`${EXECUTE_UNSEAL_1} ${VAULT_UNSEAL_KEY_1}`
UNSEAL_RES=`${EXECUTE_UNSEAL_1} ${VAULT_UNSEAL_KEY_2}`
UNSEAL_RES=`${EXECUTE_UNSEAL_1} ${VAULT_UNSEAL_KEY_3}`
UNSEAL_RES=`${EXECUTE_UNSEAL_1} ${VAULT_UNSEAL_KEY_4}`

if echo ${UNSEAL_RES} | grep "Vault is already unsealed." &>/dev/null; then
    echo -e "Unsealing of Vault on ${VAULT_POD_1} ${GREEN}DONE${NC}"
fi

UNSEAL_RES=`${EXECUTE_UNSEAL_2} ${VAULT_UNSEAL_KEY_1}`
UNSEAL_RES=`${EXECUTE_UNSEAL_2} ${VAULT_UNSEAL_KEY_2}`
UNSEAL_RES=`${EXECUTE_UNSEAL_2} ${VAULT_UNSEAL_KEY_3}`
UNSEAL_RES=`${EXECUTE_UNSEAL_2} ${VAULT_UNSEAL_KEY_4}`

if echo ${UNSEAL_RES} | grep "Vault is already unsealed." &>/dev/null; then
    echo -e "Unsealing of Vault on ${VAULT_POD_2} ${GREEN}DONE${NC}"
fi

UNSEAL_RES=`${EXECUTE_UNSEAL_3} ${VAULT_UNSEAL_KEY_1}`
UNSEAL_RES=`${EXECUTE_UNSEAL_3} ${VAULT_UNSEAL_KEY_2}`
UNSEAL_RES=`${EXECUTE_UNSEAL_3} ${VAULT_UNSEAL_KEY_3}`
UNSEAL_RES=`${EXECUTE_UNSEAL_3} ${VAULT_UNSEAL_KEY_4}`

if echo ${UNSEAL_RES} | grep "Vault is already unsealed." &>/dev/null; then
    echo -e "Unsealing of Vault on ${VAULT_POD_3} ${GREEN}DONE${NC}"
fi

echo -e "${GREEN}Bootstrapping of Vault cluster finished${NC}"

