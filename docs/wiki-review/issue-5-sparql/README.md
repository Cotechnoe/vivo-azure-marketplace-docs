# Issue #5 — SPARQL diagnostic Wiki follow-up

Review copies of the [English verification guide](pages/Post-Deployment-Verification.md) and [French verification guide](pages/fr_Post-Deployment-Verification.md), aligned with the diagnostic correction tracked in [issue #5](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/issues/5).

The main image 1.2.0 revision is already published. These two follow-up pages are **not yet published**. They describe the updated helper, distinguish older revisions, and keep the limits of the unauthenticated probe explicit. HTTP 401 with a valid Basic challenge and HTTP 403 are warnings; neither proves an authenticated query succeeded.

## Integration order

1. Review and integrate the matching `scripts/vivo-diag.sh` correction and offline tests in documentation `master`.
2. Before any separately authorized Wiki publication, check the remote and local Wiki state, review changes since base `4af5f0f3727151493de240b05a9de8dbf23dc635`, and compare the patch and page digests with [manifest.json](manifest.json). Preserve unrelated local edits.
3. Publish the two pages using the separate Wiki Git workflow, then check their rendered content, language links and anchors. A documentation PR merge does not publish the Wiki.
4. Reassess #5 after integration and publication; do not treat pending operational validations as completed.

[wiki.patch](wiki.patch) records the exact two-page change against that Wiki base. Snapshots and the patch for the earlier [image 1.2.0 review](../1.2.0/README.md) remain unchanged. No VM, DNS, certificate or Marketplace operation is part of this follow-up.
