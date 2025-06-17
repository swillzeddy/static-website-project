#!/bin/bash

# ==== CONFIGURATION ====
RESOURCE_GROUP="staticSiteGroup"
LOCATION="uksouth"
VM_NAME="staticSiteVM"
ADMIN_USERNAME="azureuser"
GITHUB_REPO="https://github.com/swillzeddy/static-website-project.git"
DNS_LABEL="edmweb$RANDOM"

# === STEP 1: CREATE RESOURCE GROUP ===
az group create --name $RESOURCE_GROUP --location $LOCATION

# === STEP 2: CREATE VM ===
az vm create \
 --resource-group $RESOURCE_GROUP \
 --name $VM_NAME \
 --image Ubuntu2204 \
 --admin-username $ADMIN_USERNAME \
 --generate-ssh-keys \
 --public-ip-sku Standard \
 --public-ip-address-dns-name $DNS_LABEL

# === STEP 3: OPEN PORT 80 ===
az vm open-port --port 80 --resource-group $RESOURCE_GROUP --name $VM_NAME

# === STEP 4: INSTALL NGINX & CLONE WEBSITE ===
az vm run-command invoke \
 --command-id RunShellScript \
 --name $VM_NAME \
 --resource-group $RESOURCE_GROUP \
 --scripts "
 sudo apt update &&
 sudo apt install -y nginx git &&
 sudo rm -rf /var/www/html/* &&
 sudo git clone $GITHUB_REPO /var/www/html &&
 sudo systemctl restart nginx
"

# === STEP 5: SHOW PUBLIC IP ===
PUBLIC_IP=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)
echo 'Website deployed at:'
echo "http://$PUBLIC_IP"