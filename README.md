# VIVO on Azure Marketplace

> 🇫🇷 Cette page est également disponible en français : [README-fr.md](README-fr.md)

> **Image 1.2.0 — review copy:** the guides linked here come from the [review package](docs/wiki-review/1.2.0/README.md). They have not yet been published to the Wiki.

**VIVO** is an open-source research networking platform for connecting researcher profiles, organizations, publications and scholarly activities in a knowledge graph. Institutions can browse profiles, search indexed content and work with RDF data.

VIVO is developed by its community with support from [LYRASIS](https://www.lyrasis.org). External sources and identifiers such as ORCID, Crossref and Wikidata require an appropriate data integration; this image does not connect them automatically. AI or retrieval-augmented generation (RAG) workflows also require additional integration or development.

## Image 1.2.0 and the public offer

**Image 1.2.0** contains **Ubuntu 24.04 LTS**, **VIVO 1.16.0** and **Vitro 1.16.0**, with Java 21, Tomcat 9, Solr 9, Jena TDB1 and NGINX. These components are preinstalled; an administrator configures and maintains the deployed instance.

As of the publisher's 14 November 2026 review, image 1.2.0 was in a certified Marketplace preview with Go live pending. The public listing still described Ubuntu 22.04. Confirm the offer, plan and image version selected at deployment; neither the VIVO application version nor the listing's display version identifies the image version. See [release status and verification limits](docs/wiki-review/1.2.0/pages/Home.md#image-120--status-and-verification).

## Deploy and operate VIVO

The intended configuration path for image 1.2.0 uses **Advanced → Custom data**, based on the image implementation; the complete Marketplace wizard has not been validated by the archived image tests. The [deployment guide](docs/wiki-review/1.2.0/pages/Deploying-from-Marketplace.md) distinguishes that path from a direct ARM deployment. Do not assume a reference ARM template or UI definition describes the published VM wizard.

NGINX provides HTTPS and redirects ordinary HTTP requests to HTTPS. The initial certificate is self-signed; Let's Encrypt is attempted only when the deployment supplies a FQDN and Certbot is available. A browser-trusted certificate has not been demonstrated by the archived 1.2.0 tests. Follow the [TLS guide](docs/wiki-review/1.2.0/pages/HTTPS-TLS-Certificate.md) to obtain and verify a certificate for your deployment.

Choose VM and disk capacity for your data, indexing and usage; the checks performed do not establish a minimum production size or load capacity. Review Marketplace plan pricing and Azure compute, storage, networking and backup charges before deployment. Access control, patching, certificates, backups and recovery remain administrative responsibilities. Deploying in an Azure subscription does not itself guarantee data residency or regulatory compliance; assess data flows and external services for your institution.

---

## Documentation

The links below open the **proposed image 1.2.0 pages in this repository**. Publishing those pages to the Wiki remains a separate step.

The [published Wiki (earlier guidance)](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki) remains available separately; it does not yet describe the 1.2.0 changes proposed here.

> 🇫🇷 Les pages de documentation sont également disponibles en français — voir la colonne **Français** ci-dessous.

| Proposed English page | Description | Proposition française |
|------|-------------|----------|
| [Quick Start Evaluation](docs/wiki-review/1.2.0/pages/Quick-Start-Evaluation.md) | Deploy a temporary test environment to evaluate the Marketplace offer | [Évaluation rapide](docs/wiki-review/1.2.0/pages/fr_Quick-Start-Evaluation.md) |
| [Deploying from Marketplace](docs/wiki-review/1.2.0/pages/Deploying-from-Marketplace.md) | Deploy VIVO from Azure Marketplace | [Déployer depuis le Marketplace](docs/wiki-review/1.2.0/pages/fr_Deploying-from-Marketplace.md) |
| [SSH Connection](docs/wiki-review/1.2.0/pages/SSH-Connection.md) | Connecting to your VM with an SSH key | [Connexion SSH](docs/wiki-review/1.2.0/pages/fr_SSH-Connection.md) |
| [Post-Deployment Verification](docs/wiki-review/1.2.0/pages/Post-Deployment-Verification.md) | Verifying services and accessing VIVO | [Vérification post-déploiement](docs/wiki-review/1.2.0/pages/fr_Post-Deployment-Verification.md) |
| [HTTPS / TLS Certificate](docs/wiki-review/1.2.0/pages/HTTPS-TLS-Certificate.md) | Let's Encrypt attempts, TLS verification, renewal, and custom certs | [Certificat HTTPS / TLS](docs/wiki-review/1.2.0/pages/fr_HTTPS-TLS-Certificate.md) |
| [Configuring VIVO](docs/wiki-review/1.2.0/pages/Configuring-VIVO.md) | Namespace, credentials, and i18n settings | [Configuration de VIVO](docs/wiki-review/1.2.0/pages/fr_Configuring-VIVO.md) |
| [Loading Sample Data](docs/wiki-review/1.2.0/pages/Loading-Sample-Data.md) | Load sample data to explore VIVO (with and without i18n) | [Chargement des données d'exemple](docs/wiki-review/1.2.0/pages/fr_Loading-Sample-Data.md) |
| [Exploring VIVO](docs/wiki-review/1.2.0/pages/Exploring-VIVO.md) | Navigate the interface, search, profiles, Site Admin | [Explorer VIVO](docs/wiki-review/1.2.0/pages/fr_Exploring-VIVO.md) |
| [Troubleshooting](docs/wiki-review/1.2.0/pages/Troubleshooting.md) | Common deployment and runtime issues | [Dépannage](docs/wiki-review/1.2.0/pages/fr_Troubleshooting.md) |
| [Support](docs/wiki-review/1.2.0/pages/Support.md) | Publisher and community support channels, contact information | [Support](docs/wiki-review/1.2.0/pages/fr_Support.md) |

---

## Release Notes — VIVO 1.16.0

This retained upstream release summary concerns VIVO 1.16.0, not new features introduced by image 1.2.0 or a functional certification of the packaged application.

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
