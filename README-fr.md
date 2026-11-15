# VIVO sur Azure Marketplace

> 🇬🇧 This page is also available in English: [README.md](README.md)

**VIVO** est une plateforme open source de mise en réseau de la recherche qui relie les profils de chercheurs, les organisations, les publications et les activités scientifiques dans un graphe de connaissances. Les institutions peuvent consulter les profils, rechercher les contenus indexés et exploiter les données RDF.

VIVO est développé par sa communauté avec le soutien de [LYRASIS](https://www.lyrasis.org). Les sources et identifiants externes comme ORCID, Crossref et Wikidata nécessitent une intégration de données adaptée ; cette image ne les connecte pas automatiquement. Les usages d'IA ou de génération augmentée par récupération (RAG) nécessitent également une intégration ou un développement supplémentaire.

## Image 1.2.0 et offre publique

L'**image 1.2.0** contient **Ubuntu 24.04 LTS**, **VIVO 1.16.0** et **Vitro 1.16.0**, avec Java 21, Tomcat 9, Solr 9, Jena TDB1 et NGINX. Ces composants sont préinstallés ; un administrateur configure et maintient l'instance déployée.

Lors de la revue de l'éditeur du 14 novembre 2026, l'image 1.2.0 était en préversion Marketplace certifiée, avec Go live en attente. La fiche publique décrivait encore Ubuntu 22.04. Confirmez l'offre, le plan et la version d'image sélectionnés au déploiement ; ni la version de l'application VIVO ni le numéro affiché dans la fiche n'identifient la version d'image. Consultez [le statut et les limites de vérification](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Home#image-120--statut-et-vérifications).

## Déployer et exploiter VIVO

Le parcours de configuration prévu pour l'image 1.2.0 utilise **Avancé → Données personnalisées (Custom data)**, d'après l'implémentation de l'image ; les essais archivés ne valident pas l'assistant Marketplace complet. Le [guide de déploiement](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Deploying-from-Marketplace) distingue ce parcours du déploiement ARM direct. Un modèle ARM ou une définition d'interface de référence ne démontre pas le fonctionnement de l'assistant VM publié.

NGINX fournit HTTPS et redirige les requêtes HTTP ordinaires vers HTTPS. Le certificat initial est autosigné ; Let's Encrypt n'est tenté que si le déploiement fournit un FQDN et si Certbot est disponible. Les essais archivés de la 1.2.0 ne démontrent pas l'obtention d'un certificat reconnu par le navigateur. Suivez le [guide TLS](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_HTTPS-TLS-Certificate) pour obtenir et vérifier un certificat adapté au déploiement.

Dimensionnez la VM et les disques selon vos données, l'indexation et l'usage ; les contrôles réalisés n'établissent ni taille minimale de production ni capacité de charge. Vérifiez le tarif du plan Marketplace et les coûts Azure de calcul, stockage, réseau et sauvegarde avant de déployer. Le contrôle d'accès, les correctifs, les certificats, les sauvegardes et la récupération relèvent de l'administration. Un déploiement dans un abonnement Azure ne garantit pas à lui seul la résidence des données ni la conformité réglementaire ; évaluez les flux de données et les services externes pour votre institution.

---

## Documentation

La documentation complète de déploiement et d'administration est disponible dans le **[wiki du projet](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Home)**.

| Page | Description | English |
|------|-------------|---------|
| [Évaluation rapide](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Quick-Start-Evaluation) | Déployer un environnement de test temporaire pour évaluer l'offre Marketplace | [Quick Start Evaluation](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Quick-Start-Evaluation) |
| [Déployer depuis le Marketplace](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Deploying-from-Marketplace) | Déployer VIVO depuis Azure Marketplace | [Deploying from Marketplace](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Deploying-from-Marketplace) |
| [Connexion SSH](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_SSH-Connection) | Se connecter à la VM avec une clé SSH | [SSH Connection](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/SSH-Connection) |
| [Vérification post-déploiement](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Post-Deployment-Verification) | Vérifier les services et accéder à VIVO | [Post-Deployment Verification](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Post-Deployment-Verification) |
| [Certificat HTTPS / TLS](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_HTTPS-TLS-Certificate) | Tentatives Let's Encrypt, vérification TLS, renouvellement et certificats personnalisés | [HTTPS / TLS Certificate](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/HTTPS-TLS-Certificate) |
| [Configuration de VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Configuring-VIVO) | Espace de noms, identifiants et paramètres i18n | [Configuring VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Configuring-VIVO) |
| [Chargement des données d'exemple](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Loading-Sample-Data) | Charger les données d'exemple pour explorer VIVO (avec et sans i18n) | [Loading Sample Data](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Loading-Sample-Data) |
| [Explorer VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Exploring-VIVO) | Naviguer dans l'interface, recherche, profils, administration du site | [Exploring VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Exploring-VIVO) |
| [Dépannage](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Troubleshooting) | Problèmes courants de déploiement et d'exécution | [Troubleshooting](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Troubleshooting) |
| [Support](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Support) | Canaux de support de l'éditeur et de la communauté, coordonnées | [Support](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Support) |

---

## Notes de version — VIVO 1.16.0

Ce résumé historique de la version amont concerne VIVO 1.16.0 ; il ne décrit pas de nouvelles fonctions de l'image 1.2.0 ni une certification fonctionnelle de l'application packagée.

> Diff complet : [vivo-1.15.1...vivo-1.16.0](https://github.com/vivo-project/VIVO/compare/vivo-1.15.1...vivo-1.16.0) (98 commits, 212 fichiers modifiés)

### Nouvelles fonctionnalités

- **Contributeurs externes aux publications et subventions** — les auteurs, éditeurs et participants aux projets peuvent désormais être représentés sous forme de VCards (personnes ou organisations externes) en plus des individus VIVO internes. Cela permet de suivre les collaborateurs qui n'ont pas de profil VIVO.
- **VCards dans le graphe de co-auteurs** — la visualisation du réseau de co-auteurs inclut maintenant les contributeurs basés sur VCard aux côtés des personnes VIVO complètes.
- **Indexeur VCard pour les autorats/éditorats** — les auteurs et éditeurs VCard externes sont désormais indexés dans Solr, les rendant découvrables via la recherche.
- **Organisations comme éditeurs** — le formulaire de saisie des éditeurs prend désormais en charge les organisations en plus des personnes.
- **Éditeur TinyMCE pour les pages HTML fixes** — l'éditeur de texte enrichi est maintenant disponible lors de la modification des pages HTML fixes (statiques) dans l'interface d'administration du site.
- **Limite configurable du réseau de co-auteurs** — de nouveaux paramètres `runtime.properties` permettent aux administrateurs de contrôler le nombre maximum de collaborateurs affichés dans la visualisation du réseau de co-auteurs.

### Améliorations

- **Méthode POST pour les grandes requêtes SPARQL** — les requêtes SPARQL dépassant les limites de longueur d'URL sont désormais envoyées via POST, évitant les erreurs `request too long`.
- **Découplage de l'installation et du déploiement** ([#4017](https://github.com/vivo-project/VIVO/pull/4017)) — le pipeline de build sépare maintenant la phase d'installation Maven du déploiement, améliorant la fiabilité CI/CD.
- **Traductions mises à jour** — nouvelles chaînes i18n ajoutées pour la case à cocher « inclure les co-auteurs externes » et les formulaires de saisie des contributeurs associés.

### Corrections de bogues

- Correction de la vérification d'autorisation lors de la réclamation d'un DOI sur une page de profil connexe.
- Correction de l'affichage du formulaire de saisie des auteurs lorsqu'une personne/VCard existante est déjà liée.
- Correction du rendu de la liste des éditeurs.
- Correction de l'affichage de la personne/VCard existante dans le formulaire « le projet a un participant ».
- Correction des liens de contact et de documentation cassés dans l'interface.

### Suppressions / modifications

- Suppression des fichiers `validation-n3` hérités ([#3994](https://github.com/vivo-project/VIVO/pull/3994)).
- Inversion de l'ordre des options de type d'URL dans le formulaire de saisie d'URL ([#3999](https://github.com/vivo-project/VIVO/pull/3999)).
- Suppression du texte superflu dans le modèle d'export CSV (VIVO-4000).

### Maintenance

- Mise à jour de `example.runtime.properties` avec des corrections et des clarifications.
- Mise à jour de `initialSiteConfig.ttl`.
- Corrections du pipeline de build Docker.
- Licence mise à jour pour 2025.

---

## Ressources

- [vivoweb.org](https://www.vivoweb.org/) — site officiel du projet VIVO
- [Documentation VIVO 1.15.x](https://wiki.lyrasis.org/display/VIVODOC115x/VIVO+1.15.x+Documentation) — wiki LYRASIS (installation, configuration, administration)
- [VIVO sur GitHub](https://github.com/vivo-project/VIVO) — code source et gestionnaire de tickets
