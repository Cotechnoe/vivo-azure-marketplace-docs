# Image 1.2.0 — Wiki review package

This directory contains a **review copy**, not an additional deployment guide or the published Wiki. The proposed pages keep their existing English/French filenames and Wiki link syntax. Merging this repository's pull request does **not** publish these pages to the separate GitHub Wiki repository.

Related tracking: [documentation issue #5](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/issues/5). That issue remains open for delivery and outstanding validations.

## Review contents

- [English Home](pages/Home.md) and [French Home](pages/fr_Home.md): dated release status, versions and verification limits.
- [English deployment guide](pages/Deploying-from-Marketplace.md) and [French deployment guide](pages/fr_Deploying-from-Marketplace.md): intended Custom data path, separate from direct ARM deployment.
- [English configuration guide](pages/Configuring-VIVO.md) and [French configuration guide](pages/fr_Configuring-VIVO.md): active configuration, administration, backups and costs.
- [English post-deployment checks](pages/Post-Deployment-Verification.md) and [French post-deployment checks](pages/fr_Post-Deployment-Verification.md): diagnostic and first-login test limits.
- The other files in [pages/](pages/) complete the eleven language pairs. `_Sidebar.md` is copied unchanged to preserve the navigation context.
- [wiki.patch](wiki.patch) contains the actual changes to 22 Wiki pages, relative to the base below.
- [manifest.json](manifest.json) records the base commit and SHA-256 digests of the base/proposed pages and patch. Copies in this package are byte-for-byte identical to the proposed local Wiki files.

## Wiki base and later integration

- Source: `https://github.com/Cotechnoe/vivo-azure-marketplace-docs.wiki.git`
- Base branch: `master`
- Base commit: `575d285ca184544d7da98273005653f09c6ee522`

Before a separately authorized Wiki integration, re-read the Wiki's remote state and inspect local changes. Do not overwrite an existing worktree, reset it or assume that the base is still current. Check the patch against the intended base and compare the resulting page digests with the manifest. If the Wiki has advanced, reconcile the changes and repeat validation instead of applying the old proposal blindly.

The preparation of this PR verifies the patch in a temporary repository created from the recorded base and compares every resulting page with the snapshots. It performs no Wiki push. Publication uses the separate [GitHub Wiki Git workflow](https://docs.github.com/en/communities/documenting-your-project-with-wikis/adding-or-editing-wiki-pages#adding-or-editing-wiki-pages-locally) only after the applicable authorization.

Coordinate the updated root README links with that later Wiki publication: the new release-status anchors in those links are not yet present in the published Wiki. Review the final rendered Wiki and language navigation after publication; a repository preview is not the Wiki renderer.

## Validation and limits

- `git diff --check` for the documentation and Wiki changes.
- `make help` and dry runs of `diag`, `set-dns` and `certbot` with example arguments.
- `bash tests/test-certbot.sh` with mocked SSH, Certbot, timer/cron and OpenSSL commands.
- Local checks of 275 internal Wiki/README links and anchors, language pairing and corresponding command blocks.
- YAML parsing and `bash -n` for the initial configuration assignments; no cloud-init/Marketplace end-to-end validation.
- Four current upstream sample RDF files parsed, without import into VIVO.
- The 14 November 2026 external-link pass plus the two Azure Custom data references checked 51 URLs: 31 succeeded, 19 returned 403 and one timed out. Blocked responses are not treated as deleted links.

The original image tests do not establish browser certificate trust, new-account first-login/password-change behavior, general VIVO functional correctness, backup recovery or workload capacity. Partner Center certification reported by the publisher is distinct from the deferred CTT report. The policy file, operational scripts, ARM and Partner Center are outside this revision.
