# VIVO sur Azure Marketplace

> **Version de l'image Marketplace :** VIVO [1.16.0](https://github.com/vivo-project/VIVO/releases/tag/vivo-1.16.0)

> 🇬🇧 This page is also available in English: [README.md](README.md)

**VIVO** est une plateforme open source de mise en réseau de la recherche qui crée une cartographie connectée et exploitable des travaux scientifiques de votre institution. Elle permet aux organisations académiques et de recherche de :

- **Connecter** chercheurs, publications, subventions, cours et organisations dans un graphe sémantique unifié
- **Découvrir** des opportunités de collaboration et des expertises dans différentes disciplines
- **Partager** des données via des standards ouverts (Linked Data / RDF), interopérables avec des sources externes comme ORCID, CrossRef et Wikidata

VIVO est développé par la communauté et soutenu par [LYRASIS](https://www.lyrasis.org), avec plus de 150 instances déployées dans plus de 25 pays à travers le monde.

---

## VIVO sur Microsoft Azure Marketplace

Cette offre Azure Marketplace déploie une instance VIVO entièrement configurée sur une machine virtuelle Azure dédiée. Le déploiement est automatisé via un modèle ARM qui gère :

- Le provisionnement de la VM (Ubuntu, Standard D2s v3 ou supérieur)
- L'installation de la pile VIVO + Apache Solr + Tomcat + Nginx
- La configuration spécifique à l'institution (espace de noms, identifiants admin, paramètres de langue)
- La terminaison TLS via Nginx avec un certificat Let's Encrypt provisionné automatiquement

Après le déploiement, VIVO est immédiatement accessible à l'adresse `https://<ip-publique>/`.

---

## Documentation

La documentation complète de déploiement et d'administration est disponible dans le **[wiki du projet](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Home)**.

| Page | Description | English |
|------|-------------|---------|
| [Déployer depuis le Marketplace](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Deploying-from-Marketplace) | Déployer VIVO depuis Azure Marketplace | [Deploying from Marketplace](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Deploying-from-Marketplace) |
| [Connexion SSH](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_SSH-Connection) | Se connecter à la VM avec une clé SSH | [SSH Connection](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/SSH-Connection) |
| [Vérification post-déploiement](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Post-Deployment-Verification) | Vérifier les services et accéder à VIVO | [Post-Deployment Verification](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Post-Deployment-Verification) |
| [Certificat HTTPS / TLS](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_HTTPS-TLS-Certificate) | Provisionnement Let's Encrypt, renouvellement et certificats personnalisés | [HTTPS / TLS Certificate](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/HTTPS-TLS-Certificate) |
| [Configuration de VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Configuring-VIVO) | Espace de noms, identifiants et paramètres i18n | [Configuring VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Configuring-VIVO) |
| [Chargement des données d'exemple](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Loading-Sample-Data) | Charger les données d'exemple pour explorer VIVO (avec et sans i18n) | [Loading Sample Data](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Loading-Sample-Data) |
| [Explorer VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Exploring-VIVO) | Naviguer dans l'interface, recherche, profils, administration du site | [Exploring VIVO](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Exploring-VIVO) |
| [Dépannage](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Troubleshooting) | Problèmes courants de déploiement et d'exécution | [Troubleshooting](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Troubleshooting) |
| [Support](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Support) | Canaux de support de l'éditeur et de la communauté, coordonnées | [Support](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/Support) |

---

## Notes de version — VIVO 1.16.0

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
