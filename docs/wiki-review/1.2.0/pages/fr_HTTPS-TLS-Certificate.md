# Certificat HTTPS / TLS

> 🇬🇧 This page is also available in English: [[HTTPS-TLS-Certificate]]

VIVO est servi exclusivement via HTTPS (port 443). Cette page explique comment le certificat TLS est provisionné et ce à quoi vous devez vous attendre.

---

## Certificat Let's Encrypt automatique

L'image **1.2.0** démarre avec un **certificat autosigné**. Son script de premier démarrage ne tente Let's Encrypt que si `VIVO_FQDN` est non vide et si Certbot est disponible. Vérifiez que le déploiement fournit réellement cette valeur : le modèle ARM de référence le fait, mais cela ne démontre pas le comportement de l'assistant Marketplace. Assigner un nom DNS après le premier démarrage ne relance pas à lui seul la demande de certificat.

Les essais archivés de la 1.2.0 utilisaient un certificat autosigné avec vérification de confiance contournée. L'obtention d'un certificat reconnu par le navigateur n'a **pas** été démontrée sur ce parcours Marketplace. La procédure ci-dessous décrit une intervention d'administration ou de récupération, et non une émission réussie observée pour cette préversion.

Pour le [défi HTTP-01](https://letsencrypt.org/docs/challenge-types/#http-01-challenge) du greffon NGINX, le DNS public doit résoudre vers le point d'accès prévu et le port entrant **80** doit être accessible à l'autorité de certification. Une règle NSG limitée à votre poste ne suffit pas à ce défi. Pour un service privé, prévoyez un certificat institutionnel ou une autre méthode de validation configurée séparément ; DNS-01 n'est pas configuré par cette image.

**Fonctionnement :**

1. Nginx démarre avec le certificat configuré par l'image.
2. Lorsque les conditions ci-dessus sont remplies, le premier démarrage tente `certbot --nginx` pour le FQDN fourni, par exemple :
   ```
   {projectName}-{uniqueHash}.{region}.cloudapp.azure.com
   ```
3. Let's Encrypt doit pouvoir compléter le défi ACME HTTP-01 sur le port 80.
4. Si l'émission réussit, Nginx sert le nouveau certificat. En cas d'échec, le certificat de secours de l'image peut rester actif.

Le délai de réussite n'est pas garanti. Vérifiez le certificat effectivement servi avant d'utiliser le site ou d'entrer des identifiants. Si le provisionnement automatique échoue, suivez la procédure manuelle ci-dessous.

---

## Vérifier le certificat

Vérifiez le certificat configuré sur la VM :

```bash
# Depuis la VM
sudo certbot certificates

# Exemple après émission réussie :
# Found the following certs:
#   Certificate Name: vivo-xxxx.canadacentral.cloudapp.azure.com
#   Domains: vivo-xxxx.canadacentral.cloudapp.azure.com
#   Expiry Date: <date> (VALID: <jours restants>)
#   Certificate Path: /etc/letsencrypt/live/.../fullchain.pem
```

Depuis un poste de travail, vérifiez le certificat servi pour le FQDN. `curl` utilise la validation habituelle de l'autorité de certification et du nom d'hôte :

```bash
FQDN="<fqdn>"
curl --silent --show-error --output /dev/null \
  --write-out 'HTTP %{http_code}; résultat de vérification TLS %{ssl_verify_result}\n' \
  "https://${FQDN}/"
```

La commande doit se terminer avec succès et indiquer un résultat de vérification TLS `0` ; une réponse HTTP ou une date d'expiration ne suffit pas. N'ajoutez pas `-k` à ce contrôle de confiance. Vous pouvez aussi examiner le certificat dans le navigateur et confirmer que son sujet/SAN comprend le FQDN et que le navigateur fait confiance à son émetteur.

---

## Avertissement de sécurité du navigateur (certificat auto-signé de secours)

Si aucun FQDN n'a été fourni, aucune demande n'a été faite. En cas d'échec d'une demande (DNS non prêt, port 80 bloqué ou limite ACME atteinte, par exemple), le certificat autosigné peut rester actif. Un certificat personnalisé expiré ou ne correspondant pas au nom peut aussi provoquer un avertissement.

**Symptôme :** Le navigateur indique que le certificat n'est pas fiable, qu'il est expiré ou qu'il ne correspond pas au FQDN.

Ne contournez pas l'avertissement et n'entrez pas d'identifiants sur un déploiement qui devrait utiliser un certificat fiable. Vérifiez le FQDN, le DNS et le certificat servi, puis suivez la procédure manuelle ci-dessous. N'utilisez un certificat non fiable que dans un environnement de test isolé, sans données ni identifiants sensibles.

N'utilisez pas l'adresse IP publique comme URL dans le navigateur : le certificat est émis pour un nom d'hôte, pas pour l'adresse IP.

---

## Provisionnement manuel du certificat

Si aucune demande n'a été faite ou si le provisionnement automatique a échoué, confirmez d'abord que le FQDN résout vers l'adresse IP publique actuelle de la VM et que le port entrant 80 est accessible. Depuis un clone du dépôt documentaire sur votre poste, avec `make`, OpenSSH et OpenSSL installés, demandez le certificat avec :

```bash
make certbot IP=<ip-publique-vm> FQDN=<fqdn> EMAIL=<votre@courriel.com> SSH_KEY=~/.ssh/votre-clé.pem
```

Le script retourne un code non nul si Certbot, la validation Nginx, SSH, l'activation du minuteur de renouvellement ou la vérification finale du certificat servi échoue. Si seul un fichier cron de renouvellement est trouvé, il indique sa présence sans prétendre que l'exécution de cron a été vérifiée. Le contrôle TLS valide la chaîne du certificat et le FQDN tout en se connectant à l'adresse IP fournie.

SSH utilise OpenSSH `StrictHostKeyChecking=accept-new` : la première clé présentée est enregistrée dans `known_hosts` et une clé modifiée est rejetée. Il s'agit d'une confiance à la première utilisation, et non d'une vérification indépendante de l'identité; si possible, vérifiez l'empreinte de la clé hôte SSH de la VM par un canal fiable avant la première connexion.

Sinon, connectez-vous directement en SSH à la VM et exécutez Certbot manuellement après avoir vérifié que le port 80 est accessible :

```bash
FQDN="<fqdn>"

sudo certbot --nginx \
  -d "${FQDN}" \
  --non-interactive \
  --agree-tos \
  --email "your@email.com" \
  --redirect
```

Validez Nginx puis vérifiez le certificat depuis votre poste de travail :

```bash
sudo nginx -t
sudo certbot certificates
```

```bash
curl --silent --show-error --output /dev/null \
  --write-out 'HTTP %{http_code}; résultat de vérification TLS %{ssl_verify_result}\n' \
  "https://${FQDN}/"
```

---

## Renouvellement du certificat

Consultez les [instructions de renouvellement Certbot](https://eff-certbot.readthedocs.io/en/stable/using.html#automated-renewals) et vérifiez le mécanisme configuré pour cette image ; il peut s'agir d'un minuteur systemd ou d'une tâche cron. Ne supposez pas qu'un minuteur ou une entrée cron est actif simplement parce qu'un certificat existe.

Pour un minuteur systemd :

```bash
sudo systemctl status --no-pager certbot.timer
sudo systemctl is-enabled certbot.timer
sudo systemctl is-active certbot.timer
```

Si l'image utilise `/etc/cron.d/certbot`, examinez ce fichier et vérifiez que le service cron est en cours d'exécution. `sudo certbot renew --dry-run` teste le renouvellement auprès du service ACME de préproduction; cette commande effectue une requête réseau externe et ne doit être exécutée qu'avec autorisation.

---

## Journaux

```bash
# Journal d'initialisation de la VM (inclut la sortie certbot)
sudo grep -i certbot /var/log/vivo-first-boot.log

# Journal complet certbot
sudo tail -50 /var/log/letsencrypt/letsencrypt.log
```

---

## Utiliser un certificat personnalisé

Si votre institution fournit son propre certificat TLS, identifiez d'abord le bloc serveur Nginx actif pour le FQDN et les chemins de certificat qu'il utilise réellement. Certbot peut modifier ces chemins; ne supposez pas qu'ils sont toujours `/etc/nginx/ssl/vivo.crt` et `/etc/nginx/ssl/vivo.key`.

```bash
sudo nginx -T 2>/dev/null | grep -nE 'server_name|ssl_certificate(_key)?[[:space:]]'
```

Repérez le bloc `server_name` de votre FQDN et ses directives `ssl_certificate` et `ssl_certificate_key`. Sauvegardez la configuration active et les fichiers de certificat avant de les modifier. Installez la chaîne de certificats et la clé privée correspondante dans des chemins gérés par votre organisation, modifiez uniquement ce bloc serveur et limitez l'accès à la clé privée au processus privilégié qui en a besoin. N'écrasez pas de liens symboliques ni de fichiers gérés par Certbot sans confirmer qui les renouvelle.

Validez et rechargez Nginx, puis vérifiez le certificat servi pour le FQDN avec la commande `curl` ci-dessus :

```bash
sudo nginx -t && sudo systemctl reload nginx
```

Ne désactivez pas `certbot.timer` sans vérification. Confirmez d'abord qu'aucun certificat géré par Certbot n'en dépend et documentez le renouvellement du certificat personnalisé.

---

*Page originale (English) : [[HTTPS-TLS-Certificate]]*
