# VIVO on Azure Marketplace

**VIVO** is an open source research networking platform that creates an actionable, connected map of the scholarly work of your institution. It enables academic and research organizations to:

- **Connect** researchers, publications, grants, courses, and organizations into a unified semantic graph
- **Discover** collaboration opportunities and expertise across disciplines
- **Share** data through open standards (Linked Data / RDF), interoperable with external sources such as ORCID, CrossRef, and Wikidata

VIVO is community-developed and supported by [LYRASIS](https://www.lyrasis.org), with over 150 instances deployed in more than 25 countries worldwide.

---

## VIVO on Microsoft Azure Marketplace

This Azure Marketplace offer deploys a fully configured VIVO instance on a dedicated Azure virtual machine. The deployment is automated via an ARM template that handles:

- VM provisioning (Ubuntu, Standard D2s v3 or larger)
- VIVO + Apache Solr + Tomcat + Nginx stack installation
- Institution-specific configuration (namespace, admin credentials, language settings)
- TLS termination via Nginx with a self-signed certificate

After deployment, VIVO is immediately accessible at `https://<public-ip>/`.

---

## Documentation

Full deployment and administration documentation is available in the **[project wiki](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki)**:

| Page | Description |
|------|-------------|
| [Deploying from the Azure Portal](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Deploying-from-the-Azure-Portal) | Step-by-step ARM template deployment guide |
| [SSH Connection](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/SSH-Connection) | Connecting to your VM with an SSH key |
| [Post-Deployment Verification](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Post-Deployment-Verification) | Verifying services and accessing VIVO |
| [Configuring VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Configuring-VIVO) | Namespace, credentials, and i18n settings |
| [Troubleshooting](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Troubleshooting) | Common deployment and runtime issues |

---

## Resources

- [vivoweb.org](https://www.vivoweb.org/) — official VIVO project website
- [VIVO 1.15.x Documentation](https://wiki.lyrasis.org/display/VIVODOC115x/VIVO+1.15.x+Documentation) — LYRASIS wiki (installation, configuration, administration)
- [VIVO on GitHub](https://github.com/vivo-project/VIVO) — source code and issue tracker
