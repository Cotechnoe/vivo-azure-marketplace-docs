# Évaluation rapide

> 🇬🇧 This page is also available in English: [[Quick-Start-Evaluation]]

Utilisez ce guide pour vérifier que l'offre VIVO Azure Marketplace se déploie et s'ouvre correctement. Il crée un environnement d'évaluation temporaire, et non un service de production.

> Utilisez le guide complet [[Déployer depuis le Marketplace|fr_Deploying-from-Marketplace]] si vous prévoyez de conserver l'instance ou de charger des données institutionnelles.

> **Délai :** vérification du compte, capacité régionale, initialisation de la VM et émission du certificat varient ; aucun délai de déploiement ou de certificat n'est garanti.

---

## Prérequis

### 1. Créer un compte Azure et un abonnement

1. Créez un [compte Microsoft](https://account.microsoft.com/account) si vous n'en possédez pas déjà un.
2. Accédez à [Azure gratuit](https://azure.microsoft.com/fr-fr/free/) et créez un compte Azure. L'inscription crée ou active un abonnement Azure ; elle peut demander une vérification d'identité et de paiement.
3. Connectez-vous au [portail Azure](https://portal.azure.com/) et vérifiez que vous pouvez sélectionner un abonnement actif.

Le plan Marketplace, la VM, l'IP publique et les disques peuvent être facturés ; ne supposez pas que l'offre est couverte par les crédits ou services du compte gratuit. Consultez les tarifs et les conditions de l'abonnement affichés lors de l'inscription avant de continuer.

### 2. Diagnostiquer l'accès pour un compte existant

Si vous venez de créer un compte Azure personnel, passez à l'étape suivante. Pour un abonnement existant ou un compte d'organisation, vérifiez vous-même les points suivants dans le portail Azure :

1. Ouvrez **Abonnements** et vérifiez que l'abonnement à utiliser est actif.
2. Si l'abonnement n'apparaît pas, ouvrez le menu de votre compte, choisissez **Changer de répertoire**, puis vérifiez les abonnements disponibles dans le bon annuaire.
3. Ouvrez l'abonnement ou le groupe de ressources prévu, puis **Contrôle d'accès (IAM)** et **Afficher mon accès**. Vous devez disposer du rôle **Contributeur** ou **Propriétaire** sur ce périmètre.

Si l'abonnement est désactivé, absent du bon annuaire ou si aucun de ces rôles n'est attribué, demandez à son administrateur de vous accorder l'accès **Contributeur** au groupe de ressources ou à l'abonnement.

### 3. Préparer l'accès SSH

Dans l'assistant Marketplace, utilisez **Générer une nouvelle paire de clés** lorsque cette option est disponible. Téléchargez le fichier de clé privée lorsqu'il vous est proposé et conservez-le dans un emplacement sûr : Azure ne permet pas de le télécharger une seconde fois.

Si l'assistant demande uniquement de coller une clé publique SSH, créez-en une auparavant en suivant [[Connexion SSH|fr_SSH-Connection]].

### 4. Prévoir la suppression

Utilisez un groupe de ressources dédié à l'évaluation, sans données institutionnelles. Convenez de la personne autorisée à retirer les ressources à la fin de l'essai. Vérifiez tarif du plan et frais Azure avant toute création.

## Étape 1 — Sélectionner l'offre et l'image

Ouvrez l'[offre VIVO](https://marketplace.microsoft.com/fr-fr/product/cotechnoe.vivo-research-profiles?tab=Overview). Confirmez si vous évaluez l'offre publique ou la préversion 1.2.0 ; le [[statut daté|fr_Home#image-120--statut-et-vérifications]] les distingue.

## Étape 2 — Configurer et déployer

Suivez [[fr_Deploying-from-Marketplace]] pour VM, disques, réseau et parcours Custom data prévu pour l'image 1.2.0. Ce guide fournit l'exemple de configuration et distingue le déploiement ARM direct. Les contrôles archivés de l'image ne valident pas l'assistant Marketplace de bout en bout.

Utilisez un namespace temporaire comme `https://vivo-evaluation.example.org/individual/`, un courriel administrateur contrôlé et une locale comme `en_US`. Choisissez les capacités VM/disque pour l'évaluation ; aucune taille minimale ni capacité de charge n'est établie ici.

## Étape 3 — Vérifier initialisation et HTTPS

Suivez [[fr_Post-Deployment-Verification]] pour vérifier cloud-init, stockage et services. Configurez ensuite le DNS au besoin et suivez [[fr_HTTPS-TLS-Certificate]] pour obtenir et vérifier un certificat pour `https://<fqdn>/` avant d'entrer des identifiants. Une réponse HTTP avec vérification du certificat désactivée ne prouve pas la confiance du navigateur.

Un accueil affiché confirme seulement la réponse de cette page. Vérifiez séparément compte, configuration et fonctions prévus ; les tests de population par formulaires n'établissent pas l'import des données d'exemple.

## Étape 4 — Terminer l'évaluation

Avant toute suppression, confirmez que le groupe ne contient que des ressources d'évaluation jetables et préservez ce qui est nécessaire par une sauvegarde restaurable. Après autorisation, retirez ce groupe dédié, vérifiez la fin de la suppression et examinez ressources restantes et facturation. Les ressources hors de ce groupe, sauvegardes et stockage conservé peuvent continuer à être facturés. Consultez les [états et la facturation des VM Azure](https://learn.microsoft.com/fr-fr/azure/virtual-machines/states-billing).

## Étapes suivantes

- Consultez [[fr_Configuring-VIVO#exploitation-sauvegardes-et-coûts]] avant de conserver le service.
- Utilisez [[fr_Loading-Sample-Data]] seulement sur une instance dédiée hors production.
