FROM alpine:3.6
MAINTAINER Bart Van Bos <bart.vanbos@kbc.be>

# This is the release of Vault to pull in.
ARG VAULT_VERSION
LABEL version="${VAULT_VERSION}"
LABEL description="HashiCorp Vault image for secure storage of secrets"
LABEL source-repo="https://agit.kbc.be:6088/scm/osinf/openshift-vault.git"

# This is the location of the releases.
ENV HASHICORP_RELEASES="https://releases.hashicorp.com"

# Set up certificates, our base tools, and Vault.
RUN apk add --update --no-cache ca-certificates gnupg openssl libcap su-exec dumb-init curl jq gettext && \
    gpg --keyserver pgp.mit.edu --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    wget ${HASHICORP_RELEASES}/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    wget ${HASHICORP_RELEASES}/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS && \
    wget ${HASHICORP_RELEASES}/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify vault_${VAULT_VERSION}_SHA256SUMS.sig vault_${VAULT_VERSION}_SHA256SUMS && \
    grep vault_${VAULT_VERSION}_linux_amd64.zip vault_${VAULT_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin vault_${VAULT_VERSION}_linux_amd64.zip && \
    cd /tmp && \
    rm -rf /tmp/build && \
    apk del gnupg openssl && \
    rm -rf /root/.gnupg

# Add entrypoint script to do ENV variable substitution in config file
COPY docker-entrypoint.sh /docker-entrypoint.sh

# /vault/logs is made available to use as a location to store audit logs, if
# desired; /vault/file is made available to use as a location with the file
# storage backend, if desired; the server will be started with /vault/config as
# the configuration directory so you can add additional config files in that
# location.
RUN mkdir -p /vault/logs && \
    mkdir -p /vault/config && \
    touch /.vault-token && \
    chmod -R ag+w /vault /.vault-token /docker-entrypoint.sh

# Set IPC_LOCK to avoid vault data to get swapped out of memory on host system
RUN setcap cap_ipc_lock=+ep /bin/vault

# 8200/tcp is the primary interface that applications use to interact with
# Vault.
EXPOSE 8200

