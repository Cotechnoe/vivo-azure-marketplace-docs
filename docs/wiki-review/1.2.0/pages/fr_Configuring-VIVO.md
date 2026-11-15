# Configuration de VIVO

> 🇬🇧 This page is also available in English: [[Configuring-VIVO]]

L'image **1.2.0** contient la pile applicative ; les réglages institutionnels et l'exploitation continue relèvent de l'administration. Consultez [[fr_Deploying-from-Marketplace]] pour la configuration initiale et la distinction entre Custom data Marketplace et déploiement ARM direct.

---

## Paramètres initiaux et configuration active

Au premier démarrage, l'image lit `/etc/vivo/install.conf`, initialise le disque de données et applique namespace, courriel administrateur, langues et tas Tomcat. Elle crée ensuite `/etc/vivo/.first-boot-done` ; les exécutions suivantes ignorent l'initialisation lorsque ce marqueur existe.

Modifier `install.conf` après cette étape n'applique **pas** automatiquement les changements. Ne supprimez pas le marqueur et ne relancez pas cloud-init pour reconfigurer une instance contenant des données. Examinez et modifiez plutôt les fichiers actifs :

| Fichier | Rôle |
| --- | --- |
| `/data/vivo/home/config/runtime.properties` | Namespace VIVO, paramètres du compte root et langues |
| `/opt/tomcat/bin/setenv.sh` | `CATALINA_OPTS` de Tomcat, dont `-Xms` et `-Xmx` |
| `/etc/nginx/conf.d/vivo.conf` | Site NGINX de l'image ; vérifier la configuration active, que Certbot ou un administrateur peut modifier |

Avant une modification, conservez une copie, prévoyez une fenêtre de maintenance adaptée et un plan de récupération. Par exemple :

```bash
sudo cp -a /data/vivo/home/config/runtime.properties \
  /data/vivo/home/config/runtime.properties.bak.$(date +%Y%m%d%H%M%S)
sudoedit /data/vivo/home/config/runtime.properties
```

Cette commande copie seulement la configuration ; elle ne sauvegarde ni les magasins RDF actifs ni l'instance complète.

## Modifier le namespace VIVO

Choisissez le namespace **avant de charger les données**. Dans `runtime.properties`, assurez-vous d'avoir une seule entrée active, en remplaçant l'exemple par l'URI institutionnelle :

```properties
Vitro.defaultNamespace = https://vivo.example.org/individual/
```

Une modification ultérieure ne réécrit pas les identifiants RDF existants et ne migre pas les données. Planifiez séparément tout changement sur une instance peuplée, avec récupération testée. Redémarrez Tomcat après une modification approuvée et vérifiez le namespace prévu sur de nouvelles données de test.

## Mot de passe administrateur VIVO

Consultez [[fr_Post-Deployment-Verification#première-connexion-de-ladministrateur-vivo]] pour la première connexion et les limites des essais archivés. Les comptes SSH et Web VIVO sont distincts. N'utilisez pas une page SPARQL publique comme procédure de réinitialisation de mot de passe.

Modifier `rootUser.emailAddress` ne renomme pas un compte et ne réinitialise pas son mot de passe. Au démarrage, Vitro peut créer un autre compte root si aucun compte ne correspond au courriel configuré. Examinez les comptes administrateurs existants et limitez l'accès avant ce changement ; vérifiez et sécurisez le compte obtenu avant de rouvrir l'accès.

## Certificat TLS (Let's Encrypt)

L'image démarre avec un certificat autosigné. Le premier démarrage ne tente Certbot que si `VIVO_FQDN` est renseigné et si Certbot est disponible ; l'émission exige encore un DNS et la validation ACME. Modifier cette valeur après l'initialisation ne demande pas de certificat. Consultez [[fr_HTTPS-TLS-Certificate]] pour l'émission manuelle, la vérification de confiance et le renouvellement.

## Internationalisation (i18n)

Les paramètres initiaux `VIVO_LANGUAGES` et `VIVO_LANGUAGE_FILTER` sont appliqués à `runtime.properties` au premier démarrage. Ensuite, modifiez directement les propriétés actives. Sélectionner une langue ne traduit pas les données RDF institutionnelles et n'installe pas les traductions manquantes.

### Mode 1 — Locale unique

Dans `runtime.properties`, assurez-vous que ces entrées sont actives une seule fois ; supprimez ou commentez toute entrée active `languages.selectableLocales` :

```properties
languages.forceLocale = en_US
RDFService.languageFilter = false
```

### Mode 2 — Multi-locale

Assurez-vous que ces entrées sont actives une seule fois ; supprimez ou commentez toute entrée active `languages.forceLocale` :

```properties
languages.selectableLocales = en_US, fr_CA
RDFService.languageFilter = true
```

La première locale est celle par défaut. Le sélecteur et les traductions de l'interface dépendent des ressources présentes. Le filtre constitue un choix distinct ; gardez-le à `false` sauf si vous souhaitez une sélection des valeurs RDF selon la langue.

### Filtre de langue RDF (`RDFService.languageFilter`)

Avec `true`, Vitro sélectionne les littéraux selon les préférences de langue et les règles de repli. Il ne masque **pas** simplement toutes les valeurs sans langue et ne garantit pas non plus leur affichage systématique : la sélection dépend aussi des valeurs alternatives du même sujet et de la même propriété. Consultez [l'implémentation du filtre dans la révision Vitro embarquée](https://github.com/vivo-project/Vitro/blob/c6fdb5091b9026f57901c97cfec88223a63cff47/api/src/main/java/edu/cornell/mannlib/vitro/webapp/rdfservice/filter/LanguageFilterModel.java).

Les codes de locale utilisent un tiret bas dans les réglages (`fr_CA`) et les balises de langue RDF un tiret (`@fr-CA`). Vérifiez des données représentatives avec et sans langue dans chaque locale avant d'activer le filtre pour les données institutionnelles.

### Locales supportées

Les codes suivants identifient ces langues lorsque leurs ressources de traduction sont installées. Ce tableau ne certifie ni l'exhaustivité ni la présence de chaque traduction dans l'image 1.2.0 :

| Code de locale | Langue |
| --- | --- |
| `en_US` | Anglais (États-Unis) |
| `en_CA` | Anglais (Canada) |
| `fr_CA` | Français (Canada) |
| `de_DE` | Allemand |
| `es` | Espagnol |
| `pt_BR` | Portugais (Brésil) |
| `ru_RU` | Russe |
| `sr_Latn_RS` | Serbe (latin, Serbie) |

### Appliquer et vérifier les langues

Utilisez l'éditeur comme indiqué plus haut pour ajouter les propriétés absentes ou remplacer les entrées existantes, y compris celles commentées avec espaces. Évitez les clés actives en double ; `languages.forceLocale` prévaut sur les locales sélectionnables. Redémarrez ensuite Tomcat dans la fenêtre de maintenance prévue :

```bash
sudo systemctl restart tomcat
systemctl is-active tomcat
grep -E '^[[:space:]]*(languages\.(forceLocale|selectableLocales)|RDFService\.languageFilter)[[:space:]]*=' \
  /data/vivo/home/config/runtime.properties
```

Vérifiez l'interface et des données représentatives après démarrage ; l'état du service ne prouve pas à lui seul le comportement linguistique.

## Exploitation, sauvegardes et coûts

- **Accès et données :** sécuriser les comptes administrateurs, examiner l'accès SPARQL et les règles NSG/UFW effectives, décider quelles informations de recherche peuvent être publiques. L'ingestion externe et les intégrations d'identifiants nécessitent configuration ou développement.
- **Maintenance :** planifier les mises à jour OS et applicatives, surveiller journaux, espace disque et services. L'image 1.2.0 suit la série de noyau Azure LTS 6.8 par une politique APT ; examiner cette politique avec l'éditeur avant de changer de série. Un contrôle de sécurité au build ne constitue pas une assurance continue contre les vulnérabilités.
- **Sauvegardes et récupération :** prévoir des sauvegardes cohérentes avec l'application pour les magasins RDF VIVO, VIVO home/configuration, les données et réglages Solr, ainsi que les réglages hors `/data` comme Tomcat et NGINX. Protéger clés de certificat et autres secrets. Copier un répertoire TDB actif n'est pas une sauvegarde validée. Tester la récupération sur une instance isolée et définir perte de données et délai de récupération tolérés. Les essais archivés de l'image n'établissent ni politique de sauvegarde automatique ni service de haute disponibilité.
- **Coûts :** distinguer le tarif du plan de ceux de la VM Azure, des disques, du réseau, des sauvegardes et des services externes. Arrêter l'OS invité n'équivaut pas à désallouer la VM ; disques et réseau peuvent encore être facturés après désallocation. Consultez les [états et la facturation des VM Azure](https://learn.microsoft.com/fr-fr/azure/virtual-machines/states-billing).
- **Responsabilités institutionnelles :** évaluer emplacement des données, sauvegardes, réplication, flux sortants, télémétrie et services externes selon vos politiques. Un déploiement dans votre abonnement ne prouve pas à lui seul résidence exclusive des données, absence de télémétrie ou conformité réglementaire. Une mise à jour d'image ne migre pas automatiquement les données ou la configuration d'une VM existante.

---

## Références

- [VIVO 1.15.x — Internationalisation](https://wiki.lyrasis.org/display/VIVODOC115x/Internationalization) (wiki LYRASIS)
- [Activer les langues d'interface dans VIVO en tant qu'administrateur](https://wiki.lyrasis.org/display/VIVODOC115x/Enabling+Interface+Languages+in+VIVO+as+an+Administrator)
- [Utiliser les fonctionnalités i18n de VIVO](https://wiki.lyrasis.org/display/VIVODOC115x/Using+VIVO%27s+Internationalization+%28i18n%29+Features)

---

*Page originale (English) : [[Configuring-VIVO]]*
