#!/usr/bin/env bash

GREEN='\033[1;32m'
BLUE='\033[0;34m'
RED='\033[1;31m'
NC='\033[0m'

VAULT_PROJECT='be-pnu-dev-vault'
VAULT_USER='vault-user'

if [ -z "$1" ]; then
    echo 'Usage: build.sh <environment>'
    echo '    <environment> should be one of the following: '
    echo '        wccl-lab1 : Leuven LAB'
    echo '        wccl-tda1 : Leuven TDA'
    echo '        wccl-pro1 : Leuven PRO'
    echo '        wccm-tda1 : Mechelen LAB'
    echo '        wccm-pro1 : Mechelen PRO'
    exit 0
else
    export CLUSTER=$1
    echo -e "${GREEN}Going to deploy in cluster ${CLUSTER}.${NC}"
fi

if ! oc config current-context | grep ${CLUSTER} &>/dev/null; then
    echo -e "${RED}Not in the proper oc context for cluster ${CLUSTER}. Please switch to the correct context.${NC}"
    exit
fi

if ! oc get projects &>/dev/null; then
    echo -e "${RED}Not logged in to cluster ${CLUSTER}. Please login first...${NC}"
    exit
fi

if ! oc get project ${VAULT_PROJECT} &>/dev/null; then
    echo -e "${GREEN}Creating project ${VAULT_PROJECT}.${NC}"
    oc new-project ${VAULT_PROJECT} --display-name="HashiCorp Vault"
else
    oc project ${VAULT_PROJECT}
fi

read -p "$(echo -e ${BLUE}Do you first want to push new images to ${VAULT_PROJECT} in OpenShift Docker Registry [yY/nN]? ${NC})" choice

case "$choice" in
  y|Y ) ./docker-build.sh ${CLUSTER} ;;
  * ) echo "Proceeding with existing images in OpenShift Docker Registry";;
esac


echo -e "${GREEN}Going to deploy/update HashiCorp Consul stack.${NC}"
mkdir -p output-${CLUSTER}
export CONSUL_ENCRYPTION_KEY=`consul keygen`
export CONSUL_NAMESPACE=${VAULT_PROJECT}
echo ${CONSUL_ENCRYPTION_KEY} > output-${CLUSTER}/.consul-encryption-key
envsubst <deploy-templates/hashicorp-route.yaml >output-${CLUSTER}/hashicorp-route.yaml
envsubst <deploy-templates/hashicorp-consul-configmap.yaml >output-${CLUSTER}/hashicorp-consul-configmap.yaml
oc apply -f output-${CLUSTER}/hashicorp-consul-configmap.yaml
oc apply -f output-${CLUSTER}/hashicorp-route.yaml
oc apply -f hashicorp-networkpolicy.yaml
oc apply -f hashicorp-service.yaml
oc apply -f hashicorp-statefulset.yaml

./bootstrap-consul.sh ${CLUSTER}

echo -e "${GREEN}Going to deploy/update HashiCorp Vault stack.${NC}"
export CONSUL_MASTER_TOKEN=`cat output-${CLUSTER}/.consul-master-token`
export VAULT_POD_IP="\${VAULT_POD_IP}" # We need envsubst at runtime!!!
envsubst <deploy-templates/hashicorp-vault-configmap.yaml >output-${CLUSTER}/hashicorp-vault-configmap.yaml
oc apply -f output-${CLUSTER}/hashicorp-vault-configmap.yaml
oc apply -f hashicorp-sa.yaml
oc apply -f hashicorp-scc.yaml
oc apply -f hashicorp-deployment.yaml

./bootstrap-vault.sh ${CLUSTER}

echo -e "${GREEN}Deployment finished successfully.${NC}"
