# Loading Sample Data

> 🇫🇷 Cette page est également disponible en français : [[fr_Loading-Sample-Data]]

The [VIVO sample data](https://github.com/vivo-project/sample-data) provides a fictional university (people, departments, publications, grants, memberships) to explore VIVO features on a freshly deployed instance.

Two loading scenarios are covered below:

- **Without i18n** — single language (English), one file to load
- **With i18n** — multilingual (English + French Canadian), three files to load in sequence

> Load sample data only on a **fresh or dedicated instance**. Do not mix it with real institutional data.

---

## Prerequisites

- VIVO is running and accessible at `https://<fqdn>/`
- You are logged in as the **site administrator** (the account secured for this instance; see [[Post-Deployment-Verification#first-vivo-administrator-login]])
- Navigate to: **Site Admin → Add/Remove RDF Data**

---

## Scenario 1 — Without i18n (English only)

Load a single N3 file. The current upstream file includes English language-tagged labels; it is not an untagged dataset.

### Step 1 — Load the sample data

In **Add/Remove RDF Data**:

| Field | Value |
|-------|-------|
| URL | `https://raw.githubusercontent.com/vivo-project/sample-data/main/sample-data.n3` |
| Action | **Add instance data** |
| File type | **N3** |

Click **Submit**.

### Step 2 — Verify

Navigate to the VIVO home page. You should see research areas, people, and organizations populated. Try searching for `Chemistry`, `Roberts`, or `Pringle`.

> **Capability Map:** If the Capability Map at `/vis/capabilitymap` shows no nodes despite data being present, see [[Troubleshooting#capability-map-is-empty--jsonp-blocked-by-mime-type]].

---

## Scenario 2 — With i18n (English + French Canadian)

The `i18n/` directory of the sample data repository distributes labels by locale:

| File | Content |
|------|---------|
| [`sample-data-i18n.ttl`](https://raw.githubusercontent.com/vivo-project/sample-data/main/i18n/sample-data-i18n.ttl) | Base data — structure, relationships and English-tagged labels |
| [`sample-data-i18n-en_US.ttl`](https://raw.githubusercontent.com/vivo-project/sample-data/main/i18n/sample-data-i18n-en_US.ttl) | Additional English (`en_US`) statements; not a complete set for every resource |
| [`sample-data-i18n-fr_CA.ttl`](https://raw.githubusercontent.com/vivo-project/sample-data/main/i18n/sample-data-i18n-fr_CA.ttl) | Additional French Canadian (`fr_CA`) statements; not a complete translation |

### Step 1 — Enable multi-locale mode

Follow [[Configuring-VIVO#mode-2--multi-locale]] to configure the active file, including missing or commented properties. After restarting Tomcat, verify the selector and sample values before importing more data. The base file already includes English labels; the locale files supplement it.

### Step 2 — Load base data

In **Site Admin → Add/Remove RDF Data**:

| Field | Value |
|-------|-------|
| URL | `https://raw.githubusercontent.com/vivo-project/sample-data/main/i18n/sample-data-i18n.ttl` |
| Action | **Add instance data** |
| File type | **Turtle** |

Click **Submit**.

### Step 3 — Load English labels

| Field | Value |
|-------|-------|
| URL | `https://raw.githubusercontent.com/vivo-project/sample-data/main/i18n/sample-data-i18n-en_US.ttl` |
| Action | **Add instance data** |
| File type | **Turtle** |

Click **Submit**.

### Step 4 — Load French Canadian labels

| Field | Value |
|-------|-------|
| URL | `https://raw.githubusercontent.com/vivo-project/sample-data/main/i18n/sample-data-i18n-fr_CA.ttl` |
| Action | **Add instance data** |
| File type | **Turtle** |

Click **Submit**.

### Step 5 — Verify

Navigate to the VIVO home page. A **language selector** should appear in the header. Switch between **English** and **Français** — labels on organizations, people, and research areas should change accordingly.

> **Capability Map:** If the Capability Map at `/vis/capabilitymap` shows no nodes despite data being present, see [[Troubleshooting#capability-map-is-empty--jsonp-blocked-by-mime-type]].

---

## Post-load verification

After loading either scenario, confirm that data is fully indexed and the Capability Map is functional.

### Check the Solr index

The document count below is the total number of documents currently in the Solr index, not a count of the sample dataset. It varies with the VIVO version, existing data, sample-data revision, and indexing progress. Do not use a fixed count as proof that the sample data loaded successfully.

```bash
curl -s "http://localhost:8983/solr/vivocore/select?q=*:*&rows=0" | python3 -c \
  "import sys, json; d=json.load(sys.stdin); print('Docs indexed:', d['response']['numFound'])"
```

Use this only as a diagnostic. If useful, compare the count before and after loading on the same dedicated test instance, then verify the expected people, organizations, and research areas in VIVO. A changing count can indicate indexing is still in progress; the count alone cannot distinguish sample data from other instance data.

### Check Capability Map data endpoint

Verify the visualization data API returns results before testing the browser UI:

```bash
# List all indexed research area concepts
curl -sS "https://<fqdn>/visualizationAjax?vis=capabilitymap&query=all&data=concepts" | head -c 500

# Retrieve researchers linked to a specific concept
curl -sS "https://<fqdn>/visualizationAjax?vis=capabilitymap&query=Rhetoric&callback=ipretResults&noCacheIE=1" | head -c 500
```

For the request containing `callback=ipretResults`, inspect the JSONP response (`ipretResults({...})`) and its records; this does not validate the browser visualization.

If the response is HTML, inspect HTTP status, authentication and the application error; it does not uniquely prove missing data. If the browser blocks the request, see [[Troubleshooting#capability-map-is-empty--jsonp-blocked-by-mime-type]].

### Check Content-Type header

Browsers enforce strict MIME checking. Confirm nginx returns the correct type:

```bash
curl -sS -I "https://<fqdn>/visualizationAjax?vis=capabilitymap&query=Rhetoric&callback=ipretResults&noCacheIE=1" \
  | grep -i content-type
```

Expected:
```
content-type: application/javascript; charset=UTF-8
```

If it returns `text/html`, inspect the response and active configuration before considering the historical workaround in [[Troubleshooting#capability-map-is-empty--jsonp-blocked-by-mime-type]].

---

## Namespace note

Inspect the namespaces in the chosen upstream files: their resource URIs can differ from the namespace configured for your instance. Loading a file does not rewrite its identifiers. Verify profile links, search and visualizations rather than assuming they work for every namespace combination.

The archived 1.2.0 Firefox scenario reconstructed selected data through forms, with incomplete source subjects and an unsupported publication-venue relation omitted. It did not exercise this RDF-import procedure or establish an identical graph. Upstream files may change; record the revision used for a repeatable test.

---

## Returning to a clean test state

This guide does not provide a safe in-place operation for removing only the sample data after it has been loaded. The sample data is added to the instance, and deleting the VIVO triplestore or Solr index directories can remove other data as well. The storage paths and initialization behavior can also vary by image version. **Do not run directory-deletion commands as a sample-data reset.**

For sample-data testing, use a fresh, disposable Marketplace deployment dedicated to that test. If it must be returned to a clean state, recreate the test deployment rather than manually deleting VIVO or Solr data. Before removing any Azure resources, verify that they belong only to the disposable test, that any data you need has a restorable backup, and that you are authorized to remove them.

If sample data was loaded into an instance that contains data you need to keep, do not attempt an in-place reset. Follow your organization’s backup and recovery procedure, verify that the backup can be restored to an isolated instance, and consult the VIVO/instance administrator before changing or replacing the deployment.

The linked VIVO 1.15.x restoration guide is upstream documentation for that VIVO release; its procedure has not been validated for every Marketplace image. Do not apply it to a Marketplace VM without first confirming the version-specific paths and recovery behavior.

---

## References

- [vivo-project/sample-data](https://github.com/vivo-project/sample-data) — GitHub repository
- [Sample Data — VIVO 1.15.x Documentation](https://wiki.lyrasis.org/display/VIVODOC115x/Sample+Data) — LYRASIS wiki
- [Restoring VIVO to First Time State](https://wiki.lyrasis.org/display/VIVODOC115x/Restoring+VIVO+to+First+Time+State) — LYRASIS wiki
- [Language Filter — VIVO 1.15.x Documentation](https://wiki.lyrasis.org/display/VIVODOC115x/Language+Filter) — LYRASIS wiki
- [[Troubleshooting]] — Capability Map empty, MIME type issue
