# ================================================================
# Makefile — VIVO Marketplace VM diagnostic orchestration
#
# Usage:
#   make diag    IP=<VM_IP>
#   make diag    IP=<VM_IP> SSH_USER=azureuser SSH_KEY=~/.ssh/my_key
#   make set-dns IP=<VM_IP>
#   make set-dns IP=<VM_IP> DNS=<label>
#   make help
# ================================================================
.PHONY: help diag set-dns

SCRIPTS_DIR := scripts
SSH_USER    ?= azureuser
SSH_KEY     ?=
DNS         ?=

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

diag: ## Run full VM installation diagnostic — make diag IP=<vm_ip>
	@[ -n "$(IP)" ] || (echo "Usage: make diag IP=<vm_ip>"; exit 1)
	@bash $(SCRIPTS_DIR)/vivo-diag.sh $(IP) $(SSH_USER) $(SSH_KEY)

set-dns: ## Assign DNS label to a VM's public IP — make set-dns IP=<vm_ip> [DNS=<label>]
	@[ -n "$(IP)" ] || (echo "Usage: make set-dns IP=<vm_ip> [DNS=<label>]"; exit 1)
	@set -e; \
	 PIP_JSON=$$(az network public-ip list \
	   --query "[?ipAddress=='$(IP)'].{name:name,rg:resourceGroup}" -o json); \
	 PIP_NAME=$$(echo "$$PIP_JSON" | python3 -c \
	   "import sys,json; d=json.load(sys.stdin); print(d[0]['name'])" 2>/dev/null); \
	 PIP_RG=$$(echo "$$PIP_JSON" | python3 -c \
	   "import sys,json; d=json.load(sys.stdin); print(d[0]['rg'])" 2>/dev/null); \
	 [ -n "$$PIP_NAME" ] || { echo "ERROR: aucune IP publique trouvée pour $(IP)"; exit 1; }; \
	 DNS_LABEL="$(DNS)"; \
	 [ -z "$$DNS_LABEL" ] && DNS_LABEL="vivo-$$(echo '$(IP)' | tr '.' '-')"; \
	 echo "IP publique : $$PIP_NAME  [$$PIP_RG]"; \
	 echo "Label DNS   : $$DNS_LABEL"; \
	 az network public-ip update \
	   --resource-group "$$PIP_RG" \
	   --name "$$PIP_NAME" \
	   --dns-name "$$DNS_LABEL" --output none; \
	 FQDN=$$(az network public-ip show \
	   --resource-group "$$PIP_RG" --name "$$PIP_NAME" \
	   --query "dnsSettings.fqdn" -o tsv); \
	 echo "FQDN        : $$FQDN"
