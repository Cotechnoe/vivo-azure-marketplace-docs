# HTTPS / TLS Certificate

> 🇫🇷 Cette page est également disponible en français : [[fr_HTTPS-TLS-Certificate]]

VIVO is served exclusively over HTTPS (port 443). This page explains how the TLS certificate is provisioned and what to expect.

---

## Automatic Let's Encrypt certificate

Image **1.2.0** starts with a **self-signed certificate**. Its first-boot script attempts Let's Encrypt only if `VIVO_FQDN` is non-empty and Certbot is available. Confirm that your deployment actually supplies that value: the reference ARM template does so, but this does not establish the Marketplace wizard's behavior. Assigning a DNS name after first boot does not itself rerun the certificate request.

The archived 1.2.0 tests used a self-signed certificate and bypassed trust checks. A browser-trusted certificate has **not** been demonstrated on that Marketplace path. The procedure below is a recovery/administration path, not a record of successful issuance for this preview.

For the NGINX plugin's [HTTP-01 challenge](https://letsencrypt.org/docs/challenge-types/#http-01-challenge), public DNS must resolve to the intended endpoint and inbound port **80** must be reachable by the certificate authority. Allowing only your workstation through an NSG is insufficient for that challenge. For a private service, arrange an organizational certificate or a separately configured validation method; DNS-01 is not configured by this image.

**How it works:**

1. Nginx starts with the certificate configured by the image.
2. When the conditions above are met, first boot attempts `certbot --nginx` for the supplied FQDN, for example:
   ```
   {projectName}-{uniqueHash}.{region}.cloudapp.azure.com
   ```
3. Let's Encrypt must be able to complete the ACME HTTP-01 challenge over port 80.
4. If issuance succeeds, Nginx serves the new certificate. If it fails, the image's fallback certificate may remain active.

There is no guaranteed completion time. Check the certificate actually served before using the site or entering credentials. Follow the manual procedure below if automatic provisioning did not succeed.

---

## Verify the certificate

Check the certificate configured on the VM:

```bash
# From the VM
sudo certbot certificates

# Example after successful issuance:
# Found the following certs:
#   Certificate Name: vivo-xxxx.canadacentral.cloudapp.azure.com
#   Domains: vivo-xxxx.canadacentral.cloudapp.azure.com
#   Expiry Date: <date> (VALID: <remaining days>)
#   Certificate Path: /etc/letsencrypt/live/.../fullchain.pem
```

From a workstation, verify the certificate served for the FQDN. `curl` uses its normal CA and hostname verification:

```bash
FQDN="<fqdn>"
curl --silent --show-error --output /dev/null \
  --write-out 'HTTP %{http_code}; TLS verification result %{ssl_verify_result}\n' \
  "https://${FQDN}/"
```

The command must exit successfully and report TLS verification result `0`; an HTTP response or certificate expiry date alone is insufficient. Do not add `-k` to this trust check. You can also inspect the certificate in your browser and confirm its subject/SAN includes the FQDN and that the browser trusts its issuer.

---

## Browser security warning (self-signed fallback)

If no FQDN was supplied, no request was made. If a request failed (for example, DNS not ready, port 80 blocked or an ACME limit reached), the self-signed certificate may remain active. An expired or mismatched custom certificate can also cause a warning.

**Symptom:** The browser reports that the certificate is untrusted, expired, or does not match the FQDN.

Do not bypass the warning or enter credentials on a deployment that should have a trusted certificate. Verify the FQDN, DNS, and served certificate, then follow the manual procedure below. Use an untrusted certificate only in an isolated test environment with no sensitive data or credentials.

Do not use the public IP in the browser URL: the certificate is issued for a hostname, not for the IP address.

---

## Manual certificate provisioning

If no request was made or automatic provisioning failed, first confirm that the FQDN resolves to the VM's current public IP and that inbound port 80 is reachable. From a clone of the documentation repository on your workstation, with `make`, OpenSSH and OpenSSL installed, request the certificate with:

```bash
make certbot IP=<vm-public-ip> FQDN=<fqdn> EMAIL=<your@email.com> SSH_KEY=~/.ssh/your-key.pem
```

The script returns a non-zero status if Certbot, Nginx validation, SSH, renewal-timer setup, or the final served-certificate verification fails. If only a cron renewal file is found, it reports that the file exists but does not claim that cron execution was verified. The TLS check validates the certificate chain and FQDN while connecting to the supplied IP.

SSH uses OpenSSH `StrictHostKeyChecking=accept-new`: the first key presented is saved in your `known_hosts` file and a changed key is rejected. This is trust-on-first-use, not an independent identity check; verify the VM's SSH host-key fingerprint through a trusted channel before the first connection when possible.

Alternatively, SSH directly into the VM and run Certbot manually after verifying that port 80 is reachable:

```bash
FQDN="<fqdn>"

sudo certbot --nginx \
  -d "${FQDN}" \
  --non-interactive \
  --agree-tos \
  --email "your@email.com" \
  --redirect
```

Validate Nginx, then verify the certificate from your workstation:
```bash
sudo nginx -t
sudo certbot certificates
```

```bash
curl --silent --show-error --output /dev/null \
  --write-out 'HTTP %{http_code}; TLS verification result %{ssl_verify_result}\n' \
  "https://${FQDN}/"
```

---

## Certificate renewal

Use the [Certbot renewal guidance](https://eff-certbot.readthedocs.io/en/stable/using.html#automated-renewals) to check the mechanism configured on this image; it may be a systemd timer or a cron job. Do not assume that a timer or cron entry is active just because the certificate exists.

For a systemd timer:
```bash
sudo systemctl status --no-pager certbot.timer
sudo systemctl is-enabled certbot.timer
sudo systemctl is-active certbot.timer
```

If the image uses `/etc/cron.d/certbot`, inspect that file and verify the cron service is running. `sudo certbot renew --dry-run` exercises renewal against the ACME staging service; it makes an external network request and should only be run when authorized.

---

## Logs

```bash
# VM initialization log (includes certbot output)
sudo grep -i certbot /var/log/vivo-first-boot.log

# Certbot full log
sudo tail -50 /var/log/letsencrypt/letsencrypt.log
```

---

## Using a custom certificate

If your institution provides its own TLS certificate, first identify the active Nginx server block for the FQDN and the certificate paths it actually uses. Certbot can change these paths; do not assume they remain `/etc/nginx/ssl/vivo.crt` and `/etc/nginx/ssl/vivo.key`.

```bash
sudo nginx -T 2>/dev/null | grep -nE 'server_name|ssl_certificate(_key)?[[:space:]]'
```

Identify the `server_name` block for your FQDN and its matching `ssl_certificate` and `ssl_certificate_key` directives. Back up the active configuration and certificate files before changing them. Install the matching certificate chain and private key at paths managed by your organization, update only that server block, and keep the private key readable only by the required privileged process. Do not overwrite Certbot-managed symlinks or files without confirming their renewal ownership.

Validate and reload Nginx, then verify the certificate served for the FQDN using the `curl` command above:

```bash
sudo nginx -t && sudo systemctl reload nginx
```

Do not disable `certbot.timer` blindly. First confirm whether any Certbot-managed certificate still depends on it and document how the custom certificate will be renewed.
