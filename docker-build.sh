#!/usr/bin/env bash

source versions.sh

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
    CLUSTER=$1
    REGISTRY="docker-registry-default.ocp-apps.$1.intapp.eu"
fi

DZDO=$(which dzdo)
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

function docker-login {
    if ! oc config current-context | grep ${CLUSTER} &>/dev/null; then
        echo -e "${RED}Not logged in to cluster ${CLUSTER}. Please login first...${NC}"
        exit
    fi
    echo -e "${GREEN}Login to docker registry ${REGISTRY} ${NC}"
    TOKEN=`oc whoami -t`
    ${DZDO} docker login -p ${TOKEN} -u unused ${REGISTRY}
}

function push {
    echo -e "${GREEN}Going to pull, tag and push $1:$2 -> $3:$4 ${NC}"
	${DZDO} docker image pull $1:$2
	${DZDO} docker tag $1:$2 ${REGISTRY}/$3:$4
	${DZDO} docker tag $1:$2 ${REGISTRY}/$3:latest
	${DZDO} docker push ${REGISTRY}/$3:$4
	${DZDO} docker push ${REGISTRY}/$3:latest
}

function build-push {
    echo -e "${GREEN}Going to build, tag and push $1:$2 -> $3:$4 ${NC}"
	${DZDO} docker build --pull -t $1:$2 $5
	${DZDO} docker tag $1:$2 ${REGISTRY}/$3:$4
	${DZDO} docker tag $1:$2 ${REGISTRY}/$3:latest
	${DZDO} docker push ${REGISTRY}/$3:$4
	${DZDO} docker push ${REGISTRY}/$3:latest
}

docker-login

build-push ${UPSTREAM_IMAGE_VAULT} ${UPSTREAM_TAG_VAULT} ${IMAGE_VAULT} ${TAG_VAULT}  "--build-arg VAULT_VERSION=${UPSTREAM_TAG_VAULT} ./docker-image/hashicorp-vault/"
build-push ${UPSTREAM_IMAGE_CONSUL} ${UPSTREAM_TAG_CONSUL} ${IMAGE_CONSUL} ${TAG_CONSUL}  "--build-arg CONSUL_VERSION=${UPSTREAM_TAG_CONSUL} ./docker-image/hashicorp-consul/"
build-push ${UPSTREAM_IMAGE_VAULT_UI} ${UPSTREAM_TAG_VAULT_UI} ${IMAGE_VAULT_UI} ${TAG_VAULT_UI} ./docker-image/djenriquez-vault-ui/

echo -e "${GREEN}Docker image deployment finished successfully.${NC}"
