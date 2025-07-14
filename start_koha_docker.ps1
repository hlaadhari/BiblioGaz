# Script PowerShell pour gérer Koha dans Docker
# Usage : .\start_koha_docker.ps1

# Configuration de l'encodage UTF-8 pour l'affichage correct des accents
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null

# Fonction pour afficher un titre avec style
function Show-Title {
    param([string]$Title)
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║" -ForegroundColor Blue -NoNewline
    Write-Host " $Title".PadRight(76) -ForegroundColor White -NoNewline
    Write-Host "║" -ForegroundColor Blue
    Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
}

# Fonction pour afficher des messages avec icônes et couleurs
function Write-Message {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )
    
    switch ($Type) {
        "INFO" { 
            Write-Host "ℹ️  " -NoNewline -ForegroundColor Cyan
            Write-Host $Message -ForegroundColor White
        }
        "SUCCESS" { 
            Write-Host "✅ " -NoNewline -ForegroundColor Green
            Write-Host $Message -ForegroundColor Green
        }
        "ERROR" { 
            Write-Host "❌ " -NoNewline -ForegroundColor Red
            Write-Host $Message -ForegroundColor Red
        }
        "WARNING" { 
            Write-Host "⚠️  " -NoNewline -ForegroundColor Yellow
            Write-Host $Message -ForegroundColor Yellow
        }
        "PROGRESS" { 
            Write-Host "🔄 " -NoNewline -ForegroundColor Magenta
            Write-Host $Message -ForegroundColor Magenta
        }
    }
}

# Fonction pour afficher une barre de progression
function Show-ProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Activity = "Progression"
    )
    
    $percent = [math]::Round(($Current / $Total) * 100)
    $barLength = 50
    $filledLength = [math]::Round(($percent / 100) * $barLength)
    
    $bar = "█" * $filledLength + "░" * ($barLength - $filledLength)
    
    Write-Host "`r🔄 $Activity : [" -NoNewline -ForegroundColor Cyan
    Write-Host $bar -NoNewline -ForegroundColor Green
    Write-Host "] $percent%" -NoNewline -ForegroundColor Cyan
    
    if ($percent -eq 100) {
        Write-Host " - Terminé !" -ForegroundColor Green
    }
}

function Check-Docker {
    Write-Message "Vérification de Docker..." "INFO"
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Message "Docker n'est pas installé ou n'est pas dans le PATH. Veuillez l'installer avant de continuer." "ERROR"
        return $false
    }
    Write-Message "Docker détecté : $dockerVersion" "SUCCESS"
    return $true
}

function Check-Compose {
    Write-Message "Vérification de docker-compose..." "INFO"
    $composeVersion = docker-compose --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Message "docker-compose n'est pas installé ou n'est pas dans le PATH. Veuillez l'installer avant de continuer." "ERROR"
        return $false
    }
    Write-Message "Docker Compose détecté : $composeVersion" "SUCCESS"
    return $true
}

function Start-Koha {
    Show-Title "DÉMARRAGE DE KOHA"
    
    if (-not (Check-Docker)) { return }
    if (-not (Check-Compose)) { return }
    
    Write-Message "Construction et démarrage de Koha dans Docker..." "INFO"
    docker-compose up --build -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Message "Conteneurs démarrés avec succès !" "SUCCESS"
        Write-Message "Vérification de l'installation des dépendances Perl..." "INFO"
        Write-Message "Cela peut prendre plusieurs minutes. Affichage des logs d'installation :" "WARNING"
        
        Write-Host ""
        Write-Host "┌─────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
        Write-Host "│" -ForegroundColor DarkGray -NoNewline
        Write-Host " LOGS D'INSTALLATION EN TEMPS RÉEL".PadRight(75) -ForegroundColor Yellow -NoNewline
        Write-Host "│" -ForegroundColor DarkGray
        Write-Host "└─────────────────────────────────────────��───────────────────────────────────┘" -ForegroundColor DarkGray
        
        # Attendre que l'installation se termine en affichant les logs
        $timeout = 300  # 5 minutes maximum
        $elapsed = 0
        $interval = 5
        
        do {
            Start-Sleep -Seconds $interval
            $elapsed += $interval
            
            # Afficher la barre de progression
            Show-ProgressBar -Current $elapsed -Total $timeout -Activity "Installation des dépendances"
            
            # Afficher les dernières lignes des logs
            $logs = docker-compose logs app --tail=2 2>$null
            if ($logs) {
                $logs | ForEach-Object { 
                    Write-Host "  📦 " -NoNewline -ForegroundColor Blue
                    Write-Host $_ -ForegroundColor Gray
                }
            }
            
            # Vérifier si Starman a démarré (signe que l'installation est terminée)
            $starmanRunning = docker-compose logs app 2>$null | Select-String "Starman" -Quiet
            if ($starmanRunning) {
                Write-Host ""
                Write-Message "Installation terminée ! Starman est démarré." "SUCCESS"
                break
            }
            
            # Vérifier si le conteneur est encore en cours d'exécution
            $containerStatus = docker-compose ps app --format "{{.Status}}" 2>$null
            if ($containerStatus -notlike "*Up*") {
                Write-Host ""
                Write-Message "Le conteneur de l'application s'est arrêté. Vérifiez les logs complets." "ERROR"
                return
            }
            
        } while ($elapsed -lt $timeout)
        
        if ($elapsed -ge $timeout) {
            Write-Host ""
            Write-Message "L'installation prend plus de temps que prévu. L'application peut encore être en cours d'installation." "WARNING"
        }
        
        Write-Host ""
        Write-Host "┌─────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
        Write-Host "│" -ForegroundColor Green -NoNewline
        Write-Host " 🎉 KOHA EST PRÊT !".PadRight(75) -ForegroundColor White -NoNewline
        Write-Host "│" -ForegroundColor Green
        Write-Host "│" -ForegroundColor Green -NoNewline
        Write-Host " 🌐 URL : http://localhost:5000".PadRight(75) -ForegroundColor Cyan -NoNewline
        Write-Host "│" -ForegroundColor Green
        Write-Host "│" -ForegroundColor Green -NoNewline
        Write-Host " 💡 Utilisez l'option 3 pour voir les logs complets si nécessaire".PadRight(75) -ForegroundColor Yellow -NoNewline
        Write-Host "│" -ForegroundColor Green
        Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
        Write-Host ""
        
    } else {
        Write-Message "Erreur lors du démarrage de Koha. Vérifiez les logs Docker." "ERROR"
    }
}

function Stop-Koha {
    Show-Title "ARRÊT DE KOHA"
    Write-Message "Arrêt de Koha et des conteneurs Docker..." "INFO"
    docker-compose down
    if ($LASTEXITCODE -eq 0) {
        Write-Message "Koha arrêté avec succès !" "SUCCESS"
    } else {
        Write-Message "Erreur lors de l'arrêt de Koha." "ERROR"
    }
}

function Logs-Koha {
    Show-Title "LOGS DE L'APPLICATION KOHA"
    Write-Message "Affichage des 100 dernières lignes des logs :" "INFO"
    Write-Host ""
    docker-compose logs app --tail=100
}

function Status-Koha {
    Show-Title "ÉTAT DES CONTENEURS DOCKER"
    Write-Message "Vérification de l'état des conteneurs..." "INFO"
    Write-Host ""
    docker-compose ps
    Write-Host ""
}

function Clean-Koha {
    Show-Title "NETTOYAGE DE L'ENVIRONNEMENT KOHA"
    Write-Message "Arrêt et suppression des conteneurs, réseaux et volumes Docker..." "WARNING"
    docker-compose down -v
    if ($LASTEXITCODE -eq 0) {
        Write-Message "Environnement nettoyé avec succès !" "SUCCESS"
    } else {
        Write-Message "Erreur lors du nettoyage." "ERROR"
    }
}

function Reinstall-Koha {
    Show-Title "RÉINSTALLATION COMPLÈTE DE KOHA"
    Write-Message "Suppression complète de l'environnement Koha..." "WARNING"
    
    docker-compose down -v
    if (Test-Path -Path "cpanfile.snapshot") { 
        Remove-Item "cpanfile.snapshot" -Force 
        Write-Message "Fichier cpanfile.snapshot supprimé" "INFO"
    }
    if (Test-Path -Path "local\lib") { 
        Remove-Item "local\lib" -Recurse -Force 
        Write-Message "Dossier local/lib supprimé" "INFO"
    }
    
    Write-Message "Reconstruction complète de l'image Docker Koha..." "INFO"
    docker-compose build --no-cache
    
    if ($LASTEXITCODE -eq 0) {
        Write-Message "Image reconstruite avec succès !" "SUCCESS"
        Start-Koha
    } else {
        Write-Message "Erreur lors de la reconstruction de l'image." "ERROR"
    }
}

function Quick-Rebuild {
    Show-Title "RECONSTRUCTION RAPIDE DE KOHA"
    Write-Message "Reconstruction rapide (utilise le cache Docker)..." "INFO"
    
    docker-compose down
    Write-Message "Reconstruction de l'image avec cache..." "INFO"
    docker-compose build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Message "Image reconstruite rapidement !" "SUCCESS"
        Start-Koha
    } else {
        Write-Message "Erreur lors de la reconstruction rapide." "ERROR"
    }
}

function Show-Menu {
    Clear-Host
    
    # En-tête stylisé
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║" -ForegroundColor Blue -NoNewline
    Write-Host "                          🐧 GESTIONNAIRE KOHA DOCKER 🐧                        " -ForegroundColor White -NoNewline
    Write-Host "║" -ForegroundColor Blue
    Write-Host "╠══════════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Blue
    Write-Host "║" -ForegroundColor Blue -NoNewline
    Write-Host " Menu interactif pour gérer votre environnement Koha facilement              " -ForegroundColor Gray -NoNewline
    Write-Host "║" -ForegroundColor Blue
    Write-Host "╚═══════════════════════════════════════���══════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
    
    # Options du menu avec icônes
    Write-Host "  🚀 " -NoNewline -ForegroundColor Green
    Write-Host "1. Démarrer Koha " -NoNewline -ForegroundColor White
    Write-Host "(installation automatique de tous les composants)" -ForegroundColor Gray
    
    Write-Host "  🛑 " -NoNewline -ForegroundColor Red
    Write-Host "2. Arrêter Koha" -ForegroundColor White
    
    Write-Host "  📋 " -NoNewline -ForegroundColor Yellow
    Write-Host "3. Voir les logs de l'app" -ForegroundColor White
    
    Write-Host "  📊 " -NoNewline -ForegroundColor Cyan
    Write-Host "4. Vérifier l'état des conteneurs" -ForegroundColor White
    
    Write-Host "  🧹 " -NoNewline -ForegroundColor Magenta
    Write-Host "5. Nettoyer " -NoNewline -ForegroundColor White
    Write-Host "(stop + suppression des conteneurs/volumes)" -ForegroundColor Gray
    
    Write-Host "  🔄 " -NoNewline -ForegroundColor DarkYellow
    Write-Host "6. Réinstaller Koha from scratch " -NoNewline -ForegroundColor White
    Write-Host "(purge + rebuild complet)" -ForegroundColor Gray
    
    Write-Host "  👋 " -NoNewline -ForegroundColor DarkRed
    Write-Host "7. Quitter" -ForegroundColor White
    
    Write-Host ""
    Write-Host "┌─────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "│" -ForegroundColor DarkGray -NoNewline
    Write-Host " 💡 Ce menu permet aux stagiaires de démarrer Koha sans connaissance technique" -ForegroundColor Yellow -NoNewline
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "│" -ForegroundColor DarkGray -NoNewline
    Write-Host " 🔧 Toutes les dépendances et la base de données sont gérées automatiquement " -ForegroundColor Yellow -NoNewline
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "│" -ForegroundColor DarkGray -NoNewline
    Write-Host " 🆕 L'option 6 permet de repartir d'une installation totalement propre      " -ForegroundColor Yellow -NoNewline
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
}

# Boucle principale du menu
while ($true) {
    Show-Menu
    Write-Host "🎯 " -NoNewline -ForegroundColor Green
    $choice = Read-Host "Choisissez une option (1-7)"
    
    switch ($choice) {
        "1" { Start-Koha }
        "2" { Stop-Koha }
        "3" { Logs-Koha }
        "4" { Status-Koha }
        "5" { Clean-Koha }
        "6" { Reinstall-Koha }
        "7" { 
            Write-Host ""
            Write-Message "Au revoir ! Merci d'avoir utilisé le gestionnaire Koha Docker 👋" "SUCCESS"
            Write-Host ""
            break 
        }
        default { 
            Write-Message "Option invalide. Veuillez choisir entre 1 et 7." "ERROR"
            Start-Sleep -Seconds 2
        }
    }
    
    if ($choice -ne "7") {
        Write-Host ""
        Write-Host "Appuyez sur Entrée pour continuer..." -ForegroundColor DarkGray
        Read-Host
    }
}