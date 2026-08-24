---
adr: 900
title: "Gouvernance de l'ajout de documents dans le Wiki"
status: "proposed"
date: 2026-08-24
superseded_by: null
replaces: null
related_adrs: [0, 3]
related_issues: []

classification:
  lifecycle: "proposed"
  domain: "business"
  impact: "low"
  quality:
    - "usability"
    - "maintainability"
  reversibility: "easy"
  scope: "operational"
  tech_areas:
    - "documentation"

tags: ["documentation", "wiki", "governance"]
stakeholders: ["@vivo-marketplace"]
effort: "low"
---

# ADR 900: Gouvernance de l'ajout de documents dans le Wiki

## 📊 Vue d'Ensemble

| Attribut | Valeur |
|----------|--------|
| **Statut** | 🔄 Proposé |
| **Date Décision** | 2026-08-24 |
| **Référence de processus** | [ADR-000](./000-META-processus-creation-adr.md) |
| **Impact** | Moyen |
| **Effort d'implémentation** | Faible par document |
| **Risque technique** | Faible |

---

## 🎯 Contexte & Problème

Le Wiki est la documentation utilisateur du projet. Il est bilingue et comprend des pages thématiques reliées par `Home.md`, `fr_Home.md` et `_Sidebar.md`. Sans règle commune, l'ajout d'un document peut créer des pages difficiles à découvrir, des traductions incomplètes, des liens rompus ou des instructions qui se chevauchent.

L'ADR-000 impose de documenter les décisions structurantes. L'ajout d'un document dans le Wiki est une décision de structure documentaire : il établit ou étend un parcours utilisateur et doit donc suivre une gouvernance stable, indépendamment du sujet de la page.

## ✅ Décision

Tout nouveau document utilisateur ajouté au Wiki suit les règles suivantes.

1. **Cadrage et traçabilité** : créer une issue conformément à [ADR-003](./003-META-creation-et-usage-des-github-issues.md), décrivant le besoin, le public visé, les sources de vérité et les critères d'acceptation. L'issue référence ADR-900.
2. **Emplacement** : vérifier qu'une page existante ne couvre pas déjà le besoin. Créer une page distincte seulement si elle correspond à un parcours, une tâche ou un public clairement différencié.
3. **Bilinguisme** : toute page destinée aux utilisateurs est créée en paire `Nom-de-page.md` et `fr_Nom-de-page.md`. Chaque page commence par son titre, un lien standardisé vers l'autre langue, une introduction et un séparateur `---`.
4. **Navigation** : inscrire la page dans `Home.md`, `fr_Home.md` et `_Sidebar.md` lorsqu'elle fait partie d'un parcours utilisateur. Mettre à jour les tableaux de langues lorsque ces accueils les exposent. Lorsqu'un guide doit être accessible depuis le dépôt, ajouter ses liens bilingues à `README.md` et `README-fr.md`.
5. **Contenu factuel** : appuyer les instructions sur l'implémentation locale, l'offre Marketplace publiée ou la documentation officielle. Ne pas dupliquer une procédure concurrente ni présenter une hypothèse comme un comportement garanti.
6. **Validation** : vérifier les liens internes, la parité fonctionnelle des langues, l'absence de références obsolètes et exécuter `git diff --check` avant livraison.

ADR-900 gouverne ce processus. Il n'est pas nécessaire de créer un nouvel ADR pour chaque page ; l'issue de livraison en assure la traçabilité opérationnelle.

## 📊 Matrice de Décision Quantifiée

| Critère | Poids | Ajout non gouverné | Règles dans chaque issue | ADR de gouvernance + issue |
|---------|-------|--------------------|--------------------------|----------------------------|
| Cohérence de structure | 30 % | 3/10 | 7/10 | 9/10 |
| Traçabilité des décisions | 25 % | 2/10 | 6/10 | 9/10 |
| Maintenabilité bilingue | 25 % | 4/10 | 7/10 | 9/10 |
| Simplicité de livraison | 20 % | 9/10 | 6/10 | 8/10 |
| **Score pondéré** | **100 %** | **4.15** | **6.55** | **8.85** |

## ⚖️ Conséquences

### ✅ Positives

- Chaque document est rattaché à un besoin vérifiable et à des sources identifiées.
- La navigation et les traductions restent cohérentes à mesure que le Wiki évolue.
- Les guides spécialisés complètent les pages existantes sans les contredire.
- Les revues disposent de critères concrets pour contrôler les ajouts documentaires.

### ⚠️ Négatives & Mitigations

| Risque | Mitigation |
|--------|------------|
| Ajout de travail pour une petite page | Utiliser une issue courte ; ADR-900 évite de recréer un ADR par page. |
| Navigation trop dense | Ajouter une page à la navigation seulement lorsqu'elle correspond à un parcours utilisateur. |
| Traduction divergente | Vérifier la parité fonctionnelle avant la livraison. |

## 🔄 Alternatives Considérées

### Ajouter les pages sans règle explicite

Rejetée : les conventions ne sont alors connues que par lecture du Wiki et deviennent faciles à contourner.

### Créer un ADR pour chaque page Wiki

Rejetée : la charge de gouvernance serait disproportionnée pour une modification documentaire locale. Une issue référencée à ADR-900 apporte une traçabilité suffisante.

## 🚀 Plan d'Implémentation

| Phase | Action | Validation |
|-------|--------|------------|
| 1 | Créer l'issue de documentation et citer ADR-900 | Besoin, public, sources et critères d'acceptation présents |
| 2 | Ajouter les pages et les liens de langue | Paire de fichiers et bandeaux bilingues présents |
| 3 | Mettre à jour la navigation nécessaire | Les deux accueils, la barre latérale et les README concernés restent cohérents |
| 4 | Valider le diff | Liens vérifiés et `git diff --check` réussi |

## 🎯 Critères de Succès & Validation

- Tout nouveau document utilisateur possède une issue qui référence ADR-900.
- Les pages bilingues ont le même suffixe, des liens réciproques et une parité fonctionnelle.
- Les pages accessibles aux utilisateurs sont visibles depuis la navigation appropriée.
- Les nouveaux guides accessibles depuis le dépôt sont référencés dans `README.md` et `README-fr.md`.
- Les affirmations opérationnelles sont reliées à des sources vérifiables.
- La validation Markdown ne signale aucune erreur d'espacement.

## 🔗 Traçabilité & Liens

- [ADR-000 - Processus de Création et Gestion des ADR](./000-META-processus-creation-adr.md)
- [ADR-003 - Création et usage des GitHub Issues](./003-META-creation-et-usage-des-github-issues.md)
- [Index des ADR](./README.md)