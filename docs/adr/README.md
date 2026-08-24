# 📚 Architecture Decision Records (ADR) — vivo-marketplace

**Index central** de toutes les décisions architecturales du projet **vivo-marketplace**.

> Le projet vise à industrialiser et publier sur **Microsoft Azure Marketplace** une offre VM intégrant la solution open source **VIVO** (Vitro + vivo-solr) sur Azure, avec triplestore RDF, destinée aux universités et centres de recherche.

---

## 🗂️ Documents du Système ADR

| Document | Description |
|----------|-------------|
| **[ADR-000](./000-META-processus-creation-adr.md)** | Processus et règles de création des ADRs |
| **[TAXONOMY.md](./TAXONOMY.md)** | Classification détaillée (7 dimensions) |
| **[adr-template-ai-optimized.md](./adr-template-ai-optimized.md)** | Template à copier pour un nouvel ADR |
| **[README.md](./README.md)** | Ce fichier (index et guide rapide) |

---

## ⚡ Créer un Nouvel ADR Rapidement

```bash
# 1. Identifier la plage de catégorie (voir tableau Numérotation)
# 2. Trouver le prochain numéro disponible dans la plage
ls -1 docs/adr/2*.md | tail -1   # Exemple: bloc INFRA (200-299)

# 3. Créer le fichier depuis le template
cp docs/adr/adr-template-ai-optimized.md docs/adr/201-INFRA-nouvelle-decision.md

# 4. Rédiger, committer et mettre à jour ce README
git add docs/adr/201-INFRA-nouvelle-decision.md docs/adr/README.md
git commit -m "docs(adr): ADR-201 [INFRA] Nouvelle décision"
```

---

## 📋 Index des ADRs par Catégorie

### 🔧 META — Méta-processus (000-099)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| [000](./000-META-processus-creation-adr.md) | Processus de Création et Gestion des ADR | ✅ Accepté | 2026-02-21 | Gouvernance |
| [001](./001-META-definition-projet-vivo-marketplace.md) | Définition et Cadrage du Projet vivo-marketplace | ✅ Accepté | 2026-02-21 | Gouvernance |
| [003](./003-META-creation-et-usage-des-github-issues.md) | Création et usage des GitHub Issues | ✅ Accepté | 2026-06-26 | Gouvernance |

---

### 🏗️ ARCH — Architecture (100-199)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| [100](./100-ARCH-architecture-docker-first-vm-offer.md) | Architecture Docker-first → VM Offer Azure Marketplace | ✅ Accepté | 2026-02-22 | Architecture |

---

### ☁️ INFRA — Infrastructure Azure (200-299)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| [200](./200-INFRA-azure-infrastructure-vm-offer.md) | Infrastructure Azure — VM Offer : Compute Gallery, NSG, ARM Template, Data Disk | ✅ Accepté | 2026-02-22 | Infrastructure |

---

### 🔒 SEC — Sécurité (300-399)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| [300](./300-SEC-securite-hardening-vm-certification.md) | Sécurité VM — Hardening OS Ubuntu pour Certification Azure Marketplace | ✅ Accepté | 2026-02-22 | Sécurité |

---

### 🗄️ DATA — Données & Semantic Web (400-499)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| *(aucun ADR pour l'instant)* | | | | |

---

### 🔌 API — Intégrations & APIs (500-599)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| *(aucun ADR pour l'instant)* | | | | |

---

### ⚙️ DEVOPS — DevOps & CI/CD (600-699)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| [600](./600-DEVOPS-bootstrap-configuration-management.md) | Bootstrap et Gestion de la Configuration | ✅ Accepté | 2026-02-21 | DevOps |
| [601](./601-DEVOPS-nomenclature-scripts.md) | Nomenclature et Organisation des Scripts | ✅ Accepté | 2026-02-21 | DevOps |
| [602](./602-DEVOPS-makefile-orchestrateur.md) | Makefile comme Orchestrateur Standard | ✅ Accepté | 2026-02-21 | DevOps |
| [603](./603-DEVOPS-git-workflow-et-strategie-versioning.md) | Git Workflow et Stratégie de Versioning | ✅ Accepté | 2026-02-21 | DevOps |
| [604](./604-DEVOPS-modularisation-scripts-partages.md) | Modularisation Scripts et Élimination Duplication | ✅ Accepté | 2026-02-21 | DevOps |
| [605](./605-DEVOPS-vivo-java-tomcat-stack.md) | Stack Java et Cycle de Développement VIVO/Vitro sur Tomcat | ✅ Accepté | 2026-02-21 | DevOps |
| [606](./606-DEVOPS-vivo-installation-approach.md) | Approche d'installation de VIVO 1.16.0 | ➡️ Supersédé | 2026-02-22 | DevOps |
| [607](./607-DEVOPS-procedure-version-bump.md) | Procédure de Bumping de Version — Image VM et Fichiers de Configuration | ✅ Accepté | 2026-03-07 | DevOps |
| [608](./608-DEVOPS-registre-drift-vm-live-vs-packer.md) | Registre des Drifts VM Live ↔ Packer — Traçabilité des Hotfix à Propager | ✅ Accepté | 2026-06-10 | DevOps |

---

### 🧪 TEST — Tests & Validation (700-799)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| [700](./700-TEST-waagent-generalisation-certification-marketplace.md) | Stratégie Validation Marketplace — waagent, Généralisation VM, Certification AMAT | ✅ Accepté | 2026-02-22 | Tests |

---

### 💼 BIZ — Business & Marketplace (800-899)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| [800](./800-BIZ-publication-azure-marketplace-vm-offer.md) | Publication Offre VM sur Azure Marketplace — Conformité et Bonnes Pratiques Microsoft | ✅ Accepté | 2026-02-21 | BIZ |
| [801](./801-BIZ-strategie-documentation-marketplace.md) | Stratégie de Documentation — Offre Azure Marketplace (utilisateur final) | ✅ Accepté | 2026-03-05 | BIZ |
| [802](./802-BIZ-conformite-politiques-certification-vm-marketplace.md) | Conformité Politiques Certification VM — Mapping Microsoft Marketplace 100/200 | ✅ Accepté | 2026-06-09 | BIZ |

---

### 📚 DOC — Documentation (900-999)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| [900](./900-DOC-guide-evaluation-rapide-wiki.md) | Guide d'evaluation rapide dans le Wiki | 🔄 Proposé | 2026-08-24 | Documentation |

---

## 📊 Statistiques

| Indicateur | Valeur |
|-----------|--------|
| **Total ADRs** | 19 |
| **Acceptés** | 16 |
| **Supersédés** | 1 |
| **Proposés** | 1 |
| **Brouillons** | 0 |
| **Par Domaine** | META: 3, ARCH: 1, INFRA: 1, SEC: 1, DEVOPS: 8, TEST: 1, BIZ: 3, DOC: 1 |

---

## 🔍 Numérotation par Catégorie

| Préfixe | Plage | Domaine | Prochains disponibles |
|---------|-------|---------|----------------------|
| `META` | 000-099 | Méta-processus | 004 |
| `ARCH` | 100-199 | Architecture VIVO/triplestore | 101 |
| `INFRA` | 200-299 | Azure VM, Packer, IaC | 201 |
| `SEC` | 300-399 | TLS, NSG, conformité Marketplace | 301 |
| `DATA` | 400-499 | Triplestore RDF, Solr, ontologies | 400 |
| `API` | 500-599 | VIVO API, Solr, intégrations | 500 |
| `DEVOPS` | 600-699 | CI/CD, scripts provisioning | 608 |
| `TEST` | 700-799 | Validation Marketplace, smoke tests | 701 |
| `BIZ` | 800-899 | Offre Marketplace, licensing | 803 |
| `DOC` | 900-999 | Documentation | 901 |

---

## 🏷️ Statuts

| Emoji | Statut | Description |
|-------|--------|-------------|
| 🔄 | Brouillon / Proposé | En cours de rédaction ou en attente de validation |
| ✅ | Accepté | Décision approuvée et implémentée |
| ❌ | Rejeté | Proposition refusée (archivée pour référence) |
| ⚠️ | Déprécié | Obsolète, non remplacé |
| ➡️ | Supersédé | Remplacé par un ADR plus récent |

---

## 🔗 Ressources Projet

- [VIVO Open Source](https://vivoweb.org/)
- [Vitro GitHub](https://github.com/vivo-project/Vitro)
- [Azure Marketplace VM Offer](https://learn.microsoft.com/en-us/azure/marketplace/azure-vm-offer-setup)
- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/)

---

_Mise à jour : 2026-08-24_
