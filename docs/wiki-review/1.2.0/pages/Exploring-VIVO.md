# Exploring VIVO

> 🇫🇷 Cette page est également disponible en français : [[fr_Exploring-VIVO]]

This page walks you through the VIVO interface after a successful deployment. It covers logging in, searching, browsing profiles, and using the site administration tools.

> The examples below assume the [[sample data|Loading-Sample-Data]] has been loaded. On a fresh empty instance, search results will be empty until real or sample data is added.

---

## Logging in

Navigate to `https://<fqdn>/` and click **Log in** in the upper-right corner. Use the VM's FQDN so the browser can verify the TLS certificate.

Use the VIVO administrator email and password applicable to your deployed version, not the VM's SSH credentials. For the first login, the current verification limits, and instructions to secure the account, see [[Post-Deployment-Verification#first-vivo-administrator-login]].

After logging in, the header shows your name and a **Site Admin** link becomes visible.

---

## Navigating the interface

The VIVO header provides the main entry points:

| Element | Description |
|---------|-------------|
| **Search box** | Full-text search across all VIVO entities |
| **Browse** menus | Browse by People, Organizations, Research, Events, etc. |
| **Log in / name** | Authentication and profile access |
| **Site Admin** | Administration panel (visible to site admins only) |

The home page displays a **summary of the data** in your VIVO — counts of people, publications, and organizations.

---

## Searching

The search box performs a full-text search across all indexed entities.

**Try these queries with the sample data:**

| Query | Expected results |
|-------|-----------------|
| `Chemistry` | Department and related people and publications |
| `Roberts` | Faculty members with that surname |
| `Pringle` | A specific researcher profile |
| `grant` | Funded projects and grants |

Search results display the entity type (Person, Organization, Grant, etc.), a short description, and a link to the full profile.

Use **filters** on the left side of the results page to narrow by entity class (People, Publications, Organizations, etc.).

---

## Browsing profiles

### Person profile

Click on any person in search results to open their profile. A profile page shows:

- Name, title, and institutional affiliation
- Research areas and expertise keywords
- Publications, grants, and awards
- Co-authorship and collaborator connections
- Teaching activities (courses, advising)

### Organization profile

An organization page shows its members, sub-organizations, and associated grants and publications.

---

## Verbose property display (admin)

When logged in as a site administrator, you can enable **verbose property display** on any profile to see the underlying RDF properties VIVO is using.

1. Open any person or entity profile
2. Click **Turn On** at the top of the page (next to "Verbose Property Display")
3. Each field now shows its RDF property URI alongside its value
4. Click **Turn Off** to return to normal view

This is useful for understanding how VIVO models scholarly data as a connected graph.

---

## Editing an individual (admin)

From any profile page (while logged in as admin):

1. Click **Edit this individual** in the Individual Control Panel
2. You will see an internal view with:
   - **Datatype properties**: literal string values (name, title, email, etc.)
   - **Object properties**: links to other entities (member of, co-author with, etc.)
3. Click the edit icon next to any property to modify it
4. Changes are reflected immediately in the profile

---

## Site Administration

The **Site Admin** panel (accessible from the header when logged in as admin) provides access to:

| Section | Description |
|---------|-------------|
| **Add/Remove RDF Data** | Load or delete RDF triples (N3, Turtle, RDF/XML) |
| **Ingest Menu** | Ingestion tools; configure sources and integrations separately |
| **User Accounts** | Create and manage user accounts |
| **Site Configuration** | Theme, contact info, and display settings |
| **SPARQL Query** | Run SPARQL queries directly against the triplestore |
| **Index** | Rebuild or check the Solr search index |

---

## Visualizations

VIVO includes built-in visualizations accessible from person and organization profiles:

- **Co-authorship network** — graph of collaborators connected through shared publications
- **Publication timeline** — chronological view of scholarly output
- **Geographic map** — distribution of collaborators by location (when location data is present)

Tool availability and results depend on the interface, configuration and data. The 1.2.0 checks do not validate every visualization or integration; see [[Home#image-120--status-and-verification]].

---

## References

- [Exploring VIVO — VIVO 1.15.x Documentation](https://wiki.lyrasis.org/display/VIVODOC115x/Exploring+VIVO) (LYRASIS wiki)
- [Logging in to VIVO](https://wiki.lyrasis.org/display/VIVODOC115x/Logging+in+to+VIVO)
- [Using VIVO](https://wiki.lyrasis.org/display/VIVODOC115x/Using+VIVO)
- [Navigating VIVO](https://wiki.lyrasis.org/display/VIVODOC115x/Navigating+VIVO)
- [Using Search](https://wiki.lyrasis.org/display/VIVODOC115x/Using+Search)
- [Using Visualizations](https://wiki.lyrasis.org/display/VIVODOC115x/Using+Visualizations)
