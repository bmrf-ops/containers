#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/squid-cache/squid/releases/latest" | jq --raw-output '.tag_name' | sed 's/SQUID_//' | tr '_' '.' 2>/dev/null)
printf "%s" "${version}"
