# Deploying VIVO from the Azure Marketplace

> 🇫🇷 Cette page est également disponible en français : [[fr_Deploying-from-Marketplace]]

Prepare an image **1.2.0** deployment with Ubuntu **24.04 LTS** and VIVO/Vitro **1.16.0**. See [[Home#image-120--status-and-verification]] for the dated distinction between the public offer and the preview.

This guide describes the intended **Advanced → Custom data** configuration path for the 1.2.0 VM image, based on its first-boot implementation. The archived tests deployed the exact image from the gallery; they do not validate the entire Marketplace wizard. Confirm the selected image and the availability of Custom data in your actual deployment. If the wizard differs, contact the publisher before creating the VM.

---

## Before deployment

- Prepare SSH keys and verify the VM's host identity: see [[SSH-Connection]]. The SSH account is separate from the VIVO web account.
- Choose an Azure subscription, region and resource group appropriate to your policies. Review plan pricing and Azure infrastructure costs.
- Size CPU, RAM and disks for your data, indexing and expected usage. The checks performed do not establish a minimum production VM/disk size or a load capacity. Keep memory available for Solr, the OS and other processes when allocating the Tomcat heap.
- Choose the permanent RDF namespace before adding institutional data. Changing identifiers later requires a planned data migration, not just a configuration edit.

## Step 1 — Select and configure the VM

Open the [VIVO offer](https://marketplace.microsoft.com/en-us/product/cotechnoe.vivo-research-profiles?tab=Overview). Confirm the plan and exact image version. The VIVO application version or listing display version is not the image version; do not assume an unqualified latest selection is 1.2.0.

In the VM creation wizard, configure the SSH administrator, SSH public key, VM size, disks and network. Let Azure inherit the OS disk requirement from the selected image rather than forcing a smaller disk.

For separate data storage, attach a **new, empty data disk at LUN 0**. The 1.2.0 initialization mounts that disk at `/data` and formats an unformatted disk. Do not attach a disk containing data to preserve as an initialization experiment. Verify the final mount with [[Post-Deployment-Verification]].

Check the effective NSG and guest firewall rules:

| Port | Use | Required decision |
| --- | --- | --- |
| 443/TCP | VIVO through NGINX | Allow only the intended web clients. |
| 80/TCP | HTTP redirect; HTTP-01 certificate challenge | Allow the certificate authority if using the NGINX/Let's Encrypt procedure. `/health` can return HTTP 200 without testing VIVO. |
| 22/TCP | SSH | Restrict to trusted administration sources; avoid unrestricted access. |
| 8080/TCP | Tomcat | Keep private; the image's UFW configuration denies external access. |
| 8983/TCP | Solr | Keep private; the image's UFW configuration denies external access. |

Do not assume the published deployment creates a particular NSG or DNS name because the reference ARM template does so.

## Step 2 — Provide the initial VIVO configuration

For this image's Custom data path, place the following cloud-config in **Advanced → Custom data** before creating the VM. Replace the example namespace and email. Do not put passwords or private keys in it. See [Azure Custom data](https://learn.microsoft.com/en-us/azure/virtual-machines/custom-data) for its provisioning lifecycle and restrictions.

```yaml
#cloud-config
write_files:
  - path: /etc/vivo/install.conf
    owner: root:root
    permissions: '0600'
    content: |
      VIVO_NAMESPACE='https://vivo.example.org/individual/'
      VIVO_ADMIN_EMAIL='admin@example.org'
      VIVO_LANGUAGES='en_US,fr_CA'
      VIVO_LANGUAGE_FILTER='false'
      TOMCAT_HEAP_MIN='2g'
      TOMCAT_HEAP_MAX='6g'
      VIVO_FQDN=''
```

The image already schedules `/usr/local/bin/vivo-first-boot.sh` through cloud-init. This payload writes the settings it reads; it does not install the application stack again.

| Setting | Meaning |
| --- | --- |
| `VIVO_NAMESPACE` | RDF base URI ending in `/`; choose it for the institution before loading data. |
| `VIVO_ADMIN_EMAIL` | Email used to configure the VIVO root account; not the SSH username or an email delivery configuration. |
| `VIVO_LANGUAGES` | Locale codes separated by commas; one locale forces that locale, multiple locales enable selection when resources are available. |
| `VIVO_LANGUAGE_FILTER` | `true` or `false`; see [[Configuring-VIVO]] before enabling it. |
| `TOMCAT_HEAP_MIN`, `TOMCAT_HEAP_MAX` | The example reproduces the image's `2g`/`6g` fallback settings, not a sizing recommendation. Adapt to the VM and validate the workload. |
| `VIVO_FQDN` | Leave empty to obtain a certificate later. If set, use a hostname already resolving to this VM and arrange HTTP-01 reachability before the first-boot request. |

The payload does not create a disk, DNS record or network rule. If no configuration is supplied, the image has example namespace/email, `en_US`, filter `false`, heap `2g`/`6g` and an empty FQDN as fallbacks. These are not institutional settings.

### Direct ARM deployment is a separate path

The reference ARM template generates its own cloud-init `customData` from parameters such as `vivoNamespace`, `vivoAdminEmail`, `vivoLanguages`, `vivoLanguageFilter`, `vmSize`, `dataDiskSizeGB` and `sshSourceIP`. Do not overwrite that generated payload with a second one. Its local image reference still targets **Jammy 1.1.19** at this review; it is not an approved 1.2.0 deployment artifact.

The reference template maps VM sizes to heap values (`1g`/`3g`, `2g`/`6g`, `4g`/`12g`, `8g`/`24g`). This mapping is reference behavior, not an automatic calculation demonstrated in the Marketplace wizard or a production capacity recommendation. The presence of a `createUiDefinition.json` does not prove a standard VM offer exposes custom VIVO fields.

## Step 3 — Create and verify initialization

Review costs, image version, resource group, network exposure and configuration, then create the VM. Azure provisioning completion does not prove VIVO initialization is complete; duration varies. Connect by SSH and follow [[Post-Deployment-Verification]]. Check cloud-init completion, the first-boot marker, `/data` mount and services before use.

Read configuration and logs locally, and redact secrets, addresses and personal data before sharing excerpts. Do not rerun initialization or remove its marker as a reconfiguration shortcut; see [[Configuring-VIVO]].

## Step 4 — Configure DNS, TLS and first login

Use the actual hostname assigned or configured for this deployment; a DNS name is not guaranteed by the Marketplace path. If required, the documentation toolkit can assign an Azure public-IP DNS label from your workstation:

```bash
git clone https://github.com/Cotechnoe/vivo-azure-marketplace-docs.git
cd vivo-azure-marketplace-docs
make set-dns IP=<vm-public-ip> DNS=<chosen-label>
```

This command changes an Azure resource in the CLI's selected subscription. Verify the subscription and public-IP resource first. For a private deployment, arrange DNS and certificate handling with your administrator instead.

NGINX initially serves a self-signed certificate. Supplying a FQDN can trigger a first-boot Certbot attempt; assigning DNS later does not rerun it. Obtain and verify a trusted certificate using [[HTTPS-TLS-Certificate]] before entering credentials. The 1.2.0 tests did not establish browser certificate trust.

Use [[Post-Deployment-Verification#first-vivo-administrator-login]] for the separate VIVO web account. Follow [[Configuring-VIVO#operations-backups-and-costs]] before keeping an instance or loading institutional data.
