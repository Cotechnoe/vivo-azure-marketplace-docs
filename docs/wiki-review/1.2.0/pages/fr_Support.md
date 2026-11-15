# Support

> 🇬🇧 This page is also available in English: [[Support]]

Cette page répertorie tous les canaux d'assistance disponibles pour l'offre **VIVO Research Profiles** sur Azure Marketplace.

---

## Support de l'éditeur — Cotechnoe

Pour les problèmes spécifiques à cette offre Azure Marketplace VM (échecs de déploiement, erreurs du modèle ARM, configuration de la VM, bogues d'image), contactez directement l'éditeur :

- **Courriel :** [support@cotechnoe.com](mailto:support@cotechnoe.com)
- **Issues GitHub :** [https://github.com/Cotechnoe/vivo-azure-marketplace-docs/issues](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/issues)

Lors de la déclaration d'un problème, veuillez inclure :

- La version d'image (par exemple 1.2.0), les versions VIVO/Vitro et le statut public ou préversion, sans les confondre
- Le parcours de configuration réellement suivi (Marketplace/Custom data ou ARM direct)
- La région Azure et la taille de VM utilisées
- La sortie de `sudo cloud-init status --long`
- Les extraits de journaux pertinents de `/var/log/vivo-first-boot.log` ou `sudo journalctl -u tomcat --no-pager -n 50`

---

Relisez et expurgez toute sortie avant publication. Ne joignez ni secrets, mots de passe, clés privées, jetons, adresses IP, noms d'hôtes internes ni données personnelles. `make diag` peut afficher configuration et journaux ; ne collez pas sa sortie complète sans revue. La préparation d'un diagnostic n'autorise pas une suppression ou une réinitialisation.

Les responsabilités de maintenance, certificats, sauvegardes et récupération sont décrites dans [[fr_Configuring-VIVO#exploitation-sauvegardes-et-coûts]]. Ne considérez pas un test réussi ou une certification Marketplace comme une garantie de conformité ou de capacité.

---

## Support de la communauté VIVO

Pour les questions sur la configuration de VIVO, la personnalisation de l'ontologie, l'ingestion de données ou le comportement de l'application, la communauté VIVO offre plusieurs canaux d'assistance :

| Canal | Détails |
|-------|---------|
| **Liste de diffusion communautaire** | [vivo-all@googlegroups.com](mailto:vivo-all@googlegroups.com) — liste principale pour la discussion générale et l'assistance |
| **Liste de diffusion technique** | [vivo-tech@googlegroups.com](mailto:vivo-tech@googlegroups.com) — pour les questions techniques et de développement |
| **GitHub Discussions / Issues** | [https://github.com/vivo-project/VIVO/issues](https://github.com/vivo-project/VIVO/issues) |
| **Page de contact VIVO** | [https://vivoweb.org/contact/](https://vivoweb.org/contact/) |
| **LYRASIS (gestionnaire de la communauté)** | [https://www.lyrasis.org/contact](https://www.lyrasis.org/contact) |

---

## Documentation et ressources d'auto-assistance

| Ressource | URL |
|-----------|-----|
| Ce wiki | [https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki](https://github.com/Cotechnoe/vivo-azure-marketplace-docs/wiki) |
| Documentation officielle VIVO | [https://wiki.lyrasis.org/display/VIVODOC](https://wiki.lyrasis.org/display/VIVODOC) |
| Site web du projet VIVO | [https://vivoweb.org/](https://vivoweb.org/) |
| Guide de résolution de problèmes | [[fr_Troubleshooting]] |

---

## Support Azure

Pour les problèmes avec l'infrastructure Azure elle-même (VM ne démarrant pas, réseau, limites d'abonnement), utilisez les canaux de support Azure standard :

- **Portail de support Azure :** [https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade)
- **Documentation Azure :** [https://learn.microsoft.com/fr-fr/azure/](https://learn.microsoft.com/fr-fr/azure/)

---

*Page originale (English) : [[Support]]*
