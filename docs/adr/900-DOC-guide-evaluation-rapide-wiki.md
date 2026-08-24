---
adr: 900
title: "Guide d'evaluation rapide dans le Wiki"
status: "proposed"
date: 2026-08-24
superseded_by: null
replaces: null
related_adrs: [0]
related_issues: []

classification:
  lifecycle: "proposed"
  domain: "business"
  impact: "low"
  quality:
    - "usability"
    - "maintainability"
    - "cost"
  reversibility: "easy"
  scope: "operational"
  tech_areas:
    - "documentation"
    - "azure"
    - "vivo"

tags: ["documentation", "wiki", "azure-marketplace", "evaluation"]
stakeholders: ["@vivo-marketplace"]
effort: "low"
---

# ADR 900: Guide d'évaluation rapide dans le Wiki

## 📊 Vue d'Ensemble

| Attribut | Valeur |
|----------|--------|
| **Statut** | 🔄 Proposé |
| **Date Décision** | 2026-08-24 |
| **Référence de processus** | [ADR-000](./000-META-processus-creation-adr.md) |
| **Impact** | Faible |
| **Effort d'implémentation** | Faible |
| **Risque technique** | Faible |

---

## 🎯 Contexte & Problème

Le Wiki propose un guide complet de deploiement, destine aux utilisateurs qui configurent une instance durable. Un utilisateur qui souhaite seulement verifier que l'offre Azure Marketplace fonctionne doit parcourir des choix de dimensionnement, de securite et d'exploitation qui ne sont pas necessaires a cette premiere evaluation.

Un guide raccourci est utile seulement s'il ne devient pas une seconde procedure de production, ne contredit pas le parcours Marketplace actuel et peut etre trouve dans les deux langues du Wiki.

Les contraintes sont les suivantes :

- conserver le Wiki bilingue, avec une paire de pages ayant le meme suffixe de fichier ;
- suivre les conventions de titre, lien de langue, separateur et navigation des pages existantes ;
- utiliser les champs de l'assistant Marketplace plutot qu'un fichier `Custom data` fourni par l'utilisateur ;
- signaler qu'une VM `Standard_D2s_v3` et un disque de 64 Go sont reserves aux tests ;
- inclure une suppression explicite du groupe de ressources pour limiter les frais Azure ;
- renvoyer vers le guide complet pour toute instance durable ou tout chargement de donnees.

Sans cette decision, le Wiki risque de presenter soit un parcours d'evaluation incomplet, soit deux guides de deploiement concurrents et incoherents.

## ✅ Décision

Creer une paire de pages Wiki dediee a l'evaluation rapide :

- `Quick-Start-Evaluation.md` ;
- `fr_Quick-Start-Evaluation.md`.

Chaque page doit commencer par le lien vers son equivalent linguistique, puis decrire le flux minimal suivant : ouvrir l'offre, renseigner les champs essentiels, creer l'instance, attendre l'initialisation, ouvrir le FQDN Azure et supprimer le groupe de ressources apres l'essai.

Le guide ne doit pas decrire le dimensionnement de production, l'administration avancee, le chargement de donnees reelles ou une garantie d'emission du certificat TLS. Ces sujets restent dans les pages specialisees existantes.

Les pages doivent etre referencees dans `Home.md`, `fr_Home.md` et `_Sidebar.md` avec un libelle coherent dans chaque langue.

## 📊 Matrice de Décision Quantifiée

| Critere | Poids | Ajouter une section au guide complet | Publier une page non liee | Paire de pages liees depuis le Wiki |
|---------|-------|--------------------------------------|---------------------------|-------------------------------------|
| Simplicite pour une evaluation | 35 % | 5/10 | 7/10 | 9/10 |
| Separation production/evaluation | 30 % | 4/10 | 8/10 | 9/10 |
| Coherence bilingue et navigation | 20 % | 7/10 | 3/10 | 9/10 |
| Maintenabilite | 15 % | 7/10 | 4/10 | 8/10 |
| **Score pondere** | **100 %** | **5.15** | **6.20** | **8.90** |

## ⚖️ Conséquences

### ✅ Positives

- Un utilisateur peut verifier le chemin Marketplace avec des ressources explicitement reservees aux tests.
- Le guide complet conserve son role de reference pour un deploiement durable.
- Les deux langues et les chemins de navigation restent synchronises.
- La suppression explicite du groupe de ressources limite les frais apres l'essai.

### ⚠️ Négatives & Mitigations

| Risque | Mitigation |
|--------|------------|
| Divergence entre les deux guides | Les deux pages renvoient au guide complet et sont revues a chaque changement du parcours Marketplace. |
| Instance d'evaluation utilisee en production | Le guide affiche les limites de taille, de stockage et de donnees des la section de prerequisites. |
| Evolution de l'offre Marketplace | Les valeurs et le comportement de premier demarrage sont verifies contre le modele de deploiement avant modification. |

## 🔄 Alternatives Considérées

### Ajouter un encart au guide de deploiement complet

Rejete : le lecteur doit toujours filtrer les recommandations de production et les etapes d'exploitation qui ne servent pas a une evaluation rapide.

### Publier une page unique sans navigation ni traduction

Rejete : cette option ne respecte pas la structure bilingue du Wiki et rend le guide difficile a decouvrir.

## 🚀 Plan d'Implémentation

| Phase | Action | Validation |
|-------|--------|------------|
| 1 | Creer les pages anglaise et francaise avec le meme suffixe | Les liens de langue resolvent vers la page correspondante |
| 2 | Ajouter les liens dans les accueils et la barre laterale | Les deux parcours sont visibles dans la navigation |
| 3 | Verifier le contenu contre le modele Marketplace | Aucun `Custom data` utilisateur ni acces par IP n'est prescrit |
| 4 | Revoir le diff Markdown | `git diff --check` reussit |

## 🎯 Critères de Succès & Validation

- Les deux pages utilisent les conventions de titre, de lien de langue et de navigation du Wiki.
- Le guide indique clairement que l'environnement est temporaire et reserve aux tests.
- Le parcours utilise le FQDN Azure et ne promet pas que le certificat TLS sera emis avec succes.
- Les liens vers le guide complet, le certificat TLS et la verification post-deploiement sont presents.
- La validation Markdown ne signale aucune erreur d'espacement.

## 🔗 Traçabilité & Liens

- [ADR-000 - Processus de Creation et Gestion des ADR](./000-META-processus-creation-adr.md)
- [Index des ADR](./README.md)
- Wiki : `Quick-Start-Evaluation.md` et `fr_Quick-Start-Evaluation.md`