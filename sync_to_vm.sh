#!/bin/bash

# Script de synchronisation du code source Koha vers la VM Ubuntu
# Usage : ./sync_to_vm.sh

VM_USER="hlaadhari"
VM_HOST="192.168.124.129"
VM_PATH="/home/hlaadhari/BiblioGaz"

# Synchronise tout le code sauf les fichiers ignorés par git
rsync -avz --delete --exclude-from='.gitignore' ./ "$VM_USER@$VM_HOST:$VM_PATH"

echo "Synchronisation terminée vers $VM_USER@$VM_HOST:$VM_PATH"

chmod +x sync_to_vm.sh 