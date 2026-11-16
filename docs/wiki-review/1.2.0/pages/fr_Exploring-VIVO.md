# Explorer VIVO

> 🇬🇧 This page is also available in English: [[Exploring-VIVO]]

Cette page vous guide à travers l'interface VIVO après un déploiement réussi. Elle couvre la connexion, la recherche, la consultation des profils et l'utilisation des outils d'administration du site.

> Les exemples ci-dessous supposent que les [[données d'exemple|fr_Loading-Sample-Data]] ont été chargées. Sur une instance vide, les résultats de recherche seront vides jusqu'à ce que des données réelles ou d'exemple soient ajoutées.

---

## Se connecter

Naviguez vers `https://<fqdn>/` et cliquez sur **Log in** dans le coin supérieur droit. Utilisez le FQDN de la VM afin que le navigateur puisse vérifier le certificat TLS.

Utilisez le courriel et le mot de passe administrateur VIVO correspondant à votre version déployée, et non les identifiants SSH de la VM. Pour la première connexion, les limites de vérification actuelles et la sécurisation du compte, consultez [[fr_Post-Deployment-Verification#première-connexion-de-ladministrateur-vivo]].

Après la connexion, l'en-tête affiche votre nom et un lien **Site Admin** devient visible.

---

## Naviguer dans l'interface

L'en-tête VIVO fournit les points d'entrée principaux :

| Élément | Description |
|---------|-------------|
| **Barre de recherche** | Recherche plein texte sur toutes les entités VIVO |
| **Menus Browse** | Parcourir par Personnes, Organisations, Recherche, Événements, etc. |
| **Log in / nom** | Authentification et accès au profil |
| **Site Admin** | Panneau d'administration (visible des administrateurs du site uniquement) |

La page d'accueil affiche un **résumé des données** dans votre VIVO — compteurs de personnes, de publications et d'organisations.

---

## Rechercher

La barre de recherche effectue une recherche plein texte sur toutes les entités indexées.

**Essayez ces requêtes avec les données d'exemple :**

| Requête | Résultats attendus |
|---------|-------------------|
| `Chemistry` | Département et personnes et publications associées |
| `Roberts` | Membres du corps professoral avec ce nom de famille |
| `Pringle` | Un profil de chercheur spécifique |
| `grant` | Projets financés et bourses |

Les résultats de recherche affichent le type d'entité (Person, Organization, Grant, etc.), une courte description et un lien vers le profil complet.

Utilisez les **filtres** sur la gauche de la page de résultats pour affiner par classe d'entité (People, Publications, Organizations, etc.).

---

## Consulter les profils

### Profil d'une personne

Cliquez sur n'importe quelle personne dans les résultats de recherche pour ouvrir son profil. Une page de profil montre :

- Nom, titre et affiliation institutionnelle
- Domaines de recherche et mots-clés d'expertise
- Publications, bourses et distinctions
- Connexions de co-auteur et de collaborateur
- Activités d'enseignement (cours, encadrement)

### Profil d'une organisation

La page d'une organisation affiche ses membres, ses sous-organisations, ainsi que les bourses et publications associées.

---

## Affichage détaillé des propriétés (admin)

Lorsque vous êtes connecté en tant qu'administrateur du site, vous pouvez activer l'**affichage détaillé des propriétés** sur n'importe quel profil pour voir les propriétés RDF sous-jacentes utilisées par VIVO.

1. Ouvrez n'importe quel profil de personne ou d'entité
2. Cliquez sur **Turn On** en haut de la page (à côté de « Verbose Property Display »)
3. Chaque champ affiche maintenant son URI de propriété RDF aux côtés de sa valeur
4. Cliquez sur **Turn Off** pour revenir à la vue normale

Cela est utile pour comprendre comment VIVO modélise les données savantes en tant que graphe connecté.

---

## Modifier une entité (admin)

Depuis n'importe quelle page de profil (lorsque connecté en tant qu'admin) :

1. Cliquez sur **Edit this individual** dans le panneau de contrôle Individual Control Panel
2. Vous verrez une vue interne avec :
   - **Datatype properties** : valeurs de chaîne littérale (nom, titre, courriel, etc.)
   - **Object properties** : liens vers d'autres entités (membre de, co-auteur avec, etc.)
3. Cliquez sur l'icône d'édition à côté de n'importe quelle propriété pour la modifier
4. Les modifications sont immédiatement reflétées dans le profil

---

## Administration du site

Le panneau **Site Admin** (accessible depuis l'en-tête lorsque connecté en tant qu'admin) donne accès à :

| Section | Description |
|---------|-------------|
| **Add/Remove RDF Data** | Charger ou supprimer des triplets RDF (N3, Turtle, RDF/XML) |
| **Ingest Menu** | Outils d'ingestion ; sources et intégrations à configurer séparément |
| **User Accounts** | Créer et gérer des comptes utilisateur |
| **Site Configuration** | Thème, coordonnées et paramètres d'affichage |
| **SPARQL Query** | Exécuter des requêtes SPARQL directement sur le triplestore |
| **Index** | Reconstruire ou vérifier l'index de recherche Solr |

---

## Visualisations

VIVO inclut des visualisations intégrées accessibles depuis les profils de personnes et d'organisations :

- **Réseau de co-auteurs** — graphe des collaborateurs connectés par des publications communes
- **Chronologie des publications** — vue chronologique de la production savante
- **Carte géographique** — distribution des collaborateurs par lieu (lorsque les données de localisation sont présentes)

La présence et le résultat de ces outils dépendent de l'interface, de la configuration et des données. Les essais 1.2.0 ne valident pas toutes les visualisations ou intégrations ; consultez [[fr_Home#image-120--statut-et-vérifications]].

---

## Références

- [Exploring VIVO — VIVO 1.15.x Documentation](https://wiki.lyrasis.org/display/VIVODOC115x/Exploring+VIVO) (wiki LYRASIS)
- [Logging in to VIVO](https://wiki.lyrasis.org/display/VIVODOC115x/Logging+in+to+VIVO)
- [Using VIVO](https://wiki.lyrasis.org/display/VIVODOC115x/Using+VIVO)
- [Navigating VIVO](https://wiki.lyrasis.org/display/VIVODOC115x/Navigating+VIVO)
- [Using Search](https://wiki.lyrasis.org/display/VIVODOC115x/Using+Search)
- [Using Visualizations](https://wiki.lyrasis.org/display/VIVODOC115x/Using+Visualizations)

---

*Page originale (English) : [[Exploring-VIVO]]*
