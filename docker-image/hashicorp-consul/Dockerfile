FROM alpine:3.6
MAINTAINER Bart Van Bos <bart.vanbos@kbc.be>

# This is the release of Vault to pull in.
ARG CONSUL_VERSION
LABEL version="${CONSUL_VERSION}"
LABEL description="HashiCorp Consul image for secure HA storage of vault secrets"
LABEL source-repo="https://agit.kbc.be:6088/scm/osinf/openshift-vault.git"

# This is the location of the releases.
ENV HASHICORP_RELEASES="https://releases.hashicorp.com"

# Set up certificates, base tools, and Consul.
RUN apk add --update --no-cache ca-certificates curl dumb-init gnupg libcap openssl su-exec jq gettext && \
    gpg --keyserver pgp.mit.edu --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
    wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS && \
    wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify consul_${CONSUL_VERSION}_SHA256SUMS.sig consul_${CONSUL_VERSION}_SHA256SUMS && \
    grep consul_${CONSUL_VERSION}_linux_amd64.zip consul_${CONSUL_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin consul_${CONSUL_VERSION}_linux_amd64.zip && \
    cd /tmp && \
    rm -rf /tmp/build && \
    apk del gnupg openssl && \
    rm -rf /root/.gnupg

# Add entrypoint script to do ENV variable substitution in config file
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY ready-check.sh /ready-check.sh
COPY health-check.sh /health-check.sh

# The /consul/data dir is used by Consul to store state. The agent will be started
# with /consul/config as the configuration directory so you can add additional
# config files in that location.
RUN mkdir -p /consul/data && \
    mkdir -p /consul/config && \
    chmod -R ag+w /consul /docker-entrypoint.sh /ready-check.sh /health-check.sh

# Expose the consul data directory as a volume since there's mutable state in there.
VOLUME /consul/data

# Server RPC is used for communication between Consul clients and servers for internal
# request forwarding.
EXPOSE 8300

# Serf LAN and WAN (WAN is used only by Consul servers) are used for gossip between
# Consul agents. LAN is within the datacenter and WAN is between just the Consul
# servers in all datacenters.
EXPOSE 8301 8301/udp 8302 8302/udp

# HTTP and DNS (both TCP and UDP) are the primary interfaces that applications
# use to interact with Consul.
EXPOSE 8500 8600 8600/udp
