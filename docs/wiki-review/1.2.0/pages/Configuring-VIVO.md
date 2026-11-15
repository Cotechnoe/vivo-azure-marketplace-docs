# Configuring VIVO

> 🇫🇷 Cette page est également disponible en français : [[fr_Configuring-VIVO]]

Image **1.2.0** contains the application stack; institution-specific settings and ongoing operation remain administrative tasks. See [[Deploying-from-Marketplace]] for initial configuration and the distinction between Marketplace Custom data and direct ARM deployment.

---

## Initial settings and active configuration

At first boot, the image reads `/etc/vivo/install.conf`, initializes the data disk and applies namespace, administrator email, locales and Tomcat heap settings. It then creates `/etc/vivo/.first-boot-done`; subsequent runs skip initialization when that marker exists.

Changing `install.conf` after completion does **not** automatically apply changes. Do not remove the marker or rerun cloud-init to reconfigure an instance containing data. Inspect and edit the active files instead:

| File | Purpose |
| --- | --- |
| `/data/vivo/home/config/runtime.properties` | VIVO namespace, root-user settings and locales |
| `/opt/tomcat/bin/setenv.sh` | Tomcat `CATALINA_OPTS`, including `-Xms` and `-Xmx` |
| `/etc/nginx/conf.d/vivo.conf` | Image's NGINX site; inspect the active configuration because Certbot or an administrator can change it |

Before changing configuration, preserve a copy, arrange an appropriate maintenance window and have a recovery plan. For example:

```bash
sudo cp -a /data/vivo/home/config/runtime.properties \
  /data/vivo/home/config/runtime.properties.bak.$(date +%Y%m%d%H%M%S)
sudoedit /data/vivo/home/config/runtime.properties
```

This copies configuration only; it is not a backup of the running RDF stores or the whole instance.

## Changing the VIVO namespace

Choose the namespace **before loading data**. In `runtime.properties`, ensure one active entry, replacing the example with your institutional URI:

```properties
Vitro.defaultNamespace = https://vivo.example.org/individual/
```

A later edit does not rewrite existing RDF identifiers or migrate data. Plan any change on a populated instance separately, with tested recovery. Restart Tomcat after an approved configuration edit and verify the intended namespace on newly created test data.

## VIVO administrator password

See [[Post-Deployment-Verification#first-vivo-administrator-login]] for first login and the limits of the archived tests. The SSH account and VIVO web account are distinct. Do not use a public SPARQL page as a password-reset procedure.

Changing `rootUser.emailAddress` is not an account rename or a password reset. At startup, Vitro can create another root account if the configured email has no account. Review existing administrator accounts and restrict access before changing this setting; verify the resulting account and secure it before reopening access.

## TLS Certificate (Let's Encrypt)

The image starts with a self-signed certificate. First boot attempts Certbot only if `VIVO_FQDN` is set and Certbot is available; issuing a trusted certificate still requires DNS and ACME validation. Editing that value after initialization does not request a certificate. Use [[HTTPS-TLS-Certificate]] for manual issuance, trust verification and renewal.

## Internationalization (i18n)

Initial settings `VIVO_LANGUAGES` and `VIVO_LANGUAGE_FILTER` are applied to `runtime.properties` at first boot. Thereafter edit the active properties directly. A locale selection does not translate institutional RDF data or install missing translations.

### Mode 1 — Single locale

In `runtime.properties`, ensure these are active exactly once; remove or comment out every active `languages.selectableLocales` entry:

```properties
languages.forceLocale = en_US
RDFService.languageFilter = false
```

### Mode 2 — Multi-locale

Ensure these are active exactly once; remove or comment out every active `languages.forceLocale` entry:

```properties
languages.selectableLocales = en_US, fr_CA
RDFService.languageFilter = true
```

The first listed locale is the default. The language selector and translated interface depend on the corresponding resources being present. The filter is a separate choice; keep it `false` unless you intend language-aware selection of your RDF values.

### RDF language filter (`RDFService.languageFilter`)

With `true`, Vitro selects literal values using language preferences and fallback rules. It does **not** simply hide all untagged values, nor guarantee that every untagged value is always displayed: selection also depends on alternative values for the same subject/property. See the [filter implementation in the packaged Vitro revision](https://github.com/vivo-project/Vitro/blob/c6fdb5091b9026f57901c97cfec88223a63cff47/api/src/main/java/edu/cornell/mannlib/vitro/webapp/rdfservice/filter/LanguageFilterModel.java).

Locale codes use underscores in settings (`fr_CA`) and RDF language tags use hyphens (`@fr-CA`). Verify representative tagged and untagged data in each selected locale before enabling filtering for institutional data.

### Supported locales

The following codes identify the corresponding languages when their translation resources are installed. This table does not certify completeness or availability of every translation in image 1.2.0:

| Locale code | Language |
| --- | --- |
| `en_US` | English (United States) |
| `en_CA` | English (Canada) |
| `fr_CA` | French (Canada) |
| `de_DE` | German |
| `es` | Spanish |
| `pt_BR` | Portuguese (Brazil) |
| `ru_RU` | Russian |
| `sr_Latn_RS` | Serbian (Latin, Serbia) |

### Apply and check language settings

Use the editor procedure above to add missing properties or replace existing entries, including commented entries with spaces. Avoid duplicate active keys; `languages.forceLocale` overrides selectable locales. Then restart Tomcat during the planned maintenance window:

```bash
sudo systemctl restart tomcat
systemctl is-active tomcat
grep -E '^[[:space:]]*(languages\.(forceLocale|selectableLocales)|RDFService\.languageFilter)[[:space:]]*=' \
  /data/vivo/home/config/runtime.properties
```

Verify the interface and representative data after startup; service state alone does not prove the language behavior.

## Operations, backups and costs

- **Access and data:** secure administrator accounts, review SPARQL access and the effective NSG/UFW rules, and decide which research information may be public. External ingestion and identifier integrations require configuration or development.
- **Maintenance:** plan OS and application updates, monitor logs, available disk space and service health. The 1.2.0 image follows the Azure LTS 6.8 kernel series through an APT policy; review that policy with the publisher before changing kernel series. A build-time security check is not continuous vulnerability assurance.
- **Backups and recovery:** arrange application-consistent backups of VIVO RDF stores, home/configuration, Solr data and configuration, and configuration outside `/data` such as Tomcat and NGINX settings. Protect certificate keys and other secrets. Do not treat copying a live TDB directory as a validated backup. Test recovery on an isolated instance and document the tolerated data loss and recovery time. No automated backup policy or high-availability service is established by the archived image tests.
- **Costs:** review plan charges separately from Azure VM, disks, networking, backups and external services. Stopping the guest OS is not the same as deallocating the VM; disks and networking can still incur charges after deallocation. See [Azure VM states and billing](https://learn.microsoft.com/en-us/azure/virtual-machines/states-billing).
- **Institutional responsibilities:** assess data location, backups, replication, outbound flows, telemetry and external services under your policies. Running in your subscription does not by itself establish exclusive data residency, absence of telemetry or regulatory compliance. An image update does not automatically migrate an existing VM's data or configuration.

---

## References

- [VIVO 1.15.x — Internationalization](https://wiki.lyrasis.org/display/VIVODOC115x/Internationalization) (LYRASIS wiki)
- [Enabling Interface Languages in VIVO as an Administrator](https://wiki.lyrasis.org/display/VIVODOC115x/Enabling+Interface+Languages+in+VIVO+as+an+Administrator)
- [Using VIVO's i18n Features](https://wiki.lyrasis.org/display/VIVODOC115x/Using+VIVO%27s+Internationalization+%28i18n%29+Features)
