# Script PowerShell pour démarrer Koha dans Docker
# Usage : .\start_koha_docker.ps1

$cpanfileSnapshot = "cpanfile.snapshot"
if (!(Test-Path -Path $cpanfileSnapshot)) {
    Write-Host "ERREUR : Le fichier cpanfile.snapshot est manquant. Veuillez le générer avec 'carton install' avant de démarrer l'application."
    exit 1
}

Write-Host "Démarrage de Koha dans Docker..."
docker-compose up --build -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "Koha est en cours d'exécution. Accédez à l'application sur : http://localhost:5000"
} else {
    Write-Host "Erreur lors du démarrage de Koha. Vérifiez les logs Docker."
} 