#!/usr/bin/env sh
set -e

# Directories
SQUID_CONFIG_DIR=/etc/squid
SQUID_CERT_DIR=/etc/squid-cert
SQUID_CACHE_DIR=/var/cache/squid
SQUID_LOG_DIR=/var/log/squid
SQUID_SPOOL_DIR=/var/spool/squid
SQUID_CONFIG_FILE=${SQUID_CONFIG_DIR}/squid.conf

create_cert() {
    if [ ! -f ${SQUID_CERT_DIR}/private.pem ]; then
        echo "Creating SSL certificates..."
        mkdir -p ${SQUID_CERT_DIR}
        openssl req -new -newkey rsa:4096 -sha512 -days 3650 -nodes -x509 \
            -extensions v3_ca -keyout ${SQUID_CERT_DIR}/private.pem \
            -out ${SQUID_CERT_DIR}/private.pem \
            -subj "/CN=${CERT_CN}/O=${CERT_ORG}/OU=${CERT_OU}/C=${CERT_COUNTRY}" \
            -utf8 -nameopt multiline,utf8

        openssl x509 -in ${SQUID_CERT_DIR}/private.pem -outform DER -out ${SQUID_CERT_DIR}/CA.der
        openssl x509 -inform DER -in ${SQUID_CERT_DIR}/CA.der -out ${SQUID_CERT_DIR}/CA.pem
    fi
}

init_ssl_db() {
    rm -rf /var/lib/ssl_db/*
    /usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB
    chown -R squid:squid /var/lib/ssl_db
}

init_cache() {
    squid -z
}

# Create directories and set permissions
# mkdir -p ${SQUID_CONFIG_DIR} ${SQUID_CERT_DIR} ${SQUID_CACHE_DIR} ${SQUID_LOG_DIR}
# chown -R squid:squid ${SQUID_CONFIG_DIR} ${SQUID_CERT_DIR} ${SQUID_CACHE_DIR} ${SQUID_LOG_DIR} ${SQUID_SPOOL_DIR}

create_cert
init_ssl_db
init_cache
rm -f /var/run/squid.pid >/dev/null 2>&1 || true

exec \
  squid -NYCd 1 -f ${SQUID_CONFIG_FILE} \
  "$@"
