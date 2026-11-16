# Chargement des données d'exemple

> 🇬🇧 This page is also available in English: [[Loading-Sample-Data]]

Les [données d'exemple VIVO](https://github.com/vivo-project/sample-data) fournissent une université fictive (personnes, départements, publications, bourses, adhésions) pour explorer les fonctionnalités de VIVO sur une instance fraîchement déployée.

Deux scénarios de chargement sont couverts ci-dessous :

- **Sans i18n** — langue unique (anglais), un seul fichier à charger
- **Avec i18n** — multilingue (anglais + français canadien), trois fichiers à charger en séquence

> Chargez les données d'exemple uniquement sur une **instance vierge ou dédiée**. Ne les mélangez pas avec des données institutionnelles réelles.

---

## Prérequis

- VIVO est en cours d'exécution et accessible à `https://<fqdn>/`
- Vous êtes connecté en tant qu'**administrateur du site** (le compte sécurisé pour cette instance ; consultez [[fr_Post-Deployment-Verification#première-connexion-de-ladministrateur-vivo]])
- Naviguez vers : **Site Admin → Add/Remove RDF Data**

---

## Scénario 1 — Sans i18n (anglais uniquement)

Chargez un seul fichier N3. Le fichier amont actuel comprend des étiquettes anglaises avec balises de langue ; ce n'est pas un jeu sans balises.

### Étape 1 — Charger les données d'exemple

Dans **Add/Remove RDF Data** :

| Champ | Valeur |
|-------|--------|
| URL | `https://raw.githubusercontent.com/vivo-project/sample-data/main/sample-data.n3` |
| Action | **Add instance data** |
| File type | **N3** |

Cliquez sur **Submit**.

### Étape 2 — Vérifier

Naviguez vers la page d'accueil VIVO. Vous devriez voir les domaines de recherche, les personnes et les organisations renseignés. Essayez de rechercher `Chemistry`, `Roberts` ou `Pringle`.

> **Carte des compétences :** Si la carte des compétences à `/vis/capabilitymap` n'affiche aucun nœud malgré la présence des données, consultez [[fr_Troubleshooting#carte-des-compétences-vide--jsonp-bloqué-par-le-type-mime]].

---

## Scénario 2 — Avec i18n (anglais + français canadien)

Le répertoire `i18n/` du dépôt de données d'exemple distribue les étiquettes par locale :

| Fichier | Contenu |
|---------|---------|
| [`sample-data-i18n.ttl`](https://raw.githubusercontent.com/vivo-project/sample-data/main/i18n/sample-data-i18n.ttl) | Données de base — structure, relations et étiquettes anglaises avec balises de langue |
| [`sample-data-i18n-en_US.ttl`](https://raw.githubusercontent.com/vivo-project/sample-data/main/i18n/sample-data-i18n-en_US.ttl) | Énoncés anglais (`en_US`) supplémentaires ; pas un ensemble complet pour chaque ressource |
| [`sample-data-i18n-fr_CA.ttl`](https://raw.githubusercontent.com/vivo-project/sample-data/main/i18n/sample-data-i18n-fr_CA.ttl) | Énoncés français canadiens (`fr_CA`) supplémentaires ; pas une traduction complète |

### Étape 1 — Activer le mode multi-locale

Suivez [[fr_Configuring-VIVO#mode-2--multi-locale]] pour configurer le fichier actif, y compris les propriétés absentes ou commentées. Après redémarrage de Tomcat, vérifiez le sélecteur et des valeurs d'exemple avant d'importer davantage de données. Le fichier de base contient déjà des étiquettes anglaises ; les fichiers par locale le complètent.

### Étape 2 — Charger les données de base

Dans **Site Admin → Add/Remove RDF Data** :

| Champ | Valeur |
|-------|--------|
| URL | `https://raw.githubusercontent.com/vivo-project/sample-data/main/i18n/sample-data-i18n.ttl` |
| Action | **Add instance data** |
| File type | **Turtle** |

Cliquez sur **Submit**.

### Étape 3 — Charger les étiquettes en anglais

| Champ | Valeur |
|-------|--------|
| URL | `https://raw.githubusercontent.com/vivo-project/sample-data/main/i18n/sample-data-i18n-en_US.ttl` |
| Action | **Add instance data** |
| File type | **Turtle** |

Cliquez sur **Submit**.

### Étape 4 — Charger les étiquettes en français canadien

| Champ | Valeur |
|-------|--------|
| URL | `https://raw.githubusercontent.com/vivo-project/sample-data/main/i18n/sample-data-i18n-fr_CA.ttl` |
| Action | **Add instance data** |
| File type | **Turtle** |

Cliquez sur **Submit**.

### Étape 5 — Vérifier

Naviguez vers la page d'accueil VIVO. Un **sélecteur de langue** devrait apparaître dans l'en-tête. Basculez entre **English** et **Français** — les étiquettes des organisations, des personnes et des domaines de recherche devraient changer en conséquence.

> **Carte des compétences :** Si la carte des compétences à `/vis/capabilitymap` n'affiche aucun nœud malgré la présence des données, consultez [[fr_Troubleshooting#carte-des-compétences-vide--jsonp-bloqué-par-le-type-mime]].

---

## Vérification post-chargement

Après le chargement, quel que soit le scénario, confirmez que les données sont entièrement indexées et que la carte des compétences est fonctionnelle.

### Vérifier l'index Solr

Le nombre affiché ci-dessous est le nombre total de documents actuellement présents dans l'index Solr, et non le nombre de documents des données d'exemple. Il varie selon la version de VIVO, les données déjà présentes, la révision des données d'exemple et l'état de l'indexation. N'utilisez pas un nombre fixe pour prouver que les données d'exemple ont été chargées correctement.

```bash
curl -s "http://localhost:8983/solr/vivocore/select?q=*:*&rows=0" | python3 -c \
  "import sys, json; d=json.load(sys.stdin); print('Docs indexés :', d['response']['numFound'])"
```

Utilisez cette commande uniquement comme diagnostic. Au besoin, comparez le nombre avant et après le chargement sur la même instance de test dédiée, puis vérifiez dans VIVO la présence des personnes, organisations et domaines de recherche attendus. Une variation peut indiquer que l'indexation est en cours; le nombre seul ne permet pas de distinguer les données d'exemple des autres données de l'instance.

### Vérifier l'API de données de la carte des compétences

Confirmez que l'API retourne des résultats avant de tester l'interface navigateur :

```bash
# Lister tous les domaines de recherche indexés
curl -sS "https://<fqdn>/visualizationAjax?vis=capabilitymap&query=all&data=concepts" | head -c 500

# Récupérer les chercheurs liés à un concept spécifique
curl -sS "https://<fqdn>/visualizationAjax?vis=capabilitymap&query=Rhetoric&callback=ipretResults&noCacheIE=1" | head -c 500
```

Pour la requête contenant `callback=ipretResults`, examinez la réponse JSONP (`ipretResults({...})`) et ses enregistrements ; cela ne valide pas la visualisation navigateur.

Si la réponse est du HTML, examinez statut HTTP, authentification et erreur applicative ; cela ne prouve pas à lui seul l'absence de données. Si le navigateur bloque la requête, consultez [[fr_Troubleshooting#carte-des-compétences-vide--jsonp-bloqué-par-le-type-mime]].

### Vérifier l'en-tête Content-Type

Les navigateurs appliquent une vérification stricte du type MIME. Confirmez que nginx retourne le bon type :

```bash
curl -sS -I "https://<fqdn>/visualizationAjax?vis=capabilitymap&query=Rhetoric&callback=ipretResults&noCacheIE=1" \
  | grep -i content-type
```

Résultat attendu :
```
content-type: application/javascript; charset=UTF-8
```

Si la réponse retourne `text/html`, examinez réponse et configuration active avant d'envisager le contournement historique dans [[fr_Troubleshooting#carte-des-compétences-vide--jsonp-bloqué-par-le-type-mime]].

---

## Note sur les espaces de nommage (namespace)

Examinez les namespaces des fichiers amont choisis : leurs URI de ressources peuvent différer du namespace de votre instance. Charger un fichier ne réécrit pas ses identifiants. Vérifiez liens des profils, recherche et visualisations plutôt que de supposer leur fonctionnement pour chaque combinaison de namespaces.

Le scénario Firefox archivé de la 1.2.0 reconstruisait une sélection de données par formulaires, en omettant des sujets source incomplets et une relation de lieu de publication non prise en charge. Il ne testait pas cette procédure d'import RDF et n'établissait pas un graphe identique. Les fichiers amont peuvent changer ; consignez la révision utilisée pour reproduire un essai.

---

## Revenir à un état de test vierge

Ce guide ne fournit pas de procédure sûre pour retirer uniquement les données d'exemple après leur chargement. Elles sont ajoutées à l'instance; la suppression des répertoires du triplestore VIVO ou de l'index Solr peut aussi effacer d'autres données. Les chemins de stockage et le comportement d'initialisation peuvent également varier selon la version de l'image. **N'exécutez pas de commande de suppression de répertoires pour réinitialiser les données d'exemple.**

Pour tester les données d'exemple, utilisez un nouveau déploiement Marketplace jetable, réservé à ce test. Pour retrouver un état vierge, recréez le déploiement de test plutôt que de supprimer manuellement les données VIVO ou Solr. Avant de supprimer des ressources Azure, vérifiez qu'elles appartiennent uniquement à l'environnement de test jetable, que toute donnée à conserver possède une sauvegarde restaurable et que vous êtes autorisé à les supprimer.

Si les données d'exemple ont été chargées dans une instance contenant des données à conserver, ne tentez pas de la réinitialiser sur place. Suivez la procédure de sauvegarde et de récupération de votre organisation, vérifiez que la sauvegarde peut être restaurée dans une instance isolée et consultez l'administrateur VIVO/de l'instance avant de modifier ou remplacer le déploiement.

Le guide de restauration VIVO 1.15.x cité ci-dessous est une documentation amont pour cette version de VIVO; sa procédure n'a pas été validée pour toutes les images Marketplace. Ne l'appliquez pas à une VM Marketplace sans confirmer au préalable les chemins et le comportement de récupération propres à la version utilisée.

---

## Références

- [vivo-project/sample-data](https://github.com/vivo-project/sample-data) — dépôt GitHub
- [Sample Data — VIVO 1.15.x Documentation](https://wiki.lyrasis.org/display/VIVODOC115x/Sample+Data) — wiki LYRASIS
- [Restoring VIVO to First Time State](https://wiki.lyrasis.org/display/VIVODOC115x/Restoring+VIVO+to+First+Time+State) — wiki LYRASIS
- [Language Filter — VIVO 1.15.x Documentation](https://wiki.lyrasis.org/display/VIVODOC115x/Language+Filter) — wiki LYRASIS
- [[fr_Troubleshooting]] — Carte des compétences vide, problème de type MIME

---

*Page originale (English) : [[Loading-Sample-Data]]*
