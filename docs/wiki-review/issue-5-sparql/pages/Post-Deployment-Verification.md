# Post-Deployment Verification

> 🇫🇷 Cette page est également disponible en français : [[fr_Post-Deployment-Verification]]

After deployment, check initialization, storage, service responses and TLS separately. See [[Home#image-120--status-and-verification]] for the scope of the archived image 1.2.0 tests.

---

## Automated Diagnostic

A companion tool runs a set of diagnostic probes in a single command **from your workstation** — no manual SSH sessions required.

**Prerequisites:** Git, `make`, SSH access to the VM, and your SSH private key. The public repository can be cloned over HTTPS without GitHub SSH authentication.

```bash
git clone https://github.com/Cotechnoe/vivo-azure-marketplace-docs.git
cd vivo-azure-marketplace-docs
make diag IP=<vm-public-ip>
```

If your SSH user or key path differ from the defaults:

```bash
make diag IP=<vm-public-ip> SSH_USER=azureuser SSH_KEY=~/.ssh/your-key.pem
```

The script covers **12 diagnostic sections** and prints a colour-coded summary:

| # | Check | What it verifies |
|---|-------|------------------|
| 1 | cloud-init | Reported cloud-init status; does not test every application function |
| 2 | First-boot | Marker present, or completion inferred by a log-text heuristic |
| 3 | Install config | File exists and its contents are displayed; review values yourself |
| 4 | Systemd services | nginx / tomcat / solr active state checked; enabled state displayed |
| 5 | Disk usage | `/data` (or root) usage below warning threshold |
| 6 | HTTP/HTTPS | Local HTTP redirect (301/302) and HTTPS response with trust checks bypassed |
| 7 | TLS certificate | Expiry text from local NGINX; no chain, hostname or expiry-threshold validation |
| 8 | UFW firewall | Textual DENY entries for 8983/8080; not an effective NSG audit |
| 9 | Solr ping | `vivocore` core responds OK (tested from inside the VM) |
| 10 | SPARQL endpoint | HTTP 200 response; 403 or 401 with a valid Basic challenge reported as WARN; query results not validated |
| 11 | Tomcat heap | Heap settings found in files, not workload suitability |
| 12 | Error scan | Recent matching log lines reported as warnings; not an exhaustive scan |

**Exit codes:** `0` = no FAIL recorded (WARNs may remain) · `1` = one or more FAIL · `2` = SSH connection error

**Illustrative summary; counts vary and do not certify a healthy deployment:**
```
════════════════════════════════════════════════════════
  OK  : 16   FAIL: 0   WARN: 2
════════════════════════════════════════════════════════
```

> **Expected WARNs:**
> - *First-boot marker absent* — downgraded to WARN when the log confirms the boot completed. The fallback is a log-text heuristic; confirm completion and investigate a missing marker before relying on initialization.
> - *`/data` not found* — root filesystem usage is reported as a fallback. This does not prove the intended data disk is available; investigate before loading data.
> - *SPARQL access restricted* — a 403 or a 401 with a valid Basic challenge shows that the endpoint responded; an authenticated query has not been tested.

---

## Interpret the diagnostic limits

The updated helper accepts an HTTP 200 response without validating query results. HTTP 403 and HTTP 401 with a valid `WWW-Authenticate: Basic` challenge, including its required `realm` parameter, are reported as WARN: the endpoint responded, but an authenticated query has not been tested. A 401 without a valid Basic challenge, an unexpected HTTP status or an SSH/curl connection or transfer error remains a FAIL.

Older helper revisions accept only 200/403 and report 401 as FAIL. Compare your local script with the current repository before interpreting the result. Inspect status, challenge and access policy; do not make SPARQL public just to clear a diagnostic failure.

HTTP/HTTPS probes run **inside the VM**. They do not validate external NSG reachability, DNS, browser trust or backup recoverability. `curl -k` bypasses certificate checks; a successful page response with that option is not a TLS trust check. Review and redact the diagnostic output before sharing it, as it prints addresses, configuration and log excerpts.

---

## Assign a DNS Name

Check whether this deployment has a DNS name; Marketplace does not establish that the reference ARM template generated one. The helper below changes the Azure public-IP resource and uses the CLI's current subscription. Confirm that subscription and resource before running it. It does not configure private DNS or request a certificate.

Assign a DNS label in one command (requires `az` CLI logged in with the appropriate subscription):

```bash
make set-dns IP=<vm-public-ip>
```

To specify a custom label instead of the default `vivo-<ip-dashes>` pattern:

```bash
make set-dns IP=<vm-public-ip> DNS=my-vivo-instance
```

The command prints the resulting FQDN, e.g. `my-vivo-instance.canadacentral.cloudapp.azure.com`.

---

## Check cloud-init status

SSH into the VM and run:
```bash
sudo cloud-init status --long
```

Expected output when successful:
```
status: done
```

If status is `running`, first-boot is still in progress — wait a few minutes and retry.

---

## Check OS, image provenance and storage

For image 1.2.0, check Ubuntu 24.04 and the active Azure LTS 6.8 kernel. The provenance file identifies the packaged VIVO/Vitro sources and WAR checksum; it does not identify the Marketplace image selected in Azure, which must be checked separately.

```bash
cat /etc/os-release
uname -r
sudo cat /etc/vivo/build-provenance.json
findmnt --mountpoint /data
lsblk -f
```

If a separate data disk was requested, `/data` must be a mount from that disk. A `/data` directory on the OS disk is not proof that the data disk mounted. Investigate a missing mount before loading data.

---

## Check services

```bash
systemctl is-active tomcat solr nginx
```

All three should return `active`.

---

## Check VIVO responds

```bash
curl -sS -o /dev/null -w "%{http_code}" http://localhost:8080/
```

Expected: `200`

---

## Access VIVO in a browser

Navigate to `https://<fqdn>/` using the FQDN assigned to the VM.

> Depending on the image release and deployment settings, first boot may attempt to provision a **Let's Encrypt** certificate. This can fail and has no guaranteed completion time.
> If the browser reports a certificate warning, do not bypass it or enter credentials. Verify the certificate served for the FQDN and see [[HTTPS-TLS-Certificate]] for recovery steps.

---

## First VIVO administrator login

The VIVO administrator login is separate from the VM's SSH account. Verify the TLS certificate for `https://<fqdn>/` before entering credentials; see [[HTTPS-TLS-Certificate]].

The 1.2.0 first-boot implementation maps `VIVO_ADMIN_EMAIL` to `rootUser.emailAddress`; verify that your configuration was applied. The reference ARM inputs do **not** include a `vivoAdminPassword` parameter. The published offer's current wizard and image have not been independently checked against that template; use the email and first-login instructions supplied with your actual deployment, or contact the publisher if they are unclear. Do not assume the SSH key or SSH username is the VIVO password.

For comparison, the [Vitro root-user implementation at the revision packaged in 1.2.0](https://github.com/vivo-project/Vitro/blob/c6fdb5091b9026f57901c97cfec88223a63cff47/api/src/main/java/edu/cornell/mannlib/vitro/webapp/auth/RootUserSetup.java#L106) creates a root account only when the configured root email has no existing account. For that new account it uses a public default initial password when `rootUser.password` is not configured and, by default, requires a password change. Both settings can be overridden. **This source does not establish which settings the published image uses.** Do not assume an existing account has been reset when the VM restarts.

The archived Chromium tests render the homepage, HTTP redirect and login form without submitting credentials. The Firefox population test signs in using credentials supplied through a private file and expects `/siteAdmin`; it does not test creation of a new root account or the mandatory first-password-change flow. Do not infer those behaviors from the passed test counts.

Use the password explicitly specified for your deployed version, restrict access until the account is secured, and change any initial or default password immediately to a unique strong password. If the expected credentials or change-password flow do not work, stop and consult the publisher or instance administrator; do not post credentials or configuration secrets in a public issue.

---

## View the VM initialization log

For detailed information about what happened during deployment:
```bash
sudo tail -100 /var/log/vivo-first-boot.log
```
