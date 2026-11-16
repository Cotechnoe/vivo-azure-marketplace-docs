# Quick Start Evaluation

> 🇫🇷 Cette page est également disponible en français : [[fr_Quick-Start-Evaluation]]

Use this guide to confirm that the VIVO Azure Marketplace offer deploys and opens successfully. It creates a temporary evaluation environment, not a production service.

> Use the complete [[Deploying-from-Marketplace]] guide when you plan to keep the instance or load institutional data.

> **Timing:** Account verification, regional capacity, VM initialization and certificate issuance vary; no deployment or certificate completion time is guaranteed.

---

## Before you start

### 1. Create an Azure account and subscription

1. Create a [Microsoft account](https://account.microsoft.com/account) if you do not already have one.
2. Go to [Azure Free](https://azure.microsoft.com/free/) and create an Azure account. The sign-up process creates or activates an Azure subscription; it may ask for identity and payment verification.
3. Sign in to the [Azure portal](https://portal.azure.com/) and confirm that you can select an active subscription.

The Marketplace plan, VM, public IP address and disks may incur charges; do not assume the offer is covered by free credits or free-account services. Review the pricing and subscription terms shown during sign-up before continuing.

### 2. Diagnose access for an existing account

If you have just created a personal Azure account, continue to the next step. For an existing subscription or organization account, check the following in the Azure portal:

1. Open **Subscriptions** and confirm that the subscription you intend to use is active.
2. If the subscription is not listed, open the account menu, select **Switch directory**, then check the subscriptions available in the correct directory.
3. Open the intended subscription or resource group, then **Access control (IAM)** and **View my access**. You need the **Contributor** or **Owner** role at that scope.

If the subscription is disabled, missing from the correct directory, or neither role is assigned, ask its administrator to grant you **Contributor** access to the resource group or subscription.

### 3. Prepare SSH access

In the Marketplace wizard, use **Generate new key pair** when that option is available. Download the private key file when prompted and keep it in a safe location: Azure cannot download it again later.

If the wizard only asks you to paste an SSH public key, create one first by following [[SSH-Connection]].

### 4. Plan cleanup

Use a dedicated evaluation resource group and keep institutional data out of it. Agree who may remove the resources when the trial is finished. Review both the plan price and Azure infrastructure charges before creating anything.

## Step 1 — Select the offer and image

Open the [VIVO offer](https://marketplace.microsoft.com/en-us/product/cotechnoe.vivo-research-profiles?tab=Overview). Confirm whether you are evaluating the public offer or the 1.2.0 preview; the dated [[release status|Home#image-120--status-and-verification]] distinguishes them.

## Step 2 — Configure and deploy

Follow [[Deploying-from-Marketplace]] for VM, disks, network and the intended Custom data path of image 1.2.0. That guide supplies the configuration example and distinguishes direct ARM deployment. The archived image checks are not an end-to-end validation of the Marketplace wizard.

Use a temporary namespace such as `https://vivo-evaluation.example.org/individual/`, a controlled administrator email and one locale such as `en_US`. Choose VM/disk capacity for the evaluation; no minimum size or workload capacity is established here.

## Step 3 — Verify initialization and HTTPS

Follow [[Post-Deployment-Verification]] to check cloud-init, storage and services. Then configure DNS if needed and follow [[HTTPS-TLS-Certificate]] to obtain and verify a certificate for `https://<fqdn>/` before entering credentials. An HTTP response with certificate verification disabled is not evidence of browser trust.

A rendered home page confirms only that page's response. Check the intended account, configuration and functions separately; sample-data import is not established by the form-population tests.

## Step 4 — Finish the evaluation

Before deleting anything, confirm the resource group contains only disposable evaluation resources and preserve anything needed through a restorable backup. When authorized, remove that dedicated group, verify deletion completed, and review remaining resources and billing. Resources outside that group, backups and retained storage may continue to incur charges. See [Azure VM states and billing](https://learn.microsoft.com/en-us/azure/virtual-machines/states-billing).

## Next steps

- Review [[Configuring-VIVO#operations-backups-and-costs]] before keeping the service.
- Use [[Loading-Sample-Data]] only on a dedicated non-production instance.
