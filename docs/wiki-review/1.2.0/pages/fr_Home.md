# VIVO Knowledge Graph — Documentation Azure Marketplace

> 🇬🇧 This page is also available in English: [[Home]]

Bienvenue dans la documentation officielle de **VIVO Knowledge Graph** déployé via le Microsoft Azure Marketplace.

VIVO est une plateforme open source de mise en réseau de la recherche, utilisée par les universités et les institutions de recherche pour représenter, gérer et partager des données scientifiques sous forme de graphe de connaissances sémantique.

---

## Image 1.2.0 — statut et vérifications

| Élément | Statut vérifié ou rapporté au 14 novembre 2026 |
| --- | --- |
| Image de préversion | **1.2.0**, Ubuntu **24.04 LTS** ; VIVO et Vitro **1.16.0** |
| Pile incluse | Java 21, Tomcat 9, Solr 9, Jena TDB1 et NGINX ; configuration et administration continue nécessaires |
| Marketplace | Certification et création de préversion réussies selon la confirmation de l'éditeur et la capture Partner Center ; Go live en attente. La capture n'indique pas elle-même la version d'image. |
| Offre publique | La fiche observée ce jour décrivait encore Ubuntu 22.04 ; confirmez l'image réellement sélectionnée avant de déployer. |
| Contrôles réalisés | Packaging/provenance de l'image et OS/services vérifiés ; smoke réseau 10/10, Chromium 3/3 et population par formulaires Firefox 1/1 réussis sur une VM issue de l'image exacte. |
| Limites | SPARQL exigeait une authentification. TLS utilisait un certificat autosigné. La population par formulaires omettait des sujets source incomplets et une relation de lieu de publication non prise en charge ; elle ne constituait pas un import RDF identique. |
| Certification Test Tool | Rapport CTT officiel différé ; la certification Partner Center ne remplace pas ce rapport. |

Ces résultats ne démontrent pas la validation fonctionnelle générale de VIVO, la confiance TLS du navigateur, la capacité de charge ni le parcours Marketplace complet. Le parcours prévu pour la configuration initiale de la 1.2.0 utilise Custom data ; consultez [[fr_Deploying-from-Marketplace]] pour les vérifications de déploiement et [[fr_Configuring-VIVO]] pour l'exploitation et les sauvegardes. Une nouvelle VM ne migre pas automatiquement les données ou la configuration d'une instance existante.

---

## Démarrage rapide

Vous souhaitez vérifier l'offre avant de planifier un déploiement complet ? Commencez par l'[[Évaluation rapide|fr_Quick-Start-Evaluation]]. Elle utilise un environnement temporaire, réservé aux tests, et inclut l'étape de suppression.

Pour un déploiement complet, VIVO est disponible directement depuis le [Microsoft Azure Marketplace](https://azuremarketplace.microsoft.com). Suivez ces étapes :

| Étape | Description | Page |
|-------|-------------|------|
| 1 | Sélectionner l'image et confirmer sa méthode de configuration | [Déployer VIVO depuis Azure Marketplace](fr_Deploying-from-Marketplace) |
| 2 | Se connecter à la VM via SSH | [Connexion SSH](fr_SSH-Connection) |
| 3 | Vérifier que les services sont en cours d'exécution | [Vérification post-déploiement](fr_Post-Deployment-Verification) |
| 4 | Vérifier la confiance du certificat HTTPS | [Certificat HTTPS / TLS](fr_HTTPS-TLS-Certificate) |
| 5 | Configurer les paramètres VIVO | [Configuration de VIVO](fr_Configuring-VIVO) |
| 6 | Charger des données d'exemple pour explorer les fonctionnalités | [Chargement des données d'exemple](fr_Loading-Sample-Data) |
| 7 | Explorer l'interface VIVO | [Explorer VIVO](fr_Exploring-VIVO) |
| 8 | Résoudre les problèmes courants | [Dépannage](fr_Troubleshooting) |

---

## Vue d'ensemble de l'architecture

```text
Client -- HTTPS --> NGINX -- HTTP local --> Tomcat / VIVO
                                           |-- Jena TDB1 : stockage RDF
                                           |-- Solr : index de recherche
/data : VIVO home, magasins RDF, données Solr et journaux
```

L'image configure UFW pour refuser l'accès externe à Tomcat (8080) et Solr (8983). Vérifiez aussi les règles NSG Azure effectives du déploiement : limitez SSH (22) aux sources de confiance, ouvrez le Web selon le besoin et gardez 8080/8983 privés. Le DNS, le disque de données séparé et les règles NSG dépendent du déploiement ; vérifiez leur présence.

---

## Paramètres de déploiement

Ces noms de paramètres proviennent du modèle ARM de référence ; ce ne sont pas des champs à attendre dans l'assistant VM Marketplace. Le guide de déploiement décrit le parcours Custom data prévu pour l'image 1.2.0, sans présenter l'assistant Marketplace complet comme testé. Consultez [[fr_Deploying-from-Marketplace]] pour les limites de vérification et [[fr_Post-Deployment-Verification#première-connexion-de-ladministrateur-vivo]] pour la première connexion.

| Paramètre | Description | Exemple |
|-----------|-------------|---------|
| `adminUsername` | Nom d'utilisateur administrateur SSH de la VM | `azureuser` |
| `adminPublicKey` | Clé publique SSH (format OpenSSH) | `ssh-ed25519 AAAA...` |
| `vmSize` | Taille de la VM Azure | À choisir selon la charge |
| `dataDiskSizeGB` | Taille du disque de données pour le stockage VIVO | À dimensionner selon la charge |
| `sshSourceIP` | CIDR autorisé pour l'accès SSH | CIDR de confiance |
| `vivoNamespace` | URI de base RDF pour les entités VIVO | `http://vivo.monuniversite.ca/individual/` |
| `vivoAdminEmail` | Courriel de connexion de l'administrateur VIVO | `vivo_root@monuniversite.ca` |
| `vivoLanguages` | Langue(s) supportée(s) | `en_US` ou `en_US,fr_CA` |
| `vivoLanguageFilter` | Activer le filtre de langue RDF | `false` |

---

## Pages du wiki

- [[Évaluation rapide|fr_Quick-Start-Evaluation]] — Déployer un environnement de test temporaire et vérifier que VIVO s'ouvre
- [[Connexion SSH|fr_SSH-Connection]] — Comment se connecter à la VM avec une clé PEM
- [[Vérification post-déploiement|fr_Post-Deployment-Verification]] — Valider que tous les services fonctionnent correctement
- [[Certificat HTTPS / TLS|fr_HTTPS-TLS-Certificate]] — Provisionnement du certificat TLS, Let's Encrypt, renouvellement et certificats personnalisés
- [[Configuration de VIVO|fr_Configuring-VIVO]] — Mettre à jour l'espace de noms, le courriel admin, les langues et autres paramètres
- [[Chargement des données d'exemple|fr_Loading-Sample-Data]] — Charger le jeu de données d'exemple VIVO (avec et sans i18n)
- [[Explorer VIVO|fr_Exploring-VIVO]] — Naviguer dans l'interface, rechercher, parcourir les profils et utiliser l'administration du site
- [[Dépannage|fr_Troubleshooting]] — Erreurs courantes et leurs solutions
- [[Support|fr_Support]] — Canaux de support de l'éditeur et de la communauté, coordonnées

---

## Langues disponibles

Les pages suivantes sont également disponibles en anglais / The following pages are also available in English:

| Page (français) | English |
|-----------------|---------|
| [Accueil](fr_Home) | [Home](Home) |
| [Évaluation rapide](fr_Quick-Start-Evaluation) | [Quick Start Evaluation](Quick-Start-Evaluation) |
| [Déployer VIVO depuis Azure Marketplace](fr_Deploying-from-Marketplace) | [Deploying from Marketplace](Deploying-from-Marketplace) |
| [Connexion SSH](fr_SSH-Connection) | [SSH Connection](SSH-Connection) |
| [Vérification post-déploiement](fr_Post-Deployment-Verification) | [Post-Deployment Verification](Post-Deployment-Verification) |
| [Certificat HTTPS / TLS](fr_HTTPS-TLS-Certificate) | [HTTPS / TLS Certificate](HTTPS-TLS-Certificate) |
| [Configuration de VIVO](fr_Configuring-VIVO) | [Configuring VIVO](Configuring-VIVO) |
| [Chargement des données d'exemple](fr_Loading-Sample-Data) | [Loading Sample Data](Loading-Sample-Data) |
| [Explorer VIVO](fr_Exploring-VIVO) | [Exploring VIVO](Exploring-VIVO) |
| [Dépannage](fr_Troubleshooting) | [Troubleshooting](Troubleshooting) |
| [Support](fr_Support) | [Support](Support) |

---

## Ressources

- [VIVO Project](https://vivoweb.org/)
- [Documentation VIVO](https://wiki.lyrasis.org/display/VIVODOC)
- [Azure Marketplace](https://azuremarketplace.microsoft.com)
- [Support](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki/fr_Support) — Contacter l'éditeur ou la communauté VIVO
