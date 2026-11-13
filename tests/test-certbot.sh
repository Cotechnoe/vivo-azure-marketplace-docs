#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CERTBOT_SCRIPT="${ROOT_DIR}/scripts/certbot.sh"
TMP_DIR="$(mktemp -d)"
MOCK_BIN="${TMP_DIR}/bin"
mkdir -p "${MOCK_BIN}"
trap 'rm -rf "${TMP_DIR}"' EXIT

cat >"${MOCK_BIN}/ssh" <<'MOCK_SSH'
#!/usr/bin/env bash
set -euo pipefail
args=("$@")
printf '%s\n' "${args[@]}" >"${MOCK_SSH_ARGS_FILE}"
if [[ "${MOCK_SSH_EXIT:-0}" -ne 0 ]]; then
  exit "${MOCK_SSH_EXIT}"
fi
remote_command="${args[${#args[@]}-1]}"
exec bash -c "${remote_command}"
MOCK_SSH

cat >"${MOCK_BIN}/sudo" <<'MOCK_SUDO'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  certbot) exit "${MOCK_CERTBOT_EXIT:-0}" ;;
  nginx) exit "${MOCK_NGINX_EXIT:-0}" ;;
  systemctl)
    case "${2:-}" in
      cat) exit "${MOCK_TIMER_PRESENT:-0}" ;;
      enable) exit "${MOCK_TIMER_ENABLE_EXIT:-0}" ;;
      is-enabled) exit "${MOCK_TIMER_ENABLED_EXIT:-0}" ;;
      is-active) exit "${MOCK_TIMER_ACTIVE_EXIT:-0}" ;;
    esac
    ;;
  test) exit "${MOCK_CRON_PRESENT:-1}" ;;
esac
echo "Unexpected sudo command: $*" >&2
exit 99
MOCK_SUDO

cat >"${MOCK_BIN}/openssl" <<'MOCK_OPENSSL'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$@" >"${MOCK_OPENSSL_ARGS_FILE}"
exit "${MOCK_TLS_EXIT:-0}"
MOCK_OPENSSL

chmod +x "${MOCK_BIN}/ssh" "${MOCK_BIN}/sudo" "${MOCK_BIN}/openssl"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_case() {
  local name="$1"
  local expected_status="$2"
  shift 2
  local output="${TMP_DIR}/${name}.out"
  local error="${TMP_DIR}/${name}.err"
  local status=0

  if env \
    PATH="${MOCK_BIN}:${PATH}" \
    MOCK_SSH_ARGS_FILE="${TMP_DIR}/ssh-args" \
    MOCK_OPENSSL_ARGS_FILE="${TMP_DIR}/openssl-args" \
    "$@" \
    "${CERTBOT_SCRIPT}" \
    "203.0.113.10" \
    "vivo.example.org" \
    "admin@example.org" \
    "azureuser" \
    >"${output}" 2>"${error}"; then
    status=0
  else
    status=$?
  fi

  if [[ "${status}" -ne "${expected_status}" ]]; then
    cat "${output}" "${error}" >&2
    fail "${name}: expected exit ${expected_status}, got ${status}"
  fi

  if [[ "${status}" -eq 0 ]] && ! grep -q "TLS certificate for vivo.example.org is served and verified" "${output}"; then
    cat "${output}" "${error}" >&2
    fail "${name}: missing verified-success message"
  fi

  if [[ "${status}" -ne 0 ]] && grep -q "TLS certificate for vivo.example.org is served and verified" "${output}"; then
    fail "${name}: reported success after failure"
  fi
}

run_case success 0 MOCK_CERTBOT_EXIT=0 MOCK_TIMER_PRESENT=0 MOCK_TLS_EXIT=0
grep -Fqx "StrictHostKeyChecking=accept-new" "${TMP_DIR}/ssh-args" || fail "SSH host-key checking is not enabled"
if grep -Fq "StrictHostKeyChecking=no" "${TMP_DIR}/ssh-args"; then
  fail "SSH host-key checking is disabled"
fi
grep -Fqx -- "-servername" "${TMP_DIR}/openssl-args" || fail "TLS verification does not set SNI"
grep -Fqx -- "-verify" "${TMP_DIR}/openssl-args" || fail "TLS verification does not validate the certificate chain"
grep -Fqx -- "-verify_hostname" "${TMP_DIR}/openssl-args" || fail "TLS verification does not validate the hostname"
grep -Fqx "vivo.example.org" "${TMP_DIR}/openssl-args" || fail "TLS verification does not use the FQDN"

run_case certbot_failure 42 MOCK_CERTBOT_EXIT=42 MOCK_TIMER_PRESENT=0 MOCK_TLS_EXIT=0
run_case timer_enable_failure 17 MOCK_CERTBOT_EXIT=0 MOCK_TIMER_PRESENT=0 MOCK_TIMER_ENABLE_EXIT=17 MOCK_TLS_EXIT=0
run_case timer_inactive_failure 23 MOCK_CERTBOT_EXIT=0 MOCK_TIMER_PRESENT=0 MOCK_TIMER_ACTIVE_EXIT=23 MOCK_TLS_EXIT=0
run_case tls_verification_failure 1 MOCK_CERTBOT_EXIT=0 MOCK_TIMER_PRESENT=0 MOCK_TLS_EXIT=19
run_case cron_fallback 0 MOCK_CERTBOT_EXIT=0 MOCK_TIMER_PRESENT=1 MOCK_CRON_PRESENT=0 MOCK_TLS_EXIT=0
grep -q "cron renewal file exists, but its execution was not verified" "${TMP_DIR}/cron_fallback.err" \
  || fail "cron fallback did not clearly report its unverified state"
run_case missing_renewal_configuration 1 MOCK_CERTBOT_EXIT=0 MOCK_TIMER_PRESENT=1 MOCK_CRON_PRESENT=1 MOCK_TLS_EXIT=0

echo "All Certbot script tests passed."
