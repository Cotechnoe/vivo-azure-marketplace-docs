# Vérification post-déploiement

> 🇬🇧 This page is also available in English: [[Post-Deployment-Verification]]

Après le déploiement, vérifiez séparément initialisation, stockage, réponses des services et TLS. Consultez [[fr_Home#image-120--statut-et-vérifications]] pour la portée des essais archivés de l'image 1.2.0.

---

## Diagnostic automatisé

Un outil compagnon exécute un ensemble de sondes de diagnostic en une seule commande **depuis votre poste de travail** — sans session SSH manuelle.

**Prérequis :** Git, `make`, accès SSH à la VM et votre clé privée SSH. Le dépôt public peut être cloné en HTTPS sans authentification SSH GitHub.

```bash
git clone https://github.com/Cotechnoe/vivo-azure-marketplace-docs.git
cd vivo-azure-marketplace-docs
make diag IP=<ip-publique-vm>
```

Si votre utilisateur SSH ou le chemin de la clé diffèrent des valeurs par défaut :

```bash
make diag IP=<ip-publique-vm> SSH_USER=azureuser SSH_KEY=~/.ssh/votre-cle.pem
```

Le script couvre **12 rubriques de diagnostic** et affiche un résumé en couleur :

| # | Vérification | Ce qui est contrôlé |
|---|--------------|---------------------|
| 1 | cloud-init | État cloud-init rapporté ; ne teste pas toutes les fonctions applicatives |
| 2 | Premier boot | Marqueur présent, ou fin inférée par une heuristique textuelle du journal |
| 3 | Config install | Fichier présent et contenu affiché ; vérifier les valeurs vous-même |
| 4 | Services systemd | nginx / tomcat / solr état actif vérifié ; état d'activation affiché |
| 5 | Espace disque | Utilisation de `/data` (ou racine) sous le seuil d'alerte |
| 6 | HTTP/HTTPS | Redirection HTTP locale (301/302) et réponse HTTPS avec vérification de confiance contournée |
| 7 | Certificat TLS | Texte d'expiration de NGINX local ; sans validation de chaîne, de nom ou de seuil d'expiration |
| 8 | Pare-feu UFW | Entrées DENY textuelles pour 8983/8080 ; pas un audit NSG effectif |
| 9 | Solr ping | Le cœur `vivocore` répond OK (testé depuis la VM) |
| 10 | Endpoint SPARQL | `/api/sparqlQuery` répond (200 ou 403 — les deux sont acceptables) |
| 11 | Heap Tomcat | Réglages de tas trouvés dans les fichiers ; pas leur adéquation à la charge |
| 12 | Scan erreurs | Lignes récentes correspondantes signalées comme avertissements ; pas un audit exhaustif |

**Codes de retour :** `0` = aucun FAIL enregistré (des WARN peuvent subsister) · `1` = un ou plusieurs FAIL · `2` = erreur de connexion SSH

**Résumé illustratif ; les comptes varient et ne certifient pas un déploiement sain :**
```
════════════════════════════════════════════════════════
  OK  : 16   FAIL: 0   WARN: 2
════════════════════════════════════════════════════════
```

> **WARNs attendus :**
> - *Marqueur premier boot absent* — rétrogradé en WARN si le journal confirme la fin du boot. Ce repli repose sur une heuristique textuelle ; confirmez la fin et examinez le marqueur absent avant de vous fier à l'initialisation.
> - *`/data` introuvable* — l'utilisation de la racine est affichée en remplacement. Cela ne prouve pas que le disque de données prévu est disponible ; examinez le problème avant de charger des données.

---

## Interpréter les limites du diagnostic

L'outil accepte un statut SPARQL 200 ou 403 sans valider le résultat d'une requête authentifiée. Un 401 avec défi d'authentification peut indiquer un point d'accès protégé, mais l'outil actuel le signale comme FAIL. Examinez statut, défi et politique d'accès ; ne rendez pas SPARQL public pour supprimer un échec de diagnostic.

Les sondes HTTP/HTTPS s'exécutent **dans la VM**. Elles ne valident ni accès NSG externe, ni DNS, ni confiance du navigateur, ni récupération des sauvegardes. `curl -k` contourne la vérification du certificat ; une page reçue ainsi ne prouve pas la confiance TLS. Relisez et expurgez la sortie du diagnostic avant partage : elle affiche adresses, configuration et extraits de journaux.

---

## Assigner un nom DNS

Vérifiez si le déploiement dispose d'un nom DNS ; Marketplace ne démontre pas que le modèle ARM de référence en a créé un. L'outil ci-dessous modifie la ressource Azure d'IP publique dans l'abonnement courant de la CLI. Confirmez cet abonnement et cette ressource avant de l'exécuter. Il ne configure pas un DNS privé et ne demande pas de certificat.

Assignez un label DNS en une seule commande (nécessite `az` CLI connecté avec l'abonnement approprié) :

```bash
make set-dns IP=<ip-publique-vm>
```

Pour spécifier un label personnalisé plutôt que le pattern par défaut `vivo-<ip-tirets>` :

```bash
make set-dns IP=<ip-publique-vm> DNS=mon-instance-vivo
```

La commande affiche le FQDN résultant, par ex. `mon-instance-vivo.canadacentral.cloudapp.azure.com`.

---

## Vérifier l'état de cloud-init

Connectez-vous à la VM en SSH et exécutez :

```bash
sudo cloud-init status --long
```

Résultat attendu en cas de succès :

```
status: done
```

Si l'état est `running`, l'initialisation est toujours en cours — attendez quelques minutes et réessayez.

---

## Vérifier OS, provenance et stockage

Pour l'image 1.2.0, vérifiez Ubuntu 24.04 et le noyau Azure LTS 6.8 actif. Le fichier de provenance identifie les sources VIVO/Vitro et le checksum WAR packagés ; il n'identifie pas l'image Marketplace sélectionnée dans Azure, à vérifier séparément.

```bash
cat /etc/os-release
uname -r
sudo cat /etc/vivo/build-provenance.json
findmnt --mountpoint /data
lsblk -f
```

Si un disque de données séparé était demandé, `/data` doit être un montage de ce disque. Un répertoire `/data` sur le disque OS ne prouve pas que le disque de données est monté. Examinez tout montage absent avant de charger des données.

---

## Vérifier les services

```bash
systemctl is-active tomcat solr nginx
```

Les trois doivent retourner `active`.

---

## Vérifier que VIVO répond

```bash
curl -sS -o /dev/null -w "%{http_code}" http://localhost:8080/
```

Résultat attendu : `200`

---

## Accéder à VIVO dans un navigateur

Naviguez vers `https://<fqdn>/` en utilisant le FQDN attribué à la VM.

> Selon la version de l'image et les paramètres de déploiement, le premier démarrage peut tenter de provisionner un certificat **Let's Encrypt**. Cette opération peut échouer et son délai n'est pas garanti.
> Si le navigateur affiche un avertissement de certificat, ne le contournez pas et n'entrez pas d'identifiants. Vérifiez le certificat servi pour le FQDN et consultez [[fr_HTTPS-TLS-Certificate]] pour les étapes de récupération.

---

## Première connexion de l'administrateur VIVO

Le compte administrateur VIVO est distinct du compte SSH de la VM. Vérifiez le certificat TLS de `https://<fqdn>/` avant d'entrer des identifiants; consultez [[fr_HTTPS-TLS-Certificate]].

L'implémentation de premier démarrage 1.2.0 associe `VIVO_ADMIN_EMAIL` à `rootUser.emailAddress` ; vérifiez que votre configuration a été appliquée. Les paramètres ARM de référence ne comprennent **pas** `vivoAdminPassword`. L'assistant et l'image actuellement publiés n'ont pas été vérifiés indépendamment par rapport à ce modèle; utilisez le courriel et la procédure de première connexion fournis pour votre déploiement, ou contactez l'éditeur s'ils ne sont pas clairs. Ne supposez pas que la clé ou le nom d'utilisateur SSH est le mot de passe VIVO.

À titre de comparaison, [l'implémentation du compte root Vitro à la révision embarquée dans la 1.2.0](https://github.com/vivo-project/Vitro/blob/c6fdb5091b9026f57901c97cfec88223a63cff47/api/src/main/java/edu/cornell/mannlib/vitro/webapp/auth/RootUserSetup.java#L106) crée un compte root uniquement si aucun compte n'existe pour le courriel root configuré. Pour ce nouveau compte, elle utilise un mot de passe initial public par défaut si `rootUser.password` n'est pas configuré et exige par défaut son changement. Ces deux réglages peuvent être remplacés. **Cette source ne démontre pas les réglages de l'image publiée.** Ne supposez pas qu'un compte existant est réinitialisé au redémarrage de la VM.

Les tests Chromium archivés affichent l'accueil, la redirection HTTP et le formulaire de connexion sans soumettre d'identifiants. Le test de population Firefox se connecte avec des identifiants fournis par un fichier privé et attend `/siteAdmin` ; il ne teste ni la création d'un compte root ni le changement obligatoire du premier mot de passe. Ne déduisez pas ces comportements des comptes de tests réussis.

Utilisez le mot de passe explicitement indiqué pour votre version déployée, limitez l'accès jusqu'à la sécurisation du compte et remplacez immédiatement tout mot de passe initial ou par défaut par un mot de passe unique et robuste. Si les identifiants attendus ou le changement de mot de passe ne fonctionnent pas, arrêtez et consultez l'éditeur ou l'administrateur de l'instance; ne publiez ni identifiants ni secrets de configuration dans une issue publique.

---

## Consulter le journal d'initialisation de la VM

Pour obtenir des informations détaillées sur ce qui s'est passé pendant le déploiement :

```bash
sudo tail -100 /var/log/vivo-first-boot.log
```

---

*Page originale (English) : [[Post-Deployment-Verification]]*
