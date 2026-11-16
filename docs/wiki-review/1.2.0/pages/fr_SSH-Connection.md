# Connexion SSH

> 🇬🇧 This page is also available in English: [[SSH-Connection]]

Comment préparer une clé SSH et se connecter à votre VM VIVO. Le compte SSH est distinct du compte administrateur web VIVO.

---

## Générer une paire de clés

Sur votre poste de travail, utilisez OpenSSH (`ssh-keygen` est disponible sous Linux, macOS et les versions récentes de Windows). Cet exemple crée une clé RSA dédiée; changez le nom du fichier s'il existe déjà et n'écrasez pas une clé dont vous avez encore besoin.

```bash
mkdir -p -m 700 ~/.ssh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_vivo_azure
cat ~/.ssh/id_vivo_azure.pub
```

Choisissez une phrase secrète robuste à l'invite et conservez-la en lieu sûr. Collez le contenu complet du fichier `.pub` dans le champ de clé publique SSH du déploiement. Gardez `~/.ssh/id_vivo_azure` privé : ne le téléversez jamais dans l'assistant, ne le commitez pas et ne l'envoyez pas au support. Consultez les [instructions SSH de Microsoft](https://learn.microsoft.com/fr-fr/azure/virtual-machines/linux/create-ssh-keys-detailed).

Si l'assistant propose plutôt de générer la clé, conservez la clé privée téléchargée en lieu sûr et suivez ses instructions. La disponibilité de cette option n'a pas été vérifiée pour toutes les versions de l'offre.

Pour les outils non interactifs `make diag` et `make certbot`, indiquez le chemin de cette clé avec `SSH_KEY=~/.ssh/id_vivo_azure` et chargez au préalable la clé protégée par phrase secrète dans votre agent SSH.

---

## Se connecter avec la clé privée

```bash
ssh -i ~/.ssh/id_vivo_azure <nom-admin>@<ip-publique>
```

Remplacez le nom d'utilisateur et l'adresse IP publique par ceux du déploiement. Pour une clé PEM téléchargée depuis Azure, utilisez son chemin à la place. Si SSH rejette cette clé en raison des permissions (fréquent sur Windows/WSL) :

```bash
# Copiez d'abord la clé dans le système de fichiers Linux (utilisateurs WSL)
cp /mnt/c/Users/<VotreNom>/Downloads/your-key.pem ~/.ssh/
chmod 600 ~/.ssh/your-key.pem
ssh -i ~/.ssh/your-key.pem <nom-admin>@<ip-publique>
```

---

## Obtenir l'adresse IP publique

Après le déploiement, relevez l'adresse prévue pour SSH dans la configuration réseau de la VM. Une IP publique ou une sortie de déploiement `publicIPAddress` dépend du parcours choisi ; un déploiement privé exige un accès réseau adapté. Vérifiez la règle NSG autorisant votre source d'administration.

---

## Première connexion

Lors de la première connexion, SSH affichera l'empreinte de l'hôte et demandera sa confirmation :

```
Are you sure you want to continue connecting (yes/no)?
```

Avant d'accepter, comparez l'empreinte affichée à celle de la clé hôte de la VM obtenue par un canal indépendant et fiable. Si elles ne correspondent pas, ou si vous ne pouvez pas les vérifier, arrêtez et contactez l'administrateur. Tapez `yes` seulement après concordance. Si une clé hôte déjà enregistrée change, vérifiez la cause avant de la retirer ou de la remplacer.

---

## Format de la clé SSH

Le paramètre `adminPublicKey` requiert le format **OpenSSH** :

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... your-comment
```

Les clés RSA (`ssh-rsa AAAA...`, d'au moins 2048 bits) sont également prises en charge. Utilisez la clé privée pour SSH et la clé publique correspondante pour le déploiement.

---

*Page originale (English) : [[SSH-Connection]]*
