#!/usr/bin/env bash

# cfr https://hub.docker.com/r/library/vault/tags
export UPSTREAM_IMAGE_VAULT="vault"
export UPSTREAM_TAG_VAULT="0.9.1"
export IMAGE_VAULT="be-pnu-dev-vault/vault"
export TAG_VAULT="0.9.1.0"

# cfr https://hub.docker.com/r/library/consul/tags
export UPSTREAM_IMAGE_CONSUL="consul"
export UPSTREAM_TAG_CONSUL="1.0.2"
export IMAGE_CONSUL="be-pnu-dev-vault/consul"
export TAG_CONSUL="1.0.2.0"

# cfr https://hub.docker.com/r/djenriquez/vault-ui/tags
export UPSTREAM_IMAGE_VAULT_UI="boeboe/vault-ui"
export UPSTREAM_TAG_VAULT_UI="2.4.0-rc4"
export IMAGE_VAULT_UI="be-pnu-dev-vault/vault-ui"
export TAG_VAULT_UI="2.4.0.0"

