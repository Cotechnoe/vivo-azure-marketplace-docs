#!/usr/bin/env bash
# =============================================================================
# certbot.sh — Obtenir/renouveler un certificat Let's Encrypt via SSH sur une VM
#
# Usage : certbot.sh <ip> <fqdn> <email> [ssh_user] [ssh_key]
#
#   <ip>        Adresse IP publique de la VM
#   <fqdn>      Nom de domaine complet (ex: vivo-01.canadacentral.cloudapp.azure.com)
#   <email>     Adresse e-mail pour les notifications Let's Encrypt
#   [ssh_user]  Utilisateur SSH (défaut: azureuser)
#   [ssh_key]   Chemin vers la clé privée SSH (optionnel)
# =============================================================================
set -euo pipefail

IP="${1:?Usage: certbot.sh <ip> <fqdn> <email> [ssh_user] [ssh_key]}"
FQDN="${2:?Usage: certbot.sh <ip> <fqdn> <email> [ssh_user] [ssh_key]}"
EMAIL="${3:?Usage: certbot.sh <ip> <fqdn> <email> [ssh_user] [ssh_key]}"
SSH_USER="${4:-azureuser}"
SSH_KEY="${5:-}"

SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=15"
[ -n "${SSH_KEY}" ] && SSH_OPTS="${SSH_OPTS} -i ${SSH_KEY}"

echo "[certbot] Demande certificat Let's Encrypt pour ${FQDN} sur ${IP}..."

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
  && echo '[certbot] Renouvellement automatique activé ✓' \
  || echo '[certbot] WARN: certbot.timer absent — cron /etc/cron.d/certbot utilisé'"

echo "[certbot] Certificat Let's Encrypt actif pour ${FQDN} ✓"
