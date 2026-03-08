# VIVO on Azure Marketplace

> **Marketplace image version:** VIVO [1.16.0](https://github.com/vivo-project/VIVO/releases/tag/vivo-1.16.0)

> 🇫🇷 Cette page est également disponible en français : [README-fr.md](README-fr.md)

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
- TLS termination via Nginx with an automatically provisioned Let's Encrypt certificate

After deployment, VIVO is immediately accessible at `https://<public-ip>/`.

---

## Documentation

Full deployment and administration documentation is available in the **[project wiki](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki)**.

> 🇫🇷 Les pages de documentation sont également disponibles en français — voir la colonne **Français** ci-dessous.

| Page | Description | Français |
|------|-------------|----------|
| [Deploying from Marketplace](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Deploying-from-Marketplace) | Deploy VIVO from Azure Marketplace | [Déployer depuis le Marketplace](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Deploying-from-Marketplace) |
| [SSH Connection](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/SSH-Connection) | Connecting to your VM with an SSH key | [Connexion SSH](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_SSH-Connection) |
| [Post-Deployment Verification](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Post-Deployment-Verification) | Verifying services and accessing VIVO | [Vérification post-déploiement](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Post-Deployment-Verification) |
| [HTTPS / TLS Certificate](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/HTTPS-TLS-Certificate) | Let's Encrypt auto-provisioning, renewal, and custom certs | [Certificat HTTPS / TLS](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_HTTPS-TLS-Certificate) |
| [Configuring VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Configuring-VIVO) | Namespace, credentials, and i18n settings | [Configuration de VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Configuring-VIVO) |
| [Loading Sample Data](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Loading-Sample-Data) | Load sample data to explore VIVO (with and without i18n) | [Chargement des données d'exemple](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Loading-Sample-Data) |
| [Exploring VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Exploring-VIVO) | Navigate the interface, search, profiles, Site Admin | [Explorer VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Exploring-VIVO) |
| [Troubleshooting](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Troubleshooting) | Common deployment and runtime issues | [Dépannage](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Troubleshooting) |
| [Support](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Support) | Publisher and community support channels, contact information | [Support](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Support) |

---

## Release Notes — VIVO 1.16.0

> Full diff: [vivo-1.15.1...vivo-1.16.0](https://github.com/vivo-project/VIVO/compare/vivo-1.15.1...vivo-1.16.0) (98 commits, 212 files changed)

### New features

- **External contributors on publications and grants** — authors, editors, and project participants can now be represented as VCards (external people or organizations) in addition to internal VIVO individuals. This enables tracking of collaborators who do not have a VIVO profile.
- **VCards in co-author graph** — the co-authorship network visualization now includes VCard-based contributors alongside full VIVO persons.
- **VCard indexer for authorships/editorships** — external VCard authors and editors are now indexed in Solr, making them discoverable via search.
- **Organizations as editors** — the editors entry form now supports organizations in addition to persons.
- **TinyMCE editor for fixed HTML pages** — the rich text editor is now available when editing fixed (static) HTML pages in the Site Admin interface.
- **Configurable co-author network limit** — new `runtime.properties` settings allow administrators to control the maximum number of collaborators displayed in the co-author network visualization.

### Improvements

- **POST method for large SPARQL requests** — SPARQL queries that exceed URL length limits are now sent via POST, avoiding `request too long` errors.
- **Decoupled installation and deployment** ([#4017](https://github.com/vivo-project/VIVO/pull/4017)) — the build pipeline now separates the Maven install phase from deployment, improving CI/CD reliability.
- **Translations updated** — new i18n strings added for the "include external co-authors" checkbox and related contributor entry forms.

### Bug fixes

- Fixed authorization check when claiming a DOI on a related profile page.
- Fixed the authors entry form display when an existing person/VCard is already linked.
- Fixed the editors list view rendering.
- Fixed display of existing person/VCard on the "project has participant" form.
- Fixed broken contact and documentation links in the interface.

### Removed / changed

- Removed legacy `validation-n3` files ([#3994](https://github.com/vivo-project/VIVO/pull/3994)).
- Reversed the order of URL type options in the URL entry form ([#3999](https://github.com/vivo-project/VIVO/pull/3999)).
- Removed extraneous text from the CSV export template (VIVO-4000).

### Maintenance

- Updated `example.runtime.properties` with corrections and clarifications.
- Updated `initialSiteConfig.ttl`.
- Docker build pipeline fixes.
- License updated to 2025.

---

## Resources

- [vivoweb.org](https://www.vivoweb.org/) — official VIVO project website
- [VIVO 1.15.x Documentation](https://wiki.lyrasis.org/display/VIVODOC115x/VIVO+1.15.x+Documentation) — LYRASIS wiki (installation, configuration, administration)
- [VIVO on GitHub](https://github.com/vivo-project/VIVO) — source code and issue tracker
