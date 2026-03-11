#!/usr/bin/env bash
# =============================================================================
# set-dns.sh — Assigner un label DNS à l'IP publique Azure d'une VM
#
# Usage : set-dns.sh <ip> [dns_label]
#
#   <ip>         Adresse IP publique de la VM
#   [dns_label]  Label DNS souhaité (défaut: vivo-<ip-avec-tirets>)
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

[ -n "${PIP_NAME}" ] || { echo "ERROR: aucune IP publique trouvée pour ${IP}"; exit 1; }

[ -z "${DNS_LABEL}" ] && DNS_LABEL="vivo-$(echo "${IP}" | tr '.' '-')"

echo "IP publique : ${PIP_NAME}  [${PIP_RG}]"
echo "Label DNS   : ${DNS_LABEL}"

az network public-ip update \
  --resource-group "${PIP_RG}" \
  --name "${PIP_NAME}" \
  --dns-name "${DNS_LABEL}" --output none

FQDN=$(az network public-ip show \
  --resource-group "${PIP_RG}" --name "${PIP_NAME}" \
  --query "dnsSettings.fqdn" -o tsv)

echo "FQDN        : ${FQDN}"
