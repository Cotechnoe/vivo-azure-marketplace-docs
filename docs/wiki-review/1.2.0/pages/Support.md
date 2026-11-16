# Support

> 🇫🇷 Cette page est également disponible en français : [[fr_Support]]

This page lists all available support channels for the **VIVO Research Profiles** Azure Marketplace offer.

---

## Publisher Support — Cotechnoe

For issues specific to this Azure Marketplace VM offer (deployment failures, ARM template errors, VM configuration, image bugs), contact the publisher directly:

- **Email:** [support@cotechnoe.com](mailto:support@cotechnoe.com)
- **GitHub Issues:** [https://github.com/Cotechnoe/vivo-azure-marketplace-docs/issues](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/issues)

When reporting an issue, please include:

- The image version (for example 1.2.0), VIVO/Vitro versions and public/preview status, kept distinct
- The configuration path actually followed (Marketplace/Custom data or direct ARM)
- The Azure region and VM size used
- The output of `sudo cloud-init status --long`
- Relevant log excerpts from `/var/log/vivo-first-boot.log` or `sudo journalctl -u tomcat --no-pager -n 50`

---

Review and redact all output before publication. Do not attach secrets, passwords, private keys, tokens, IP addresses, internal hostnames or personal data. `make diag` can print configuration and logs; do not paste its full output without review. Preparing a diagnostic does not authorize deletion or reinitialization.

Maintenance, certificate, backup and recovery responsibilities are described in [[Configuring-VIVO#operations-backups-and-costs]]. A passed test or Marketplace certification is not a compliance or capacity guarantee.

---

## VIVO Community Support

For questions about VIVO configuration, ontology customization, data ingestion, or application-level behavior, the VIVO community provides several support channels:

| Channel | Details |
|---------|---------|
| **Community mailing list** | [vivo-all@googlegroups.com](mailto:vivo-all@googlegroups.com) — primary list for general discussion and support |
| **Technical mailing list** | [vivo-tech@googlegroups.com](mailto:vivo-tech@googlegroups.com) — for technical and development questions |
| **GitHub Discussions / Issues** | [https://github.com/vivo-project/VIVO/issues](https://github.com/vivo-project/VIVO/issues) |
| **VIVO Contact page** | [https://vivoweb.org/contact/](https://vivoweb.org/contact/) |
| **LYRASIS (community steward)** | [https://www.lyrasis.org/contact](https://www.lyrasis.org/contact) |

---

## Documentation and Self-Help Resources

| Resource | URL |
|----------|-----|
| This wiki | [https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki) |
| VIVO official documentation | [https://wiki.lyrasis.org/display/VIVODOC](https://wiki.lyrasis.org/display/VIVODOC) |
| VIVO project website | [https://vivoweb.org/](https://vivoweb.org/) |
| Troubleshooting guide | [[Troubleshooting]] |

---

## Azure Support

For issues with the Azure infrastructure itself (VM not starting, networking, subscription limits), use the standard Azure support channels:

- **Azure Support portal:** [https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade)
- **Azure documentation:** [https://learn.microsoft.com/azure/](https://learn.microsoft.com/azure/)
