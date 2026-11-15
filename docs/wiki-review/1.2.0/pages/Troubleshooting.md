# Troubleshooting

> 🇫🇷 Cette page est également disponible en français : [[fr_Troubleshooting]]

Common issues encountered when deploying and running VIVO on Azure Marketplace.

> **Run the automated diagnostic first.** The `make diag` command probes services, the guest firewall, certificate expiry, Solr, SPARQL status and recent logs; the probes run from your workstation. Review their limits in the verification guide.
> → See [[Automated Diagnostic|Post-Deployment-Verification#automated-diagnostic]] for setup and usage.

---

## Deployment fails — `VIVO_LANGUAGES: unbound variable`

**Symptom:**
```
VIVO_LANGUAGES: unbound variable
cloud-final.service: Failed
```

**Historical context:** Earlier initialization scripts could fail on missing settings. The 1.2.0 implementation supplies fallbacks; this error alone does not identify the deployment method. Confirm the image version, applied configuration and failing script in the logs.

**Action:** Inspect cloud-init status and the initialization log, then consult the publisher before attempting recovery. Preserve existing data and configuration. Do not delete a VM or reset its first-boot marker as a generic fix. See [[Deploying-from-Marketplace]] and [[Configuring-VIVO]].

---

## SSH — UNPROTECTED PRIVATE KEY FILE

**Symptom:**
```
Permissions 0777 for 'key.pem' are too open.
bad permissions: ignore key
```

**Cause:** The key file is on a Windows/NTFS filesystem (e.g. `/mnt/c/...`). `chmod` has no effect there.

**Fix:**
```bash
cp /mnt/c/Users/<YourName>/Downloads/your-key.pem ~/.ssh/
chmod 600 ~/.ssh/your-key.pem
ssh -i ~/.ssh/your-key.pem azureuser@<public-ip>
```

---

## Deployment error — `osDisk.diskSizeGB` too small

**Symptom:**
```json
"code": "OperationNotAllowed",
"message": "The specified disk size 64 GB is less than the size of the corresponding disk in the VM image: 256 GB."
```

**Cause:** The deployment template from a previous offer version set a disk size smaller than the image requires. This historical example does not establish the current public offer or its disk requirement.

**Action:** Check the selected image's OS disk requirement and remove an undersized override from the deployment configuration. Do not replace an existing VM or discard data without a recovery plan and authorization.

---

## Deployment error — `linuxConfiguration.ssh.publicKeys.path` invalid

**Symptom:**
```json
"code": "InvalidParameter",
"target": "linuxConfiguration.ssh.publicKeys.path"
```

**Cause:** `adminUsername` was left empty, producing path `/home//.ssh/authorized_keys`.

**Fix:** Ensure `adminUsername` is filled in (default: `azureuser`).

---

## VIVO is accessible but shows default example.org namespace

**Possible cause:** The intended settings were not supplied or applied before initialization. The image's fallback namespace is an example, not an institutional configuration.

**Action:** Compare initial settings with the active `runtime.properties`. If data has already been loaded, changing the configured namespace does not migrate its identifiers. See [[Configuring-VIVO]] before changing it.

---

## Browser security warning — certificate not trusted

**Symptom:** Firefox/Chrome shows "Potential Security Risk" or "Your connection is not private" for the FQDN.

**Possible causes:** No FQDN was supplied, the Certbot request failed, or the served certificate is expired, untrusted or for another name. The 1.2.0 tests used a self-signed certificate; they did not establish browser trust.

**Diagnose:**
```bash
sudo grep -i certbot /var/log/vivo-first-boot.log
sudo cat /var/log/letsencrypt/letsencrypt.log | tail -30
```

**Fix:** Run certbot manually — see [[HTTPS-TLS-Certificate]].

---

## Services status check

```bash
systemctl status tomcat solr nginx
sudo journalctl -u tomcat --no-pager -n 50
sudo tail -100 /opt/tomcat/logs/catalina.out
```

---

## Capability Map is empty — JSONP blocked by MIME type

**Symptom:**

The VIVO Capability Map at `/vis/capabilitymap` loads its frame but shows no nodes, even after sample data has been loaded and indexed. The browser console shows:

```
La ressource à l'adresse /visualizationAjax... a été bloquée en raison d'un type MIME
(« text/html ») incorrect (X-Content-Type-Options: nosniff)
```

or in English:

```
The resource at /visualizationAjax... was blocked due to MIME type ("text/html") mismatch
(X-Content-Type-Options: nosniff)
```

**Cause:**

In the affected historical deployments, VIVO's `/visualizationAjax` endpoint returned `Content-Type: text/html` for all responses, including JSONP (where the body is JavaScript of the form `ipretResults({...})`). Nginx applies `X-Content-Type-Options: nosniff` globally. Browsers comply with the nosniff directive and block execution of the JSONP callback, resulting in an empty map.

**Step 1 — Verify the upstream data is present**

Before fixing nginx, confirm the backend is returning data:

```bash
curl -sS "https://<fqdn>/visualizationAjax?vis=capabilitymap&query=Rhetoric&callback=ipretResults&noCacheIE=1" | head -c 200
```

Expected output (JSONP):
```
ipretResults({"researchers":[...], "researchAreas":[...]})
```

If the output is HTML, check status, authentication and application errors before concluding that data is missing — see [[Loading-Sample-Data]].

**Step 2 — Check the Content-Type header**

```bash
curl -sS -I "https://<fqdn>/visualizationAjax?vis=capabilitymap&query=Rhetoric&callback=ipretResults&noCacheIE=1" \
  | grep -i content-type
```

- Returns `text/html` → inspect the response and active configuration before choosing a fix (Step 3)
- Returns `application/javascript` → nginx is already fixed, check browser console for other errors

**Step 3 — Review the historical nginx workaround**

Image 1.2.0 already includes the workaround below. For an affected older instance, inspect and back up the active NGINX configuration first. Do not add a duplicate location. With an administrator, consider a dedicated `location /visualizationAjax {}` block inside the relevant `server { listen 443 ... }` block in `/etc/nginx/conf.d/vivo.conf`:

```nginx
# JSONP fix — VIVO returns text/html for /visualizationAjax
location /visualizationAjax {
    proxy_pass         http://127.0.0.1:8080;
    proxy_set_header   Host              $host;
    proxy_set_header   X-Real-IP         $remote_addr;
    proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto https;
    proxy_read_timeout 300s;
    proxy_connect_timeout 60s;
    proxy_hide_header  Content-Type;
    add_header Content-Type              "application/javascript; charset=UTF-8" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains"   always;
    add_header X-Frame-Options           "SAMEORIGIN"                            always;
    add_header Referrer-Policy           "strict-origin-when-cross-origin"       always;
}
```

> **Historical workaround:** The block reproduces the image's JavaScript MIME override and local security headers. Removing `nosniff` is not generally required when the correct MIME type is served. Under the standard [NGINX header inheritance rules](https://nginx.org/en/docs/http/ngx_http_headers_module.html#add_header), local `add_header` directives affect inheritance; check the installed version and active configuration rather than copying this as a general security policy.

After editing, validate and reload nginx:

```bash
sudo nginx -t && sudo systemctl reload nginx
```

Re-run the Step 2 check — `content-type: application/javascript; charset=UTF-8` confirms the fix is active.

> The workaround is present in image 1.2.0. Its presence is not a functional validation of every visualization; confirm the response and browser behavior for your data.
