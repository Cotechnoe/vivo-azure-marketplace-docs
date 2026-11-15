# SSH Connection

> 🇫🇷 Cette page est également disponible en français : [[fr_SSH-Connection]]

How to prepare an SSH key and connect to your VIVO VM. The SSH account is separate from the VIVO web administrator account.

---

## Generate a key pair

On your workstation, use OpenSSH (`ssh-keygen` is available on Linux, macOS, and recent Windows installations). This example creates a dedicated RSA key; change the filename if it already exists and do not overwrite a key you still need.

```bash
mkdir -p -m 700 ~/.ssh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_vivo_azure
cat ~/.ssh/id_vivo_azure.pub
```

Choose a strong passphrase when prompted and store it safely. Paste the complete contents of the `.pub` file into the deployment's SSH public key field. Keep `~/.ssh/id_vivo_azure` private: never upload it to the wizard, commit it, or send it to support. See [Microsoft's SSH key guidance](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed).

If the wizard offers key generation instead, save the downloaded private key securely and follow that wizard's instructions. Availability of this option has not been verified for every version of the offer.

For the non-interactive `make diag` and `make certbot` helpers, pass this key's path using `SSH_KEY=~/.ssh/id_vivo_azure` and load a passphrase-protected key into your SSH agent before running them.

---

## Connect with your private key

```bash
ssh -i ~/.ssh/id_vivo_azure <admin-username>@<public-ip>
```

Replace the username and public IP with the values from your deployment. For an Azure-downloaded PEM key, use its path instead. If SSH rejects that key due to permissions (common on Windows/WSL):
```bash
# Copy key to Linux filesystem first (WSL users)
cp /mnt/c/Users/<YourName>/Downloads/your-key.pem ~/.ssh/
chmod 600 ~/.ssh/your-key.pem
ssh -i ~/.ssh/your-key.pem <admin-username>@<public-ip>
```

---

## Get the public IP

After deployment, find the intended SSH address in the VM's network configuration. A public IP or a deployment output named `publicIPAddress` depends on the deployment path; a private VM requires suitable network access. Verify the NSG rule allowing your administration source.

---

## First connection

On first connection, SSH will show the host fingerprint and ask for confirmation:
```
Are you sure you want to continue connecting (yes/no)?
```
Before accepting, compare the displayed fingerprint with the VM's host-key fingerprint obtained through a trusted, independent channel. If it does not match, or if you cannot verify it, stop and contact the administrator. Type `yes` only after a match. If a previously saved host key changes, investigate before removing or replacing it.

---

## SSH key format

The `adminPublicKey` parameter requires **OpenSSH format**:
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... your-comment
```

RSA keys (`ssh-rsa AAAA...`, at least 2048 bits) are also supported. Use the private key for SSH and the corresponding public key for deployment.
