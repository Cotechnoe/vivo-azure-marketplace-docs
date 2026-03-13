#!/usr/bin/env bash
# =============================================================================
# set-dns.sh — Assign a DNS label to an Azure VM's public IP (v1.1.6)
#
# Copyright (c) 2026 Cotechnoe inc.
#
# Assigns a custom DNS label to the Azure Public IP resource associated with
# the VM, generating the FQDN required for TLS certificate provisioning.
#
# See: https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/HTTPS-TLS-Certificate
#
# Usage: set-dns.sh <ip> [dns_label]
#
#   <ip>         VM public IP address
#   [dns_label]  Desired DNS label (default: vivo-<ip-with-dashes>)
# =============================================================================
set -euo pipefail

IP="${1:?Usage: set-dns.sh <ip> [dns_label]}"
DNS_LABEL="${2:-}"

PIP_JSON=$(az network public-ip list \
  --query "[?ipAddress=='${IP}'].{name:name,rg:resourceGroup}" -o json)

PIP_NAME=$(echo "${PIP_JSON}" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d[0]['name'])" 2>/dev/null) || true
PIP_RG=$(echo "${PIP_JSON}" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d[0]['rg'])" 2>/dev/null) || true

[ -n "${PIP_NAME}" ] || { echo "ERROR: no public IP found for ${IP}"; exit 1; }

[ -z "${DNS_LABEL}" ] && DNS_LABEL="vivo-$(echo "${IP}" | tr '.' '-')"

echo "Public IP   : ${PIP_NAME}  [${PIP_RG}]"
echo "DNS label   : ${DNS_LABEL}"

az network public-ip update \
  --resource-group "${PIP_RG}" \
  --name "${PIP_NAME}" \
  --dns-name "${DNS_LABEL}" --output none

FQDN=$(az network public-ip show \
  --resource-group "${PIP_RG}" --name "${PIP_NAME}" \
  --query "dnsSettings.fqdn" -o tsv)

echo "FQDN        : ${FQDN}"
