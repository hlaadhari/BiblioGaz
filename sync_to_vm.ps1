# Script PowerShell pour synchroniser le code source Koha vers la VM Ubuntu
# Usage : .\sync_to_vm.ps1

$VM_USER = "hlaadhari"
$VM_HOST = "192.168.124.129"
$VM_PATH = "/home/hlaadhari/BiblioGaz"

# Chemin local du projet
$LOCAL_PATH = "$PSScriptRoot"

# Synchronisation des fichiers suivis par git (hors .gitignore)
# Nécessite Git et OpenSSH installés sur Windows

# Récupère la liste des fichiers suivis par git
$files = git ls-files
foreach ($file in $files) {
    $dest = $VM_USER + "@" + $VM_HOST + ":" + $VM_PATH + "/" + $file
    Write-Host "Transfert de $file vers $dest"
    scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $file $dest
}

# Copie manuelle du fichier de config même s'il est ignoré
$conf = "etc/koha-conf.xml"
if (Test-Path $conf) {
    $dest = $VM_USER + "@" + $VM_HOST + ":" + $VM_PATH + "/" + $conf
    Write-Host "Transfert de $conf vers $dest"
    scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $conf $dest
}

Write-Host ("Synchronisation terminée vers " + $VM_USER + "@" + $VM_HOST + ":" + $VM_PATH) 