# Résolution de problèmes

> 🇬🇧 This page is also available in English: [[Troubleshooting]]

Problèmes courants rencontrés lors du déploiement et de l'exploitation de VIVO sur Azure Marketplace.

> **Lancez d'abord le diagnostic automatisé.** La commande `make diag` sonde les services, le pare-feu invité, l'expiration du certificat, Solr, le statut SPARQL et des journaux récents ; les sondes sont lancées depuis votre poste. Consultez leurs limites dans le guide de vérification.
> → Voir [[Diagnostic automatisé|fr_Post-Deployment-Verification#diagnostic-automatisé]] pour la mise en place et l'utilisation.

---

## Échec du déploiement — `VIVO_LANGUAGES : unbound variable`

**Symptôme :**

```
VIVO_LANGUAGES: unbound variable
cloud-final.service: Failed
```

**Contexte historique :** D'anciens scripts pouvaient échouer sur des paramètres absents. L'implémentation 1.2.0 fournit des valeurs de secours ; cette erreur n'identifie pas à elle seule le mode de déploiement. Confirmez version d'image, configuration appliquée et script en échec dans les journaux.

**Action :** Examinez cloud-init et le journal d'initialisation, puis consultez l'éditeur avant une récupération. Préservez données et configuration existantes. Ne supprimez pas une VM et ne réinitialisez pas le marqueur de premier démarrage comme correction générale. Consultez [[fr_Deploying-from-Marketplace]] et [[fr_Configuring-VIVO]].

---

## SSH — UNPROTECTED PRIVATE KEY FILE

**Symptôme :**

```
Permissions 0777 for 'key.pem' are too open.
bad permissions: ignore key
```

**Cause :** Le fichier de clé se trouve sur un système de fichiers Windows/NTFS (ex. : `/mnt/c/...`). La commande `chmod` n'y a aucun effet.

**Correction :**

```bash
cp /mnt/c/Users/<VotreNom>/Downloads/your-key.pem ~/.ssh/
chmod 600 ~/.ssh/your-key.pem
ssh -i ~/.ssh/your-key.pem azureuser@<public-ip>
```

---

## Erreur de déploiement — `osDisk.diskSizeGB` trop petit

**Symptôme :**

```json
"code": "OperationNotAllowed",
"message": "The specified disk size 64 GB is less than the size of the corresponding disk in the VM image: 256 GB."
```

**Cause :** Le modèle de déploiement d'une version précédente de l'offre définissait une taille de disque inférieure à celle requise par l'image. Cet exemple historique ne démontre pas l'état de l'offre publique actuelle ni sa taille de disque requise.

**Action :** Vérifiez la taille de disque OS exigée par l'image sélectionnée et retirez le réglage trop petit de la configuration de déploiement. Ne remplacez pas une VM existante et ne perdez pas de données sans plan de récupération ni autorisation.

---

## Erreur de déploiement — `linuxConfiguration.ssh.publicKeys.path` invalide

**Symptôme :**

```json
"code": "InvalidParameter",
"target": "linuxConfiguration.ssh.publicKeys.path"
```

**Cause :** `adminUsername` a été laissé vide, produisant le chemin `/home//.ssh/authorized_keys`.

**Correction :** Assurez-vous que `adminUsername` est renseigné (valeur par défaut : `azureuser`).

---

## VIVO est accessible mais affiche le namespace example.org par défaut

**Cause possible :** Les réglages prévus n'ont pas été fournis ou appliqués avant l'initialisation. Le namespace de secours de l'image est un exemple, pas une configuration institutionnelle.

**Action :** Comparez les réglages initiaux à `runtime.properties` actif. Si des données sont déjà chargées, modifier le namespace configuré ne migre pas leurs identifiants. Consultez [[fr_Configuring-VIVO]] avant le changement.

---

## Avertissement de sécurité du navigateur — certificat non approuvé

**Symptôme :** Firefox/Chrome affiche « Risque de sécurité potentiel » ou « Votre connexion n'est pas privée » pour le FQDN.

**Causes possibles :** Aucun FQDN fourni, échec de la demande Certbot, certificat servi expiré, non reconnu ou pour un autre nom. Les essais 1.2.0 utilisaient un certificat autosigné ; ils n'établissent pas la confiance du navigateur.

**Diagnostic :**

```bash
sudo grep -i certbot /var/log/vivo-first-boot.log
sudo cat /var/log/letsencrypt/letsencrypt.log | tail -30
```

**Correction :** Exécutez certbot manuellement — voir [[fr_HTTPS-TLS-Certificate]].

---

## Vérification de l'état des services

```bash
systemctl status tomcat solr nginx
sudo journalctl -u tomcat --no-pager -n 50
sudo tail -100 /opt/tomcat/logs/catalina.out
```

---

## Carte des compétences vide — JSONP bloqué par le type MIME

**Symptôme :**

La carte des compétences VIVO à `/vis/capabilitymap` charge son cadre mais n'affiche aucun nœud, même après le chargement des données d'exemple et avec des données indexées dans Solr. La console du navigateur affiche :

```
La ressource à l'adresse /visualizationAjax... a été bloquée en raison d'un type MIME
(« text/html ») incorrect (X-Content-Type-Options: nosniff)
```

**Cause :**

Dans les déploiements historiques affectés, l'endpoint `/visualizationAjax` de VIVO retournait `Content-Type: text/html` pour toutes les réponses, y compris les réponses JSONP (dont le corps est du JavaScript de la forme `ipretResults({...})`). Nginx applique `X-Content-Type-Options: nosniff` de manière globale. Les navigateurs respectent cette directive et bloquent l'exécution du rappel JSONP, ce qui rend la carte vide.

**Étape 1 — Vérifier que les données sont présentes côté serveur**

Avant de corriger nginx, confirmez que le backend retourne des données :

```bash
curl -sS "https://<fqdn>/visualizationAjax?vis=capabilitymap&query=Rhetoric&callback=ipretResults&noCacheIE=1" | head -c 200
```

Résultat attendu (JSONP) :
```
ipretResults({"researchers":[...], "researchAreas":[...]})
```

Si la sortie est du HTML, examinez statut, authentification et erreurs applicatives avant de conclure à l'absence de données — consultez [[fr_Loading-Sample-Data]].

**Étape 2 — Vérifier l'en-tête Content-Type**

```bash
curl -sS -I "https://<fqdn>/visualizationAjax?vis=capabilitymap&query=Rhetoric&callback=ipretResults&noCacheIE=1" \
  | grep -i content-type
```

- Retourne `text/html` → examiner réponse et configuration active avant de choisir une correction (Étape 3)
- Retourne `application/javascript` → nginx est déjà corrigé, vérifiez la console du navigateur pour d'autres erreurs

**Étape 3 — Examiner le contournement nginx historique**

L'image 1.2.0 inclut déjà le contournement ci-dessous. Pour une ancienne instance affectée, examinez et sauvegardez d'abord la configuration NGINX active. N'ajoutez pas de location en double. Avec un administrateur, envisagez un bloc `location /visualizationAjax {}` dédié dans le bloc `server { listen 443 ... }` du fichier `/etc/nginx/conf.d/vivo.conf` :

```nginx
# Correctif JSONP — VIVO retourne text/html pour /visualizationAjax
location /visualizationAjax {
    proxy_pass         http://127.0.0.1:8080;
    proxy_set_header   Host              $host;
    proxy_set_header   X-Real-IP         $remote_addr;
    proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto https;
    proxy_read_timeout 300s;
    proxy_connect_timeout 60s;
    proxy_hide_header  Content-Type;
    add_header Content-Type              "application/javascript; charset=UTF-8" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains"   always;
    add_header X-Frame-Options           "SAMEORIGIN"                            always;
    add_header Referrer-Policy           "strict-origin-when-cross-origin"       always;
}
```

> **Contournement historique :** Ce bloc reproduit le type MIME JavaScript et les en-têtes locaux de l'image. Retirer `nosniff` n'est pas une exigence générale lorsque le bon type MIME est servi. Selon les [règles standard d'héritage NGINX](https://nginx.org/en/docs/http/ngx_http_headers_module.html#add_header), des directives `add_header` locales affectent l'héritage ; vérifiez version installée et configuration active plutôt que d'en faire une politique générale de sécurité.

Après modification, validez et rechargez nginx :

```bash
sudo nginx -t && sudo systemctl reload nginx
```

Relancez la vérification de l'Étape 2 — `content-type: application/javascript; charset=UTF-8` confirme que la correction est active.

> Le contournement est présent dans l'image 1.2.0. Sa présence ne valide pas toutes les visualisations ; confirmez la réponse et le comportement navigateur avec vos données.
