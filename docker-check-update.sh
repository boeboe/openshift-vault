#!/usr/bin/env bash

source versions.sh

GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${GREEN}Checking for new versions of vault${NC}"
curl -s "https://registry.hub.docker.com/v2/repositories/library/${UPSTREAM_IMAGE_VAULT}/tags/" | tr ',' $'\n' | grep name | sed 's/^.*"name": //' | grep --color=auto -E "${UPSTREAM_TAG_VAULT}|$"

echo -e "${GREEN}Checking for new versions of vault ui${NC}"
curl -s "https://registry.hub.docker.com/v2/repositories/${UPSTREAM_IMAGE_VAULT_UI}/tags/" | tr ',' $'\n' | grep name | sed 's/^.*"name": //' | grep --color=auto -E "${UPSTREAM_TAG_VAULT_UI}|$"
