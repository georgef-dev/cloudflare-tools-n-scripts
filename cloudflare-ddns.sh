#!/bin/bash

# Simple Bash script to mimic a dynamic DNS provider via Cloudflare
# The script expects the DNS record to exist in Cloudflare
# 
# The script expects 2 environment variables:
#
# CLOUDFLARE_AUTH_EMAIL = Your account email.
# CLOUDFLARE_AUTH_KEY = API Key provided by Cloudflare. You can use the one available in the main dashbaord.
#export https_proxy=http://<proxyuser>:<proxypassword>@<proxyip>:<proxyport>

if [[ $# -ne 2 ]]; then
  echo "Usage: ${0} CLOUDFLARE_DNS_ZONE CLOUDFLARE_DNS_RECORD"
  echo ;
  echo "CLOUDFLARE_DNS_ZONE: zone name (e.g. your domain)."
  echo "CLOUDFLARE_DNS_RECORD: DNS (type A) record to be updated."
  exit 1;
fi

CLOUDFLARE_ZONE=$1
CLOUDFLARE_DNS_RECORD=$2

# Get the current external IP address
CURRENT_IP=$(curl -s -X GET https://checkip.amazonaws.com)

echo "Current IP is ${CURRENT_IP}"

if host "${CLOUDFLARE_DNS_RECORD}" 1.1.1.1 | grep "has address" | grep "${CURRENT_IP}"; then
  echo "${CLOUDFLARE_DNS_RECORD} is already set to ${CURRENT_IP}; Graciously exiting."
  exit 0;
fi

# if here, the dns record needs updating

# get the zone id for the requested zone
CLOUDFLARE_ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${CLOUDFLARE_ZONE}&status=active" \
  -H "X-Auth-Email: ${CLOUDFLARE_AUTH_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_AUTH_KEY}" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

echo "Zoneid for ${CLOUDFLARE_ZONE} is ${CLOUDFLARE_ZONE_ID}"

# get the dns record id
DNS_RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records?type=A&name=${CLOUDFLARE_DNS_RECORD}" \
  -H "X-Auth-Email: ${CLOUDFLARE_AUTH_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_AUTH_KEY}" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

echo "DNSrecordid for ${CLOUDFLARE_DNS_RECORD} is ${DNS_RECORD_ID}"

# update the record
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records/${DNS_RECORD_ID}" \
  -H "X-Auth-Email: ${CLOUDFLARE_AUTH_EMAIL}" \
  -H "X-Auth-Key: ${CLOUDFLARE_AUTH_KEY}" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"${CLOUDFLARE_DNS_RECORD}\",\"content\":\"${CURRENT_IP}\",\"ttl\":1,\"proxied\":false}" | jq