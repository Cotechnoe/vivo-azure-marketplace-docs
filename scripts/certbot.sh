#!/usr/bin/env bash
# =============================================================================
# certbot.sh — Obtain/renew a Let's Encrypt certificate on a VM via SSH (v1.1.6)
#
# Copyright (c) 2026 Cotechnoe inc.
#
# Issues a TLS certificate via Certbot for the VIVO web interface served by
# Nginx. The VM must have a resolvable FQDN before running this script
# (see set-dns.sh).
#
# See: https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/HTTPS-TLS-Certificate
#
# Usage: certbot.sh <ip> <fqdn> <email> [ssh_user] [ssh_key]
#
#   <ip>        VM public IP address
#   <fqdn>      Fully qualified domain name (e.g. vivo-01.canadacentral.cloudapp.azure.com)
#   <email>     Email address for Let's Encrypt notifications
#   [ssh_user]  SSH user (default: azureuser)
#   [ssh_key]   Path to SSH private key (optional)
# =============================================================================
set -euo pipefail

IP="${1:?Usage: certbot.sh <ip> <fqdn> <email> [ssh_user] [ssh_key]}"
FQDN="${2:?Usage: certbot.sh <ip> <fqdn> <email> [ssh_user] [ssh_key]}"
EMAIL="${3:?Usage: certbot.sh <ip> <fqdn> <email> [ssh_user] [ssh_key]}"
SSH_USER="${4:-azureuser}"
SSH_KEY="${5:-}"

if ! command -v openssl >/dev/null 2>&1; then
  echo "[certbot] ERROR: openssl is required to verify the certificate served by the VM." >&2
  exit 2
fi

SSH_OPTS=(-o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 -o BatchMode=yes)
if [[ -n "${SSH_KEY}" ]]; then
  SSH_OPTS+=(-i "${SSH_KEY}")
fi

echo "[certbot] Requesting Let's Encrypt certificate for ${FQDN} on ${IP}..."

printf -v REMOTE_COMMAND 'FQDN=%q EMAIL=%q bash -s' "${FQDN}" "${EMAIL}"
ssh "${SSH_OPTS[@]}" "${SSH_USER}@${IP}" "${REMOTE_COMMAND}" <<'REMOTE_SCRIPT'
set -euo pipefail

sudo certbot --nginx \
  -d "${FQDN}" \
  --non-interactive \
  --agree-tos \
  --email "${EMAIL}" \
  --redirect \
  --no-eff-email

sudo nginx -t

if sudo systemctl cat certbot.timer >/dev/null 2>&1; then
  sudo systemctl enable --now certbot.timer
  sudo systemctl is-enabled --quiet certbot.timer
  sudo systemctl is-active --quiet certbot.timer
  echo "[certbot] Renewal timer is enabled and active."
elif sudo test -s /etc/cron.d/certbot; then
  echo "[certbot] WARN: timer unavailable; cron renewal file exists, but its execution was not verified." >&2
else
  echo "[certbot] ERROR: no Certbot renewal timer or cron file was found." >&2
  exit 1
fi
REMOTE_SCRIPT

echo "[certbot] Checking the certificate served for ${FQDN}..."
if ! openssl s_client \
  -connect "${IP}:443" \
  -servername "${FQDN}" \
  -verify 5 \
  -verify_hostname "${FQDN}" \
  -verify_return_error \
  -brief </dev/null; then
  echo "[certbot] ERROR: the certificate served by ${IP}:443 did not verify for ${FQDN}." >&2
  exit 1
fi

echo "[certbot] TLS certificate for ${FQDN} is served and verified ✓"
