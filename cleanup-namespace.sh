#!/usr/bin/env bash

#
# Small helper script to clean a namespace. Use with caution!
#

VAULT_PROJECT="be-pnu-dev-vault"
BLUE='\033[0;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

function clean-all {
    kubectl delete --all --now=true statefulset -n $1 &
    kubectl delete --all --now=true deployment -n $1 &
    kubectl delete --all --now=true pods -n $1
    kubectl delete --all --now=true route -n $1
    kubectl delete --all --now=true networkpolicy -n $1
    kubectl delete --all --now=true service -n $1
    kubectl delete --all --now=true replicaset -n $1
    kubectl delete --all --now=true configmap -n $1
    oc delete project --force=true --now=true $1
}

oc project ${VAULT_PROJECT}
PROJECT=$(oc project -q)

if [ "$PROJECT" != ${VAULT_PROJECT} ]; then
  echo "${RED}Project '$PROJECT' is not a Vault related project! Quitting...${NC}"
  exit
fi

read -p "$(echo -e ${BLUE}Going to clean project ${VAULT_PROJECT}, are you sure [yY/nN]? ${NC})" choice

case "$choice" in
  y|Y ) clean-all ${VAULT_PROJECT};;
  n|N ) exit;;
  * ) exit;;
esac

while true; do
    if ! oc get project ${VAULT_PROJECT} &>/dev/null; then break; fi
done

echo -e "${GREEN}Successfully cleaned up project ${VAULT_PROJECT}${NC}"
