# ================================================================
# Makefile — VIVO Marketplace VM diagnostic orchestration
# (ADR-602 : Makefile comme orchestrateur de scripts)
#
# Usage:
#   make diag    IP=<VM_IP>
#   make diag    IP=<VM_IP> SSH_USER=azureuser SSH_KEY=~/.ssh/my_key
#   make set-dns IP=<VM_IP> [DNS=<label>]
#   make certbot IP=<VM_IP> FQDN=<fqdn> EMAIL=<email>
#   make help
# ================================================================
.PHONY: help diag set-dns certbot

SCRIPTS_DIR := scripts
SSH_USER    ?= azureuser
SSH_KEY     ?=
DNS         ?=

# Couleurs
BLUE   := \033[0;34m
GREEN  := \033[0;32m
YELLOW := \033[1;33m
NC     := \033[0m

##@ Aide

help: ## Afficher cette aide
	@echo "$(BLUE)══════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)  VIVO Marketplace — Outils diagnostic VM         $(NC)"
	@echo "$(BLUE)══════════════════════════════════════════════════$(NC)"
	@awk 'BEGIN {FS = ":.*##"} /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0,5) } /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

##@ Diagnostic

diag: ## Diagnostic complet d'installation VM — make diag IP=<vm_ip>
	@[ -n "$(IP)" ] || (echo "Usage: make diag IP=<vm_ip>"; exit 1)
	@bash $(SCRIPTS_DIR)/vivo-diag.sh "$(IP)" "$(SSH_USER)" "$(SSH_KEY)"

##@ DNS & TLS

set-dns: ## Assigner un label DNS à l'IP publique d'une VM — make set-dns IP=<vm_ip> [DNS=<label>]
	@[ -n "$(IP)" ] || (echo "Usage: make set-dns IP=<vm_ip> [DNS=<label>]"; exit 1)
	@bash $(SCRIPTS_DIR)/set-dns.sh "$(IP)" "$(DNS)"

certbot: ## Obtenir/renouveler un certificat Let's Encrypt — make certbot IP=<ip> FQDN=<fqdn> EMAIL=<email>
	@[ -n "$(IP)"    ] || (echo "Usage: make certbot IP=<ip> FQDN=<fqdn> EMAIL=<email>"; exit 1)
	@[ -n "$(FQDN)"  ] || (echo "Usage: make certbot IP=<ip> FQDN=<fqdn> EMAIL=<email>"; exit 1)
	@[ -n "$(EMAIL)" ] || (echo "Usage: make certbot IP=<ip> FQDN=<fqdn> EMAIL=<email>"; exit 1)
	@bash $(SCRIPTS_DIR)/certbot.sh "$(IP)" "$(FQDN)" "$(EMAIL)" "$(SSH_USER)" "$(SSH_KEY)"
