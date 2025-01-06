FROM docker.io/library/alpine:3.21

ARG SQUID_VERSION=6.12-r0
ARG SQUID_PROXY_PORT=3128
ARG SQUID_PROXY_SSL_PORT=3129

ENV CERT_CN=squid.local \
    CERT_COUNTRY=US \
    CERT_STATE=AZ \
    CERT_CITY="Black Mesa" \
    CERT_ORG="Anomalous Materials" \
    CERT_OU="Lambda Complex"

RUN mkdir -p /etc/squid-cert /var/cache/squid /var/log/squid /var/spool/squid && \
    apk add --no-cache \
        squid=${SQUID_VERSION} \
        openssl \
        catatonit \
        ca-certificates && \
    update-ca-certificates && \
    rm -rf /etc/squid/squid.conf && \
    chown -R squid:squid /etc/squid-cert /var/cache/squid/ /var/log/squid/ /var/spool/squid

COPY openssl.conf /etc/ssl/openssl.conf
COPY apps/squid/entrypoint.sh /entrypoint.sh

EXPOSE ${SQUID_PROXY_PORT} ${SQUID_PROXY_SSL_PORT}

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
