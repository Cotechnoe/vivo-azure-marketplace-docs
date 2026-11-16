#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT
mkdir -p "${TMP_DIR}/bin"
touch "${TMP_DIR}/test-key"

# Every SSH call is intercepted. Only the SPARQL command is executed, with curl
# replaced by a fixture reader; all other diagnostic checks get healthy results.
cat >"${TMP_DIR}/bin/ssh" <<'MOCK_SSH'
#!/usr/bin/env bash
set -euo pipefail
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|-o) shift 2 ;;
        *@*) shift; break ;;
        *) echo "Unexpected SSH argument: $1" >&2; exit 99 ;;
    esac
done
command="$*"
case "${command}" in
    *https://localhost/api/sparqlQuery*)
        [[ "${MOCK_SPARQL_SSH_EXIT:-0}" -eq 0 ]] || exit "${MOCK_SPARQL_SSH_EXIT}"
        exec bash -c "${command}"
        ;;
    true) ;;
    'cloud-init status') echo 'status: done' ;;
    'test -f /etc/vivo/.first-boot-done'*) echo '2026-11-16 00:00:00' ;;
    'sudo cat /etc/vivo/install.conf'*) echo 'VIVO_LANGUAGES=en_US' ;;
    'systemctl is-active '*) echo active ;;
    'systemctl is-enabled '*) echo enabled ;;
    'df -h /data'*) echo '/dev/example 10G 1G 9G 10% /data' ;;
    *'http://localhost/'*) echo 301 ;;
    *'https://localhost/'*) echo 200 ;;
    *'openssl s_client'*) echo 'Nov 16 00:00:00 2027 GMT' ;;
    'sudo ufw status'*) printf 'Status: active\n8983 DENY\n8080 DENY\n' ;;
    *'http://localhost:8983/solr/vivocore/admin/ping'*) echo '"status":"OK"' ;;
    *TOMCAT_HEAP*) echo TOMCAT_HEAP_MIN=1G ;;
    *'vivo-first-boot.log'*|*'journalctl -u tomcat'*) echo NONE ;;
    *) echo "Unexpected remote command: ${command}" >&2; exit 99 ;;
esac
MOCK_SSH

cat >"${TMP_DIR}/bin/curl" <<'MOCK_CURL'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$@" >"${MOCK_CURL_ARGS_FILE}"
cat "${MOCK_HEADERS_FILE}"
printf '\n%s' "${MOCK_HTTP_CODE}"
exit "${MOCK_CURL_EXIT:-0}"
MOCK_CURL
chmod +x "${TMP_DIR}/bin/ssh" "${TMP_DIR}/bin/curl"

fail() { echo "FAIL: $*" >&2; exit 1; }

run_case() {
    local name="$1" expected="$2" code="$3" headers="$4" message="$5"
    shift 5
    local status=0 output="${TMP_DIR}/${name}.out"
    printf '%b' "${headers}" >"${TMP_DIR}/headers"
    if env PATH="${TMP_DIR}/bin:${PATH}" \
        MOCK_HEADERS_FILE="${TMP_DIR}/headers" MOCK_HTTP_CODE="${code}" \
        MOCK_CURL_ARGS_FILE="${TMP_DIR}/curl-args" "$@" \
        bash "${ROOT_DIR}/scripts/vivo-diag.sh" 203.0.113.10 azureuser "${TMP_DIR}/test-key" \
        >"${output}" 2>&1; then
        status=0
    else
        status=$?
    fi
    if [[ "${status}" -ne "${expected}" ]] || ! grep -Fq "${message}" "${output}"; then
        cat "${output}" >&2
        fail "${name}: expected exit ${expected} and message '${message}', got ${status}"
    fi
    if [[ "${expected}" -ne 0 ]] && grep -Eq '\[OK\].*SPARQL|\[WARN\].*SPARQL' "${output}"; then
        fail "${name}: accepted a failed SPARQL probe"
    fi
    if [[ "${expected}" -eq 0 && "${code}" != 200 ]] && ! grep -Eq '\[WARN\].*SPARQL' "${output}"; then
        fail "${name}: restricted access must be reported as a warning"
    fi
    printf 'PASS: %s\n' "${name}"
}

run_case http_200 0 200 'HTTP/1.1 200 OK\r\nContent-Type: application/sparql-results+json\r\n\r\n' \
    'SPARQL endpoint responded (HTTP 200); query results not validated'
run_case http_403 0 403 'HTTP/1.1 403 Forbidden\r\n\r\n' 'access forbidden (HTTP 403)'
run_case basic_401 0 401 'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic realm="VIVO"\r\n\r\n' \
    'Basic authentication required (HTTP 401); authenticated query not tested'
run_case basic_case_and_parameter_order 0 401 \
    'HTTP/2 401\r\nwww-authenticate: bAsIc CHARSET="UTF-8", ReAlM = "VIVO"\r\n\r\n' \
    'Basic authentication required (HTTP 401)'
run_case multiple_headers 0 401 \
    'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Bearer realm="other"\r\nWWW-Authenticate: Basic realm="VIVO"\r\n\r\n' \
    'Basic authentication required (HTTP 401)'
run_case parameters_across_headers 0 401 \
    'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic charset="UTF-8"\r\nWWW-Authenticate: realm="VIVO"\r\n\r\n' \
    'Basic authentication required (HTTP 401)'
run_case combined_challenges 0 401 \
    'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Digest realm="other, realm", nonce="abc", Basic realm="VIVO"\r\n\r\n' \
    'Basic authentication required (HTTP 401)'
run_case empty_realm 0 401 'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic realm=""\r\n\r\n' \
    'Basic authentication required (HTTP 401)'
run_case quoted_comma_and_escape 0 401 \
    'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic realm="VIVO, research \\"lab\\""\r\n\r\n' \
    'Basic authentication required (HTTP 401)'
run_case token_realm 0 401 'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic realm=VIVO\r\n\r\n' \
    'Basic authentication required (HTTP 401)'
run_case missing_challenge 1 401 'HTTP/1.1 401 Unauthorized\r\n\r\n' 'without a valid Basic challenge'
run_case missing_realm 1 401 'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic charset="UTF-8"\r\n\r\n' \
    'without a valid Basic challenge'
run_case malformed_realm 1 401 'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic realm="VIVO\r\n\r\n' \
    'without a valid Basic challenge'
run_case duplicate_realm 1 401 'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic realm="one", realm="two"\r\n\r\n' \
    'without a valid Basic challenge'
run_case another_scheme 1 401 'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Bearer realm="VIVO"\r\n\r\n' \
    'without a valid Basic challenge'
run_case proxy_challenge_only 1 401 'HTTP/1.1 401 Unauthorized\r\nProxy-Authenticate: Basic realm="VIVO"\r\n\r\n' \
    'without a valid Basic challenge'
run_case similar_scheme 1 401 'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: BasicExtra realm="VIVO"\r\n\r\n' \
    'without a valid Basic challenge'
run_case basic_in_another_realm 1 401 \
    'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Digest realm="other, Basic", nonce="abc"\r\n\r\n' \
    'without a valid Basic challenge'
run_case challenge_in_body_only 1 401 \
    'HTTP/1.1 401 Unauthorized\r\n\r\nWWW-Authenticate: Basic realm="body"\r\n' \
    'without a valid Basic challenge'
run_case earlier_challenge_only 1 401 \
    'HTTP/1.1 100 Continue\r\nWWW-Authenticate: Basic realm="old"\r\n\r\nHTTP/1.1 401 Unauthorized\r\n\r\n' \
    'without a valid Basic challenge'
run_case http_500 1 500 'HTTP/1.1 500 Server Error\r\n\r\n' 'unexpected response (HTTP 500)'
run_case redirect 1 302 'HTTP/1.1 302 Found\r\nLocation: /login\r\n\r\n' 'unexpected response (HTTP 302)'
run_case connection_error 1 000 '' 'SSH or curl connection/transfer error' MOCK_CURL_EXIT=7
run_case timeout 1 000 '' 'SSH or curl connection/transfer error' MOCK_CURL_EXIT=28
run_case failed_transfer_with_headers 1 401 \
    'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic realm="VIVO"\r\n\r\n' \
    'SSH or curl connection/transfer error' MOCK_CURL_EXIT=18
run_case ssh_error 1 000 '' 'SSH or curl connection/transfer error' MOCK_SPARQL_SSH_EXIT=255

grep -Fxq -- '--connect-timeout' "${TMP_DIR}/curl-args" || fail 'Missing connection timeout'
grep -Fxq -- '--max-time' "${TMP_DIR}/curl-args" || fail 'Missing transfer timeout'
if grep -Eiq 'Authorization:|^(-u|--user)$' "${TMP_DIR}/curl-args"; then
    fail 'The unauthenticated probe must not send credentials'
fi
echo 'All VIVO diagnostic tests passed (SSH and curl mocked).'
