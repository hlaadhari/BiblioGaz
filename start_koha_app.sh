#!/bin/bash

# Script pour démarrer l'application Koha (Plack) avec logs
# Usage : ./start_koha_app.sh

APP_PATH="/home/hlaadhari/BiblioGaz"
CONF_PATH="$APP_PATH/etc/koha-conf.xml"
LOG_DIR="$APP_PATH/log"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/koha-app-$DATE.log"

# Vérifie que le fichier de configuration existe
if [ ! -f "$CONF_PATH" ]; then
  echo "Erreur : le fichier de configuration $CONF_PATH est introuvable."
  exit 1
fi

# Crée le dossier de logs s'il n'existe pas
mkdir -p "$LOG_DIR"

# Se place dans le dossier de l'application
cd "$APP_PATH"

# Exporte la variable d'environnement KOHA_CONF
export KOHA_CONF="$CONF_PATH"
echo "KOHA_CONF défini sur $KOHA_CONF"
echo "Les logs seront dans $LOG_FILE"

# Démarre l'application avec Plack en arrière-plan avec logs
nohup plackup app.psgi > "$LOG_FILE" 2>&1 &
echo "Koha lancé en arrière-plan (PID $!)" 