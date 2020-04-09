#!/usr/bin/env bash

# set -x

GREEN='\033[1;32m'
BLUE='\033[0;34m'
RED='\033[1;31m'
NC='\033[0m'

EXECUTE="oc exec -it consul-0 -- "
EXECUTE_BOOTSTRAP="${EXECUTE} curl --request PUT http://localhost:8500/v1/acl/bootstrap "
EXECUTE_ACL_CREATE="${EXECUTE} curl --request PUT http://localhost:8500/v1/acl/create "
EXECUTE_ACL_UPDATE="${EXECUTE} curl --request PUT http://localhost:8500/v1/acl/update "

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
    echo -e "${GREEN}Going to bootstrap Consul in cluster ${CLUSTER}.${NC}"
fi

echo -e "${GREEN}Checking/waiting for consul-2 readiness${NC}"
while ! oc get pods consul-2 &>/dev/null; do
    echo -n "."
    sleep 1
done
while ! oc get pods consul-2 | grep Running | grep 1/1 &>/dev/null; do
    echo -n "."
    sleep 1
done
echo

BOOTSTRAP_RES=`${EXECUTE_BOOTSTRAP}`

while ! echo ${BOOTSTRAP_RES} | grep ID &>/dev/null; do

    if [[ "${BOOTSTRAP_RES}" =~ "ACL bootstrap no longer allowed" ]]; then
        echo -e "${RED}Bootstrapping already done: ${BOOTSTRAP_RES}${NC}"
        exit 1
    elif [[ "${BOOTSTRAP_RES}" =~ "No cluster leader" ]]; then
        echo "Waiting for cluster leader election to finish"
        sleep 5
    elif [[ "${BOOTSTRAP_RES}" =~ "rpc error getting client" ]]; then
        echo "Waiting for RPC readiness to finish"
        sleep 5
    else
        echo -e "${RED}Unexpected response: ${BOOTSTRAP_RES}${NC}"
        sleep 2
    fi

    BOOTSTRAP_RES=`${EXECUTE_BOOTSTRAP}`
done

ACL_MASTER_TOKEN=`echo ${BOOTSTRAP_RES} | jq '.ID' | tr -d '"'`
echo -e "${GREEN}New Consul Master Token: ${ACL_MASTER_TOKEN}${NC}"
echo ${ACL_MASTER_TOKEN} > output-${CLUSTER}/.consul-master-token

echo -e "${GREEN}Going to add/update Consul ACLs for Vault integration${NC}"
oc cp consul-acl/vault-token.json be-pnu-dev-vault/consul-0:/tmp/vault-token.json
oc cp consul-acl/anonymous-token.json be-pnu-dev-vault/consul-0:/tmp/anonymous-token.json
${EXECUTE_ACL_CREATE} --header "X-Consul-Token: ${ACL_MASTER_TOKEN}" --data @/tmp/vault-token.json &>/dev/null
${EXECUTE_ACL_UPDATE} --header "X-Consul-Token: ${ACL_MASTER_TOKEN}" --data @/tmp/anonymous-token.json &>/dev/null

echo -e "${GREEN}Bootstrapping of Consul cluster finished${NC}"

