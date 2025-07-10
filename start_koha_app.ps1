# Script PowerShell pour démarrer l'application Koha dans un conteneur Docker
# Usage : .\start_koha_app.ps1

$IMAGE_NAME = "koha:latest" # À adapter selon ton image
$CONTAINER_NAME = "koha-app"
$APP_PATH = "C:\Users\GitHub\BiblioGaz" # Chemin local à adapter si besoin
$LOG_DIR = "$APP_PATH\log"
$DATE = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOG_FILE = "$LOG_DIR\koha-app-$DATE.log"

# Créer le dossier de logs s'il n'existe pas
if (!(Test-Path -Path $LOG_DIR)) {
    New-Item -ItemType Directory -Path $LOG_DIR | Out-Null
}

# Arrêter et supprimer l'ancien conteneur si besoin
if (docker ps -a --format '{{.Names}}' | Select-String -Pattern "^$CONTAINER_NAME$") {
    docker stop $CONTAINER_NAME | Out-Null
    docker rm $CONTAINER_NAME | Out-Null
}

# Lancer le conteneur Docker
Write-Host "Démarrage de Koha dans Docker..."
docker run -d --name $CONTAINER_NAME `
    -v "$APP_PATH`:/app" `
    -v "$LOG_DIR`:/app/log" `
    -e KOHA_CONF="/app/etc/koha-conf.xml" `
    -p 5000:5000 ` # Adapter le port si besoin
    $IMAGE_NAME

Write-Host "Koha lancé dans Docker. Pour voir les logs : docker logs -f $CONTAINER_NAME" 