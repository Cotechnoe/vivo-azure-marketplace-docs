---
adr: 3
title: "Création et usage des GitHub Issues"
status: "accepted"
date: 2026-06-26
superseded_by: null
replaces: null
related_adrs: [0, 2]
related_issues: []
classification:
  lifecycle: "accepted"
  domain: "meta"
  impact: "medium"
  quality:
    - "maintainability"
    - "reliability"
    - "compliance"
    - "usability"
  reversibility: "easy"
  scope: "tactical"
  tech_areas:
    - "git"
    - "github"
    - "documentation"
    - "planning"
tags: ["github", "issues", "triage", "workflow", "templates"]
stakeholders: ["@dev-team", "@architecture-team"]
effort: "low"
---

# ADR 003 : Création et usage des GitHub Issues

## 📋 Vue d'ensemble

| Attribut | Valeur |
|----------|--------|
| **Statut** | ✅ Accepté |
| **Date de décision** | 2026-06-26 |
| **Dernière révision** | 2026-07-28 |
| **Impact** | 🟡 Moyen |
| **Domaine** | META |
| **Réversibilité** | 🟢 Facile |
| **Portée** | Gouvernance du suivi du travail |

---

## 🎯 Contexte

Le dépôt `vivo-marketplace` structure son travail autour d'ADR, de documentation d'exploitation et de certification, d'issues GitHub actionnables, d'un README racine et de scripts de build, de déploiement et de validation Azure. Sans règles explicites, la qualité des GitHub Issues peut devenir hétérogène :

- titres peu précis ;
- périmètres trop larges (par exemple : « finaliser toute la certification Marketplace ») ;
- critères d'acceptation absents ;
- liens manquants vers ADR, commit, branche de travail, script d'infrastructure ou documentation ;
- confusion entre une demande d'action (issue), une décision durable (ADR) et une question ouverte (discussion).

La documentation officielle GitHub positionne les issues comme l'unité standard pour **planifier, discuter et tracer** le travail, avec des capacités natives de :

- labels, assignees, milestones et types ;
- sub-issues et dépendances ;
- templates et formulaires d'issue ;
- intégration avec GitHub Projects.

GitHub documente également que l'interface peut suggérer des doublons pendant la
création d'une issue, et que ces suggestions ne bloquent pas la création.

Pour ce dépôt, le travail est suivi par issues puis intégré directement dans
`main`, sans PR locale. Un format homogène des issues améliore la traçabilité,
réduit les ambiguïtés de pilotage et facilite la rédaction ultérieure des
propositions de contribution si un sujet devait être porté en amont.

---

## ✅ Décision

Nous décidons d'utiliser les **GitHub Issues comme support canonique de suivi du travail actionnable** dans ce dépôt, selon les règles suivantes. Une issue doit être créée à partir de faits vérifiés et reliée, quand pertinent, aux ADR, user stories, commits, branches de travail et preuves de validation. Dans ce dépôt, l'intégration se fait par merge direct dans `main`, sans PR locale.

### 1. Rôle d'une issue

Une issue doit représenter **un besoin, un problème ou un résultat actionnable clairement identifiable**.

Une issue est adaptée pour :

- une user story (par exemple : « déployer une VM VIVO utilisable dans Azure Marketplace ») ;
- un bug (par exemple : « le smoke test TLS échoue après le déploiement de la VM ») ;
- une tâche technique (par exemple : « ajouter une vérification de sécurité au provisioning Packer ») ;
- une action de conformité ou de qualité (par exemple : « expurgation des journaux dans le provider mock ») ;
- un travail de documentation nécessitant une sortie vérifiable.

Une issue ne doit **pas** servir de substitut à :

- une discussion exploratoire longue (utiliser GitHub Discussions ou une note dans `docs/`) ;
- une question de support sans action attendue ;
- une décision d'architecture durable, qui relève d'un ADR sous `docs/adr/`.

### 2. Vérification préalable obligatoire

Avant d'ouvrir une issue, le rédacteur doit vérifier le contexte minimal :

- lire les artefacts sources pertinents : README racine, ADR, guide de déploiement,
  script de validation, fichier d'infrastructure ou issue existante ;
- rechercher les issues existantes avec les mots-clés discriminants : phase,
  user story, endpoint, classe, ADR, symptôme ou livrable ;
- réutiliser, commenter ou mettre à jour une issue existante si le sujet est déjà
  couvert ;
- signaler explicitement toute incertitude restante au lieu de la présenter comme
  un fait.

Cette règle applique les principes de vérification documentaire définis dans
l'[ADR-001](./001-META-definition-projet-vivo-marketplace.md) aux GitHub Issues :
un agent IA ne doit pas déduire qu'une phase est terminée, qu'un script a réussi
ou qu'une issue est absente sans vérification locale ou GitHub.

### 3. Granularité

Chaque issue doit viser **un seul résultat principal**.

Si le sujet devient trop large (par exemple : « implémenter la Phase 3 — Index hybride »), il doit être découpé en :

- plusieurs issues (une par livrable identifiable) ;
- sub-issues ;
- ou dépendances explicites entre issues.

Une issue ne doit pas couvrir plusieurs jalons ou livrables majeurs simultanément.
Quand un sujet s'inscrit dans un plan historique ou un epic plus large, le titre
et le corps doivent distinguer explicitement le resultat reellement couvert.

### 4. Contenu minimal obligatoire

Toute nouvelle issue doit contenir, au minimum :

- un **titre concis et orienté résultat** ;
- un **contexte** ou problème à résoudre ;
- un **objectif attendu** ;
- des **critères d'acceptation** vérifiables ;
- les **références dépôt** utiles : README racine, ADR, documentation de certification,
  scripts concernés, fichiers Packer/Bicep/Docker et issues liées ;
- les **dépendances** connues (autres issues, ADR à produire, ordre de merge ou dépendance technique).

Quand pertinent, l'issue doit aussi préciser :

- le jalon, l'epic, l'issue parente ou le contexte historique concerne, si cela aide a la tracabilite ;
- le périmètre hors-scope ;
- la stratégie de validation (tests smoke Playwright, validation ARM/Bicep,
  contrôles de sécurité VM ou vérification manuelle Azure) ;
- les preuves attendues pour la clôture.

Pour un travail non trivial, l'issue doit aussi inclure un **plan de réalisation**
par tranches, avec sortie attendue et validation ciblée pour chaque tranche.

#### Modèle recommandé

````markdown
## Objectif
[Résultat attendu en une phrase]

## Contexte vérifié
- Source 1 : [Plan, ADR, US, issue, fichier]
- Source 2 : [Autre ancrage vérifié]

## Périmètre inclus
- [ ] [Livrable 1]
- [ ] [Livrable 2]

## Hors périmètre
- [Élément explicitement exclu]

## Plan de réalisation
### Tranche 1 — [Nom]
- [ ] [Action]
**Validation ciblée :** [test, commande, revue, preuve]

## Critères d'acceptation
```gherkin
Étant donné ...
Quand ...
Alors ...
```

## Definition of Done
- [ ] Tests ou validations exécutés
- [ ] Documentation mise à jour si nécessaire
- [ ] ADR relié ou amendé si décision durable
- [ ] Preuves de validation ajoutées en commentaire avant clôture

## Références
- [ADR ou fichier]
- [Issue liée, commit ou branche]
````

### 5. Métadonnées GitHub

Les métadonnées GitHub doivent être utilisées pour éviter de surcharger le texte libre :

- **labels** pour classifier (`bug`, `documentation`, `security`, `azure`, `packer`, `vm`, `marketplace`, `certification`, `triage`, `drift`, etc.) ;
- **assignee** pour signaler le porteur principal ;
- **milestone** pour rattacher l'issue à un livrable, un epic ou un jalon historique du projet ;
- **project** si un tableau GitHub Projects est utilisé ;
- **issue type** si l'organisation GitHub l'active.

Les labels, milestones et types ne doivent pas être inventés par un agent IA. Si
la liste réelle n'a pas été vérifiée, il faut omettre la metadata ou vérifier les
valeurs disponibles avant création.

#### Création automatisée sur dépôt privé

Lorsqu'une issue est créée par automatisation sur un dépôt privé, l'agent doit
vérifier l'identité authentifiée et l'accès au dépôt avant la création. Il utilise
en priorité le connecteur GitHub courant qui permet la création ou mise à jour
d'issue. Si cette opération échoue alors que l'accès au dépôt est vérifié, il
utilise `gh issue create` comme solution de repli.

Un message `Repository not found` retourné par un ancien endpoint de création ne
prouve ni l'absence du dépôt ni l'absence d'autorisation. L'agent ne doit pas
répéter cet endpoint : il vérifie l'accès avec une lecture GitHub ou `gh repo
view`, puis utilise le connecteur courant ou le repli CLI. Le titre, le corps et
les métadonnées préparés doivent être conservés pour éviter une création
partielle ou divergente.

### 6. Liens de traçabilité

Toute issue importante doit pouvoir être reliée à ses artefacts associés :

- ADR si l'issue déclenche ou met en œuvre une décision durable ;
- branche Git dédiée à l'issue quand une mise en œuvre est réalisée dans le dépôt ;
- commit ou tag notable ;
- merge effectif dans `main` ;
- éventuelle contribution amont vers VIVO, Vitro ou un autre projet open source si le sujet quitte ce dépôt ;
- documentation de test ou de validation.

Par défaut, une issue livrée dans ce dépôt doit être réalisée dans sa propre
branche Git, créée depuis `main` et dédiée à ce seul sujet jusqu'à son
intégration. Le nom de branche doit permettre d'identifier clairement l'issue ou
son livrable principal, par exemple `issue-42-adr-github-workflow` ou
`docs/issue-42-adr-github-workflow`.

Cette règle vise à garantir :

- une traçabilité simple entre issue, commits, validations et merge ;
- un périmètre de livraison isolé ;
- une vérification explicite que les livrables ont bien rejoint `main`.

Dans ce dépôt, l'intégration se fait sans PR locale : le merge dans `main` et le
commentaire de validation dans l'issue constituent la preuve de clôture.

### 7. Templates et formulaires

Quand le dépôt activera des templates d'issues, ceux-ci devront suivre les bonnes pratiques GitHub :

- placement dans `.github/ISSUE_TEMPLATE/` ;
- usage de formulaires YAML pour les cas récurrents ;
- présence des clés minimales `name`, `description` et `body` pour les issue forms YAML ;
- champs structurés pour les bugs, demandes fonctionnelles, tâches d'ADR et tâches d'infrastructure ou de certification ;
- `config.yml` pour guider le chooser ;
- `blank_issues_enabled: false` recommandé si les formulaires couvrent correctement les besoins ;
- `contact_links` pour rediriger les demandes qui ne relèvent pas d'une issue
  (par exemple, questions générales sur VIVO ou Vitro vers leurs canaux officiels).

### 8. Issue vs Discussion vs ADR

| Type | Quand l'utiliser |
|------|------------------|
| **Issue** | Travail actionnable, livrable identifiable, critères d'acceptation vérifiables |
| **Discussion** | Exploration, question ouverte, choix non encore cadré |
| **ADR** | Décision architecturale durable avec alternatives, conséquences et traçabilité |

Si le sujet ne porte pas encore sur une action clairement cadrée, il doit être traité dans une discussion ou reformulé avant ouverture d'issue. Si la décision relève d'une orientation durable (vocabulaire RDF, structure de modules, posture sécurité, contribution amont), un ADR est requis en complément ou à la place de l'issue.

### 9. Suivi et clôture

Une issue doit rester à jour pendant le travail : commentaires de tranche,
commits importants, décisions découvertes, validations exécutées et risques
restants.

Une issue de réalisation n'est considérée complète et closable que lorsque ses
livrables sont effectivement intégrés dans `main`. Une implémentation présente
uniquement sur une branche de travail, même poussée sur `origin`, ne suffit pas
à considérer l'issue comme terminée.

Avant clôture, ajouter un commentaire de validation avec les commandes, tests,
commits ou limites connues. Si l'issue est fermée pour une autre raison que la
complétion, utiliser la raison disponible appropriée dans GitHub : doublon,
non-planifié ou équivalent selon l'interface.

Avant de fermer une issue comme terminée, vérifier explicitement au moins les
points suivants :

- la branche dédiée à l'issue a été mergée dans `main` ;
- les livrables attendus sont présents dans `main` ;
- les preuves de validation ou limites connues ont été ajoutées en commentaire ;
- les références de traçabilité utiles (branche, commits, documentation)
  sont accessibles depuis l'issue.

Si le travail est terminé sur une branche mais pas encore mergé dans `main`,
l'issue doit rester ouverte avec un commentaire indiquant l'état réel : prête à
merger directement dans `main` ou bloquée.

---

## 📊 Matrice de décision quantifiée

| Critère | Poids | Issues libres | Plan/ADR seuls | Outil externe | Issues structurées + traçabilité |
|---------|-------|---------------|----------------|---------------|----------------------------------|
| **Traçabilité besoin → décision → merge main** | 30 % | 4/10 | 6/10 | 7/10 | 9/10 |
| **Fiabilité / non-hallucination** | 25 % | 4/10 | 6/10 | 6/10 | 9/10 |
| **Maintenabilité et contribution amont** | 20 % | 5/10 | 7/10 | 6/10 | 9/10 |
| **Simplicité opérationnelle** | 15 % | 9/10 | 4/10 | 4/10 | 8/10 |
| **Intégration native GitHub** | 10 % | 8/10 | 3/10 | 3/10 | 10/10 |
| **Score total pondéré** | 100 % | **5.35** | **5.60** | **5.70** | **8.95** |

```text
Issues libres:                    (4*0.30) + (4*0.25) + (5*0.20) + (9*0.15) + (8*0.10) = 5.35
Plan/ADR seuls:                   (6*0.30) + (6*0.25) + (7*0.20) + (4*0.15) + (3*0.10) = 5.60
Outil externe:                    (7*0.30) + (6*0.25) + (6*0.20) + (4*0.15) + (3*0.10) = 5.70
Issues structurées + traçabilité: (9*0.30) + (9*0.25) + (9*0.20) + (8*0.15) + (10*0.10) = 8.95
```

---

## ⚖️ Conséquences

### Positives

| Bénéfice | Métrique cible | Mesure |
|----------|----------------|--------|
| Issues plus actionnables | 100 % des nouvelles issues importantes ont objectif, périmètre et critères d'acceptation | Revue de triage |
| Moins de doublons | Recherche explicite avant création | Historique de l'issue ou note de création |
| Traçabilité renforcée | Issues reliées aux ADR, commits, user stories ou fichiers pertinents | Liens dans le corps ou commentaires |
| Meilleure clôture | Preuves de validation avant fermeture | Commentaire final d'issue |
| Alignement non-hallucination | Faits projet vérifiés avant rédaction | Références locales ou GitHub |

### Négatives

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| Rédaction plus longue | 🟡 Moyen | 🟡 Moyen | Modèle minimal et templates GitHub |
| Issues trop lourdes pour de petits changements | 🟢 Faible | 🟡 Moyen | Adapter la longueur au risque ; garder les petites issues concises |
| Sur-découpage du backlog | 🟡 Moyen | 🟡 Moyen | Utiliser une issue parent avec tranches quand les validations restent communes |
| Metadata GitHub inventée ou obsolète | 🟡 Moyen | 🟡 Moyen | Vérifier labels, types et milestones avant usage |
| Confusion phase/tranche | 🟡 Moyen | 🟡 Moyen | Titre spécifique et note de cadrage en tête d'issue |

---

## 🔄 Alternatives considérées

### Alternative 1 : laisser les issues totalement libres

**Description** : chaque contributeur rédige les issues comme il le souhaite.

**Avantages** : peu de friction initiale ; compatible avec l'usage GitHub par défaut.

**Rejetée parce que** : la qualité devient hétérogène, la recherche de doublons
reste implicite et la traçabilité est insuffisante pour un projet documenté par
ADR et destiné à une publication Azure Marketplace.

**Score matrice** : 5.35/10

### Alternative 2 : tracer le travail uniquement via le plan historique et les ADR

**Description** : ne pas utiliser les issues pour piloter le travail courant.

**Avantages** : moins d'outils ; décisions centralisées dans les ADR.

**Rejetée parce que** : le plan historique et les ADR fixent la direction et les décisions,
mais ne pilotent pas les validations de tranche, les bugs, les tâches concrètes
ou les commentaires de clôture.

**Score matrice** : 5.60/10

### Alternative 3 : utiliser un outil externe de suivi

**Description** : gérer le backlog hors GitHub.

**Avantages** : workflow potentiellement plus riche selon l'outil choisi.

**Rejetée parce que** : le lien avec issues, commits, labels GitHub et future
contribution amont devient plus coûteux à maintenir.

**Score matrice** : 5.70/10

### Alternative 4 : issues structurées avec traçabilité ADR/merge

**Description** : utiliser GitHub Issues avec un cadre local vérifiable.

**Retenue parce que** : cette option maximise la traçabilité tout en restant
simple et nativement intégrée à GitHub.

**Score matrice** : 8.95/10

---

## 🚀 Plan d'implémentation

| Phase | Action | Validation | Statut |
|-------|--------|------------|--------|
| 1 | Formaliser la règle avec cet ADR | ADR présent et indexé | ✅ Fait |
| 2 | Appliquer ce format aux nouvelles issues importantes | Revue de triage des nouvelles issues | 📋 À appliquer |
| 3 | Ajouter des issue templates ou forms si le volume augmente | Fichiers sous `.github/ISSUE_TEMPLATE/` | 📋 À planifier |
| 4 | Vérifier les liens issue ↔ ADR ↔ commits ↔ merge `main` | Checklist ou revue manuelle | 📋 À généraliser |
| 5 | Réviser cet ADR si GitHub modifie fortement les issue forms ou issue types | Mise à jour datée de l'ADR | 📋 Continu |

---

## 🎯 Critères de succès et validation

| Critère | Cible | Validation |
|---------|-------|------------|
| Recherche de doublon | Les nouvelles issues importantes mentionnent ou démontrent une recherche préalable | Commentaire ou historique de création |
| Objectif clair | Chaque issue importante a un objectif vérifiable | Revue de triage |
| Acceptation testable | Les critères d'acceptation sont observables ou testables | Revue avant démarrage |
| Traçabilité | Les issues liées à une décision référencent l'ADR pertinent et le merge dans `main` | Liens dans l'issue, commits ou historique Git |
| Clôture propre | Les issues fermées contiennent les preuves de validation ou la raison de non-réalisation | Commentaire final |
| Non-hallucination | Les affirmations sur l'état du projet s'appuient sur sources locales, GitHub ou documentation officielle | Revue documentaire |

---

## 🔗 Traçabilité et liens

- [ADR-000 — Processus de création des ADR](./000-META-processus-creation-adr.md)
- [ADR-001 — Définition et cadrage du projet vivo-marketplace](./001-META-definition-projet-vivo-marketplace.md)
- [ADR-000 — Processus de création des ADR](./000-META-processus-creation-adr.md)
- [GitHub Docs — About issues](https://docs.github.com/en/issues/tracking-your-work-with-issues/learning-about-issues/about-issues)
- [GitHub Docs — Creating an issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-an-issue)
- [GitHub Docs — Configuring issue templates for your repository](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository)
- [GitHub Docs — Syntax for issue forms](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)

---

## 📝 Notes et historique

| Date | Auteur | Changement | Raison |
|------|--------|------------|--------|
| 2026-08-04 | @architecture-team | Documenter la création automatisée sur dépôt privé | Éviter d'interpréter un défaut d'ancien connecteur comme une absence de dépôt ou de droits ; utiliser le connecteur courant puis `gh` en repli |
| 2026-07-28 | @architecture-team | Réalignement du workflow sans PR locale | Documenter l'intégration par merge direct dans `main` et retirer les références normatives aux PR dans ce dépôt |
| 2026-07-26 | @architecture-team | Réalignement documentaire pour vivo-marketplace | Adapter le document au suivi du build, du déploiement et de la certification Marketplace |
| 2026-07-18 | @architecture-team | Révision alignée avec ADR-000, ADR-002 et la documentation GitHub officielle | Ajouter matrice de décision, procédure opérationnelle, règles de non-hallucination et critères de clôture |
| 2026-06-26 | @architecture-team | Création initiale adaptée à vivo-marketplace | Formaliser la création et l'usage des GitHub Issues pour le suivi du build, du déploiement et de la certification Marketplace |
