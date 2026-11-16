# VIVO Knowledge Graph — Azure Marketplace Documentation

> 🇫🇷 Cette page est également disponible en français : [[fr_Home]]

Welcome to the official documentation for **VIVO Knowledge Graph** deployed via the Microsoft Azure Marketplace.

VIVO is an open-source research networking platform used by universities and research institutions to represent, manage, and share scholarly data as a semantic knowledge graph.

---

## Image 1.2.0 — status and verification

| Item | Verified or reported status as of 14 November 2026 |
| --- | --- |
| Preview image | **1.2.0**, Ubuntu **24.04 LTS**; VIVO and Vitro **1.16.0** |
| Included stack | Java 21, Tomcat 9, Solr 9, Jena TDB1 and NGINX; configuration and ongoing administration are required |
| Marketplace | Certification and preview creation succeeded according to the publisher's confirmation and Partner Center screenshot; Go live was pending. The screenshot does not itself show the image version. |
| Public offer | The listing observed that day still described Ubuntu 22.04; confirm the image actually selected before deployment. |
| Checks performed | Image packaging/provenance and guest OS/services checked; network smoke 10/10, Chromium 3/3 and Firefox form population 1/1 passed on a test VM from the exact image. |
| Limits | SPARQL required authentication. TLS used a self-signed certificate. Form population omitted incomplete source subjects and an unsupported publication-venue relationship; it was not an identical RDF import. |
| Certification Test Tool | Official CTT report deferred; Partner Center certification does not replace that report. |

These results do not establish general VIVO functional correctness, browser certificate trust, workload capacity or the complete Marketplace deployment path. The intended initial configuration path for image 1.2.0 uses Custom data; follow [[Deploying-from-Marketplace]] for deployment checks and [[Configuring-VIVO]] for operation and backups. A new VM does not automatically migrate an existing instance's data or configuration.

---

## Quick Start

Want to verify the offer before planning a full deployment? Start with [[Quick Start Evaluation|Quick-Start-Evaluation]]. It uses a temporary, test-only environment and includes the cleanup step.

For a full deployment, VIVO is available directly from the [Microsoft Azure Marketplace](https://azuremarketplace.microsoft.com). Follow these steps:

| Step | Description | Page |
|------|-------------|------|
| 1 | Select the image and confirm its configuration method | [[Deploying-from-Marketplace]] |
| 2 | Connect to the VM via SSH | [[SSH-Connection]] |
| 3 | Verify services are running | [[Post-Deployment-Verification]] |
| 4 | Verify HTTPS certificate trust | [[HTTPS-TLS-Certificate]] |
| 5 | Configure VIVO settings | [[Configuring-VIVO]] |
| 6 | Load sample data to explore features | [[Loading-Sample-Data]] |
| 7 | Explore the VIVO interface | [[Exploring-VIVO]] |
| 8 | Troubleshoot common issues | [[Troubleshooting]] |

---

## Architecture Overview

```text
Client -- HTTPS --> NGINX -- HTTP loopback --> Tomcat / VIVO
                                               |-- Jena TDB1: RDF storage
                                               |-- Solr: search index
/data: VIVO home, RDF stores, Solr data and logs
```

The image configures UFW to deny external access to Tomcat (8080) and Solr (8983). Also check the deployment's effective Azure NSG rules: restrict SSH (22) to trusted sources, allow web access only as intended, and keep 8080/8983 private. DNS, a separate data disk and NSG rules depend on the deployment; verify them instead of assuming they were created.

---

## Deployment Parameters

These are parameter names from the reference ARM template, not fields to expect in the Marketplace VM wizard. The deployment guide describes the intended Custom data path for image 1.2.0 without claiming the complete Marketplace wizard was tested. See [[Deploying-from-Marketplace]] for the verification limits and [[Post-Deployment-Verification#first-vivo-administrator-login]] for first login.

| Parameter | Description | Example |
|-----------|-------------|---------|
| `adminUsername` | VM SSH administrator username | `azureuser` |
| `adminPublicKey` | SSH public key (OpenSSH format) | `ssh-ed25519 AAAA...` |
| `vmSize` | Azure VM size | Choose for the workload |
| `dataDiskSizeGB` | Data disk size for VIVO storage | Size for the workload |
| `sshSourceIP` | Allowed CIDR for SSH access | Trusted source CIDR |
| `vivoNamespace` | RDF base URI for VIVO entities | `http://vivo.myuniversity.edu/individual/` |
| `vivoAdminEmail` | VIVO administrator login email | `vivo_root@myuniversity.edu` |
| `vivoLanguages` | Supported locale(s) | `en_US` or `en_US,fr_CA` |
| `vivoLanguageFilter` | Enable RDF language filter | `false` |

---

## Wiki Pages

- [[Quick Start Evaluation|Quick-Start-Evaluation]] — Deploy a temporary test environment and confirm VIVO opens
- [[SSH-Connection]] — How to connect to the VM using a PEM key
- [[Post-Deployment-Verification]] — Validate that all services are running correctly
- [[HTTPS-TLS-Certificate]] — TLS certificate provisioning, Let's Encrypt, renewal, and custom certs
- [[Configuring-VIVO]] — Update namespace, admin email, languages, and other settings
- [[Loading-Sample-Data]] — Load the VIVO sample dataset (with and without i18n)
- [[Exploring-VIVO]] — Navigate the interface, search, browse profiles, and use Site Admin
- [[Troubleshooting]] — Common errors and their solutions
- [[Support]] — Publisher and community support channels, contact information

---

## Available languages

The following pages are also available in French / Les pages suivantes sont également disponibles en français :

| Page | Français |
|------|----------|
| [[Home]] | [[fr_Home]] |
| [[Quick Start Evaluation|Quick-Start-Evaluation]] | [[Évaluation rapide|fr_Quick-Start-Evaluation]] |
| [[Deploying-from-Marketplace]] | [[fr_Deploying-from-Marketplace]] |
| [[SSH-Connection]] | [[fr_SSH-Connection]] |
| [[Post-Deployment-Verification]] | [[fr_Post-Deployment-Verification]] |
| [[HTTPS-TLS-Certificate]] | [[fr_HTTPS-TLS-Certificate]] |
| [[Configuring-VIVO]] | [[fr_Configuring-VIVO]] |
| [[Loading-Sample-Data]] | [[fr_Loading-Sample-Data]] |
| [[Exploring-VIVO]] | [[fr_Exploring-VIVO]] |
| [[Troubleshooting]] | [[fr_Troubleshooting]] |
| [[Support]] | [[fr_Support]] |

---

## Resources

- [VIVO Project](https://vivoweb.org/)
- [VIVO Documentation](https://wiki.lyrasis.org/display/VIVODOC)
- [Azure Marketplace](https://azuremarketplace.microsoft.com)
- [Support](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Support) — Contact publisher or VIVO community
