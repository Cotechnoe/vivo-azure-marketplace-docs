# Déployer VIVO depuis Azure Marketplace

> 🇬🇧 This page is also available in English: [[Deploying-from-Marketplace]]

Préparez un déploiement de l'image **1.2.0**, avec Ubuntu **24.04 LTS** et VIVO/Vitro **1.16.0**. Consultez [[fr_Home#image-120--statut-et-vérifications]] pour la distinction datée entre l'offre publique et la préversion.

Ce guide décrit le parcours prévu **Avancé → Données personnalisées (Custom data)** de l'image VM 1.2.0, d'après son implémentation de premier démarrage. Les essais archivés déployaient l'image exacte depuis la galerie ; ils ne valident pas l'assistant Marketplace complet. Confirmez l'image sélectionnée et la présence du champ Custom data dans le déploiement réel. Si l'assistant diffère, contactez l'éditeur avant de créer la VM.

---

## Avant le déploiement

- Préparez les clés SSH et vérifiez l'identité de la VM : consultez [[fr_SSH-Connection]]. Le compte SSH est distinct du compte Web VIVO.
- Choisissez un abonnement Azure, une région et un groupe de ressources adaptés à vos politiques. Vérifiez le tarif du plan et les coûts d'infrastructure Azure.
- Dimensionnez CPU, RAM et disques selon vos données, l'indexation et l'usage prévu. Les contrôles réalisés n'établissent ni taille minimale de VM/disque en production ni capacité de charge. Gardez de la mémoire pour Solr, l'OS et les autres processus lors du réglage du tas Tomcat.
- Choisissez le namespace RDF permanent avant d'ajouter des données institutionnelles. Modifier les identifiants ensuite exige une migration planifiée des données, pas seulement un réglage de configuration.

## Étape 1 — Sélectionner et configurer la VM

Ouvrez l'[offre VIVO](https://marketplace.microsoft.com/fr-fr/product/cotechnoe.vivo-research-profiles?tab=Overview). Confirmez le plan et la version d'image exacte. La version de l'application VIVO ou le numéro affiché dans la fiche n'est pas la version d'image ; ne supposez pas qu'une sélection latest non précisée correspond à la 1.2.0.

Dans l'assistant de création de VM, configurez l'administrateur SSH, la clé publique SSH, la taille, les disques et le réseau. Laissez Azure reprendre la taille de disque OS exigée par l'image sélectionnée plutôt que de forcer un disque plus petit.

Pour un stockage de données séparé, attachez un **nouveau disque de données vide au LUN 0**. L'initialisation 1.2.0 monte ce disque sur `/data` et formate un disque non formaté. N'attachez pas un disque contenant des données à conserver pour expérimenter l'initialisation. Vérifiez le montage final avec [[fr_Post-Deployment-Verification]].

Vérifiez les règles NSG et du pare-feu invité effectives :

| Port | Usage | Décision nécessaire |
| --- | --- | --- |
| 443/TCP | VIVO via NGINX | Autoriser seulement les clients Web prévus. |
| 80/TCP | Redirection HTTP ; défi de certificat HTTP-01 | Autoriser l'autorité de certification si vous utilisez la procédure NGINX/Let's Encrypt. `/health` peut répondre HTTP 200 sans tester VIVO. |
| 22/TCP | SSH | Limiter aux sources d'administration de confiance ; éviter l'accès sans restriction. |
| 8080/TCP | Tomcat | Garder privé ; la configuration UFW de l'image refuse l'accès externe. |
| 8983/TCP | Solr | Garder privé ; la configuration UFW de l'image refuse l'accès externe. |

Ne supposez pas que le déploiement publié crée un NSG ou un nom DNS particulier parce que le modèle ARM de référence le fait.

## Étape 2 — Fournir la configuration VIVO initiale

Pour le parcours Custom data de cette image, placez le cloud-config suivant dans **Avancé → Données personnalisées** avant de créer la VM. Remplacez le namespace et le courriel d'exemple. N'y mettez ni mots de passe ni clés privées. Consultez [Custom data Azure](https://learn.microsoft.com/fr-fr/azure/virtual-machines/custom-data) pour le cycle de provisionnement et ses restrictions.

```yaml
#cloud-config
write_files:
  - path: /etc/vivo/install.conf
    owner: root:root
    permissions: '0600'
    content: |
      VIVO_NAMESPACE='https://vivo.example.org/individual/'
      VIVO_ADMIN_EMAIL='admin@example.org'
      VIVO_LANGUAGES='en_US,fr_CA'
      VIVO_LANGUAGE_FILTER='false'
      TOMCAT_HEAP_MIN='2g'
      TOMCAT_HEAP_MAX='6g'
      VIVO_FQDN=''
```

L'image programme déjà `/usr/local/bin/vivo-first-boot.sh` par cloud-init. Ce bloc écrit les paramètres que ce script lit ; il ne réinstalle pas la pile applicative.

| Paramètre | Signification |
| --- | --- |
| `VIVO_NAMESPACE` | URI RDF de base terminée par `/` ; à choisir pour l'institution avant de charger les données. |
| `VIVO_ADMIN_EMAIL` | Courriel configurant le compte root VIVO ; ce n'est ni le nom SSH ni un réglage d'envoi de courriels. |
| `VIVO_LANGUAGES` | Codes de locale séparés par des virgules ; une locale force cette langue, plusieurs permettent une sélection si les ressources sont disponibles. |
| `VIVO_LANGUAGE_FILTER` | `true` ou `false` ; consultez [[fr_Configuring-VIVO]] avant de l'activer. |
| `TOMCAT_HEAP_MIN`, `TOMCAT_HEAP_MAX` | L'exemple reprend les valeurs de secours `2g`/`6g` de l'image, sans constituer une recommandation de dimensionnement. Adaptez-les à la VM et validez la charge. |
| `VIVO_FQDN` | Laisser vide pour obtenir un certificat plus tard. Si renseigné, utiliser un nom résolvant déjà vers cette VM et préparer l'accès HTTP-01 avant la demande du premier démarrage. |

Ce bloc ne crée ni disque, ni enregistrement DNS, ni règle réseau. Sans configuration fournie, l'image utilise un namespace et un courriel d'exemple, `en_US`, le filtre `false`, un tas `2g`/`6g` et un FQDN vide comme valeurs de secours. Ce ne sont pas des réglages institutionnels.

### Le déploiement ARM direct est un parcours distinct

Le modèle ARM de référence génère son propre `customData` cloud-init à partir de paramètres comme `vivoNamespace`, `vivoAdminEmail`, `vivoLanguages`, `vivoLanguageFilter`, `vmSize`, `dataDiskSizeGB` et `sshSourceIP`. Ne remplacez pas ce bloc généré par un second bloc. Sa référence locale d'image vise encore **Jammy 1.1.19** lors de cette revue ; ce n'est pas un artefact de déploiement 1.2.0 approuvé.

Le modèle associe les tailles de VM à des valeurs de tas (`1g`/`3g`, `2g`/`6g`, `4g`/`12g`, `8g`/`24g`). Ce comportement de référence n'est ni un calcul automatique démontré dans l'assistant Marketplace ni une recommandation de capacité de production. La présence d'un `createUiDefinition.json` ne prouve pas qu'une offre VM standard expose des champs VIVO personnalisés.

## Étape 3 — Créer et vérifier l'initialisation

Vérifiez les coûts, la version d'image, le groupe de ressources, l'exposition réseau et la configuration, puis créez la VM. La fin du provisionnement Azure ne prouve pas que l'initialisation de VIVO est terminée ; le délai varie. Connectez-vous par SSH et suivez [[fr_Post-Deployment-Verification]]. Vérifiez la fin de cloud-init, le marqueur de premier démarrage, le montage `/data` et les services avant utilisation.

Consultez configuration et journaux localement ; expurgez secrets, adresses et données personnelles avant de partager des extraits. Ne relancez pas l'initialisation et ne supprimez pas son marqueur pour reconfigurer l'instance ; consultez [[fr_Configuring-VIVO]].

## Étape 4 — Configurer DNS, TLS et première connexion

Utilisez le nom réellement assigné ou configuré pour ce déploiement ; le parcours Marketplace ne garantit pas un nom DNS. Au besoin, l'outil documentaire permet d'assigner un label DNS à une IP publique Azure depuis votre poste :

```bash
git clone https://github.com/Cotechnoe/vivo-azure-marketplace-docs.git
cd vivo-azure-marketplace-docs
make set-dns IP=<vm-public-ip> DNS=<chosen-label>
```

Cette commande modifie une ressource Azure dans l'abonnement sélectionné par la CLI. Vérifiez d'abord l'abonnement et la ressource d'IP publique. Pour un déploiement privé, préparez plutôt le DNS et le certificat avec votre administrateur.

NGINX sert initialement un certificat autosigné. Fournir un FQDN peut déclencher une tentative Certbot au premier démarrage ; assigner un DNS plus tard ne la relance pas. Obtenez et vérifiez un certificat de confiance avec [[fr_HTTPS-TLS-Certificate]] avant d'entrer des identifiants. Les essais 1.2.0 n'établissent pas la confiance TLS du navigateur.

Consultez [[fr_Post-Deployment-Verification#première-connexion-de-ladministrateur-vivo]] pour le compte Web VIVO distinct. Suivez [[fr_Configuring-VIVO#exploitation-sauvegardes-et-coûts]] avant de conserver une instance ou de charger des données institutionnelles.
