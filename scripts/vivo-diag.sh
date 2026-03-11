#!/usr/bin/env bash
# ================================================================
# vivo-diag.sh — Remote diagnostic script for a deployed VIVO VM
#
# Usage:
#   ./vivo-diag.sh <VM_IP> [SSH_USER] [SSH_KEY]
#   make diag IP=<VM_IP>
#
# The script connects to the VM via SSH and checks:
#   1. cloud-init status
#   2. first-boot completion marker
#   3. /etc/vivo/install.conf content
#   4. systemd service status (nginx, tomcat, solr)
#   5. Disk usage on /mnt/data
#   6. HTTP/HTTPS reachability (local curl from the VM)
#   7. TLS certificate expiry (openssl)
#   8. UFW firewall rules (ports 443/80/22/8983/8080)
#   9. Solr core vivocore ping
#  10. SPARQL endpoint probe (public query — no credentials required)
#  11. Java heap settings (TOMCAT_HEAP_MIN / TOMCAT_HEAP_MAX)
#  12. Recent error lines in first-boot and tomcat logs
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more checks failed
#   2 — SSH connection error or missing argument
# ================================================================
set -uo pipefail

# ── Colours ──────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ── Counters ─────────────────────────────────────────────────────
PASS=0
FAIL=0
WARN=0

ok()   { echo -e "${GREEN}  [OK]${NC}   $*"; PASS=$((PASS+1)); }
fail() { echo -e "${RED}  [FAIL]${NC} $*"; FAIL=$((FAIL+1)); }
warn() { echo -e "${YELLOW}  [WARN]${NC} $*"; WARN=$((WARN+1)); }
section() { echo -e "\n${BLUE}${BOLD}─── $* ───${NC}"; }

# ── Argument parsing ─────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <VM_IP> [SSH_USER] [SSH_KEY_PATH]" >&2
    echo "       make diag IP=<VM_IP>" >&2
    exit 2
fi

VM_IP="${1}"
SSH_USER="${2:-azureuser}"
SSH_KEY="${3:-}"

# Auto-discover SSH key: use SSH_KEY arg, then VM_SSH_KEY_NAME from config, then id_rsa/id_ed25519
if [[ -z "${SSH_KEY}" ]]; then
    # Try to source project config for VM_SSH_KEY_NAME
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_CONFIG="${SCRIPT_DIR}/../../env/generated/config.env"
    if [[ -f "${PROJECT_CONFIG}" ]]; then
        # shellcheck source=/dev/null
        source "${PROJECT_CONFIG}"
        SSH_KEY="${HOME}/.ssh/${VM_SSH_KEY_NAME:-}"
    fi
fi
# Fall back to default SSH key discovery
if [[ -z "${SSH_KEY}" || ! -f "${SSH_KEY}" ]]; then
    for candidate in "${HOME}/.ssh/id_ed25519" "${HOME}/.ssh/id_rsa"; do
        if [[ -f "${candidate}" ]]; then
            SSH_KEY="${candidate}"
            break
        fi
    done
fi
if [[ -z "${SSH_KEY}" || ! -f "${SSH_KEY}" ]]; then
    echo -e "${RED}[ERROR]${NC} SSH key not found. Pass it as 3rd argument or set VM_SSH_KEY_NAME." >&2
    exit 2
fi

chmod 600 "${SSH_KEY}"

# ── SSH wrapper: run a command block on the remote VM ────────────
remote() {
    ssh -i "${SSH_KEY}" \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=10 \
        -o BatchMode=yes \
        "${SSH_USER}@${VM_IP}" "$@" 2>/dev/null
}

# ── Verify SSH connectivity before running checks ────────────────
echo -e "\n${BOLD}VIVO Diagnostic — ${VM_IP}${NC}"
echo -e "SSH user : ${SSH_USER}"
echo -e "SSH key  : ${SSH_KEY}"
echo -e "Date     : $(date '+%Y-%m-%d %H:%M:%S')"
echo "════════════════════════════════════════════════════════"

if ! remote true 2>/dev/null; then
    echo -e "${RED}[ERROR]${NC} Cannot connect to ${SSH_USER}@${VM_IP} with key ${SSH_KEY}" >&2
    exit 2
fi

# ────────────────────────────────────────────────────────────────
# CHECK 1 — cloud-init status
# ────────────────────────────────────────────────────────────────
section "1. cloud-init"
CI_STATUS=$(remote cloud-init status 2>/dev/null || echo "unknown")
if echo "${CI_STATUS}" | grep -q "status: done"; then
    ok "cloud-init: ${CI_STATUS}"
elif echo "${CI_STATUS}" | grep -q "status: running"; then
    warn "cloud-init still running — VM may not be fully provisioned yet"
else
    fail "cloud-init status unexpected: ${CI_STATUS}"
fi

# ────────────────────────────────────────────────────────────────
# CHECK 2 — first-boot completion marker
# ────────────────────────────────────────────────────────────────
section "2. First-boot marker"
FB_MARKER=$(remote "test -f /etc/vivo/.first-boot-done && stat -c '%y' /etc/vivo/.first-boot-done || echo ABSENT")
if [[ "${FB_MARKER}" != "ABSENT" ]]; then
    ok "First-boot completed on: ${FB_MARKER%.*}"
else
    # Marker absent — check if the log confirms completion anyway
    LAST_FB=$(remote "sudo tail -10 /var/log/vivo-first-boot.log 2>/dev/null || echo '(log absent)'" || true)
    if echo "${LAST_FB}" | grep -qi 'premier boot.*terminé\|first.boot.*done\|terminé.*✓'; then
        warn "First-boot marker /etc/vivo/.first-boot-done absent but log confirms completion"
    else
        fail "First-boot marker /etc/vivo/.first-boot-done absent — boot may be incomplete"
    fi
    echo "    Last lines of first-boot log:"
    echo "${LAST_FB}" | sed 's/^/    /'
fi

# ────────────────────────────────────────────────────────────────
# CHECK 3 — /etc/vivo/install.conf
# ────────────────────────────────────────────────────────────────
section "3. Install configuration (/etc/vivo/install.conf)"
CONF=$(remote "sudo cat /etc/vivo/install.conf 2>/dev/null || echo ABSENT")
if [[ "${CONF}" == "ABSENT" ]]; then
    fail "/etc/vivo/install.conf not found"
else
    ok "/etc/vivo/install.conf present"
    echo "${CONF}" | grep -v '^\s*#' | grep -v '^\s*$' | sed 's/^/    /'
fi

# ────────────────────────────────────────────────────────────────
# CHECK 4 — systemd services
# ────────────────────────────────────────────────────────────────
section "4. Systemd services (nginx / tomcat / solr)"
for svc in nginx tomcat solr; do
    STATE=$(remote "systemctl is-active ${svc} 2>/dev/null || echo inactive")
    ENABLED=$(remote "systemctl is-enabled ${svc} 2>/dev/null || echo disabled")
    if [[ "${STATE}" == "active" ]]; then
        ok "${svc}: active / enabled=${ENABLED}"
    else
        fail "${svc}: ${STATE} / enabled=${ENABLED}"
    fi
done

# ────────────────────────────────────────────────────────────────
# CHECK 5 — Disk usage (/mnt/data)
# ────────────────────────────────────────────────────────────────
section "5. Disk usage (/mnt/data)"
DISK=$(remote "df -h /mnt/data 2>/dev/null | tail -1 || echo ABSENT")
if [[ "${DISK}" == "ABSENT" || -z "${DISK}" ]]; then
    warn "/mnt/data not found — data disk may not be mounted or path differs"
    # Fall back to root filesystem usage
    ROOT_DISK=$(remote "df -h / | tail -1")
    echo "    Root filesystem: ${ROOT_DISK}"
else
    USED_PCT=$(echo "${DISK}" | awk '{print $5}' | tr -d '%')
    if [[ -z "${USED_PCT}" || ! "${USED_PCT}" =~ ^[0-9]+$ ]]; then
        warn "Could not parse disk usage for /mnt/data: ${DISK}"
    else
        echo "    ${DISK}"
        if [[ "${USED_PCT}" -ge 90 ]]; then
            fail "Disk /mnt/data is ${USED_PCT}% full — critical"
        elif [[ "${USED_PCT}" -ge 75 ]]; then
            warn "Disk /mnt/data is ${USED_PCT}% full — monitor closely"
        else
            ok "Disk /mnt/data usage: ${USED_PCT}%"
        fi
    fi
fi

# ────────────────────────────────────────────────────────────────
# CHECK 6 — HTTP/HTTPS reachability (curl from the VM itself)
# ────────────────────────────────────────────────────────────────
section "6. HTTP/HTTPS reachability (local)"
HTTP_CODE=$(remote "curl -s -o /dev/null -w '%{http_code}' --max-redirs 0 http://localhost/ 2>/dev/null || echo ERR")
if [[ "${HTTP_CODE}" == "301" || "${HTTP_CODE}" == "302" ]]; then
    ok "HTTP port 80 redirects to HTTPS (${HTTP_CODE})"
else
    fail "HTTP port 80 unexpected response: ${HTTP_CODE}"
fi

HTTPS_CODE=$(remote "curl -sk -o /dev/null -w '%{http_code}' https://localhost/ 2>/dev/null || echo ERR")
if [[ "${HTTPS_CODE}" == "200" ]]; then
    ok "HTTPS port 443 returns HTTP ${HTTPS_CODE}"
elif [[ "${HTTPS_CODE}" == "302" ]]; then
    warn "HTTPS port 443 returns redirect (${HTTPS_CODE}) — VIVO may still be starting"
else
    fail "HTTPS port 443 unexpected response: ${HTTPS_CODE}"
fi

# ────────────────────────────────────────────────────────────────
# CHECK 7 — TLS certificate expiry
# ────────────────────────────────────────────────────────────────
section "7. TLS certificate"
CERT_EXPIRY=$(remote "echo '' | openssl s_client -connect localhost:443 2>/dev/null \
    | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2 || echo UNKNOWN")
if [[ "${CERT_EXPIRY}" == "UNKNOWN" ]]; then
    warn "Could not retrieve TLS certificate expiry"
else
    ok "TLS certificate expires: ${CERT_EXPIRY}"
fi

# ────────────────────────────────────────────────────────────────
# CHECK 8 — UFW firewall rules
# ────────────────────────────────────────────────────────────────
section "8. UFW firewall"
UFW_STATUS=$(remote "sudo ufw status 2>/dev/null || echo 'ufw unavailable'")
if echo "${UFW_STATUS}" | grep -q "Status: active"; then
    ok "UFW is active"
    # Verify that sensitive ports are DENY, not ALLOW
    for blocked_port in 8983 8080; do
        if echo "${UFW_STATUS}" | grep -E "${blocked_port}" | grep -q 'DENY'; then
            ok "Port ${blocked_port} is explicitly DENY in UFW"
        elif echo "${UFW_STATUS}" | grep -E "${blocked_port}" | grep -q 'ALLOW'; then
            fail "Port ${blocked_port} is ALLOW in UFW — must be blocked"
        else
            warn "Port ${blocked_port} has no explicit UFW rule — relying on default policy"
        fi
    done
else
    warn "UFW status: $(echo "${UFW_STATUS}" | head -1)"
fi

# ────────────────────────────────────────────────────────────────
# CHECK 9 — Solr vivocore ping (via docker exec or direct on VM)
# ────────────────────────────────────────────────────────────────
section "9. Solr vivocore ping"
SOLR_PING=$(remote "curl -s 'http://localhost:8983/solr/vivocore/admin/ping' 2>/dev/null \
    | grep -o '\"status\":\"[^\"]*\"' || echo '\"status\":\"unreachable\"'")
if echo "${SOLR_PING}" | grep -q '"status":"OK"'; then
    ok "Solr vivocore ping: OK"
else
    fail "Solr vivocore ping: ${SOLR_PING} (port 8983 blocked externally — this runs from inside the VM)"
fi

# ────────────────────────────────────────────────────────────────
# CHECK 10 — SPARQL endpoint probe (public, no credentials)
# ────────────────────────────────────────────────────────────────
section "10. SPARQL endpoint"
SPARQL_CODE=$(remote "curl -sk -o /dev/null -w '%{http_code}' -X POST https://localhost/api/sparqlQuery \
    --data-urlencode 'query=SELECT ?s WHERE { ?s a <http://www.w3.org/2002/07/owl#Class> } LIMIT 1' \
    -H 'Accept: application/sparql-results+json' 2>/dev/null || echo ERR")
if [[ "${SPARQL_CODE}" == "200" || "${SPARQL_CODE}" == "403" ]]; then
    ok "SPARQL endpoint responded (HTTP ${SPARQL_CODE})"
else
    fail "SPARQL endpoint unreachable (HTTP ${SPARQL_CODE})"
fi

# ────────────────────────────────────────────────────────────────
# CHECK 11 — Java / Tomcat heap settings
# ────────────────────────────────────────────────────────────────
section "11. Tomcat heap settings"
HEAP_CONF=$(remote "sudo grep -E 'TOMCAT_HEAP|Xms|Xmx' /etc/vivo/install.conf \
    /etc/default/tomcat* /opt/tomcat/bin/setenv.sh 2>/dev/null | head -10 || echo NONE")
if [[ "${HEAP_CONF}" == "NONE" ]]; then
    warn "Could not find explicit heap settings — using JVM defaults"
else
    ok "Heap settings found:"
    echo "${HEAP_CONF}" | sed 's/^/    /'
fi

# ────────────────────────────────────────────────────────────────
# CHECK 12 — Recent errors in logs
# ────────────────────────────────────────────────────────────────
section "12. Recent errors in logs"
FB_ERRORS=$(remote "sudo grep -iE 'error|fail|FAILED|Exception' /var/log/vivo-first-boot.log \
    2>/dev/null | tail -5 || echo NONE")
if [[ "${FB_ERRORS}" == "NONE" || -z "${FB_ERRORS}" ]]; then
    ok "No errors found in /var/log/vivo-first-boot.log"
else
    warn "Errors found in first-boot log (last 5):"
    echo "${FB_ERRORS}" | sed 's/^/    /'
fi

TOMCAT_ERRORS=$(remote "sudo journalctl -u tomcat --no-pager -n 20 2>/dev/null \
    | grep -iE 'error|exception|failed' | tail -5 || echo NONE")
if [[ "${TOMCAT_ERRORS}" == "NONE" || -z "${TOMCAT_ERRORS}" ]]; then
    ok "No errors found in tomcat journal (last 20 lines)"
else
    warn "Errors found in tomcat journal:"
    echo "${TOMCAT_ERRORS}" | sed 's/^/    /'
fi

# ────────────────────────────────────────────────────────────────
# Summary
# ────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════"
printf "${GREEN}  OK  : %d${NC}   ${RED}FAIL: %d${NC}   ${YELLOW}WARN: %d${NC}\n" \
    "${PASS}" "${FAIL}" "${WARN}"
echo "════════════════════════════════════════════════════════"

if [[ "${FAIL}" -gt 0 ]]; then
    exit 1
fi
exit 0
