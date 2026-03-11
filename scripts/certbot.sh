#!/usr/bin/env bash
# =============================================================================
# certbot.sh — Obtain/renew a Let's Encrypt certificate on a VM via SSH
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

SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=15"
[ -n "${SSH_KEY}" ] && SSH_OPTS="${SSH_OPTS} -i ${SSH_KEY}"

echo "[certbot] Requesting Let's Encrypt certificate for ${FQDN} on ${IP}..."

# shellcheck disable=SC2086
ssh ${SSH_OPTS} "${SSH_USER}@${IP}" \
  "sudo certbot --nginx \
    -d '${FQDN}' \
    --non-interactive \
    --agree-tos \
    --email '${EMAIL}' \
    --redirect \
    --no-eff-email \
  && sudo systemctl enable certbot.timer 2>/dev/null \
  && echo '[certbot] Auto-renewal enabled ✓' \
  || echo '[certbot] WARN: certbot.timer not found — using cron /etc/cron.d/certbot'"  

echo "[certbot] Let's Encrypt certificate active for ${FQDN} ✓"
