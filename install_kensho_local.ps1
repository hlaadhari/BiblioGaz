# Script pour installer Task::Kensho localement et récupérer toutes les dépendances
# Usage : .\install_kensho_local.ps1

# Configuration de l'encodage UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Fonction pour afficher des messages colorés
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
    }
}

Write-Host ""
Write-Host "╔══��═══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║" -ForegroundColor Blue -NoNewline
Write-Host "              🎯 INSTALLATION TASK::KENSHO AVEC DÉPENDANCES 🎯               " -ForegroundColor White -NoNewline
Write-Host "║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# Vérifier si Perl est installé
try {
    $perlVersion = perl -v 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Message "Perl détecté sur le système" "SUCCESS"
    } else {
        Write-Message "Perl n'est pas installé. Installation via Docker recommandée." "WARNING"
        Write-Host ""
        Write-Message "Utilisez plutôt le Dockerfile.kensho avec l'option 9 → 5" "INFO"
        return
    }
}
catch {
    Write-Message "Perl n'est pas accessible. Installation via Docker recommandée." "WARNING"
    Write-Host ""
    Write-Message "Utilisez plutôt le Dockerfile.kensho avec l'option 9 → 5" "INFO"
    return
}

# Créer un dossier temporaire pour l'installation
$tempDir = "temp_perl_install"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Message "Installation de Task::Kensho avec toutes ses dépendances..." "INFO"
Write-Message "Cela peut prendre 10-20 minutes selon votre connexion..." "WARNING"
Write-Host ""

# Commandes Perl pour installer Task::Kensho
$perlCommands = @"
use strict;
use warnings;

# Configuration de cpanm
system('cpanm --version') == 0 or die "cpanm not found. Please install App::cpanminus first.\n";

print "=== Installation de Task::Kensho ===\n";
my \$result = system('cpanm --notest --force Task::Kensho');

if (\$result == 0) {
    print "=== Task::Kensho installé avec succès ===\n";
    
    # Installer les modules spécifiques à Koha
    my @koha_modules = qw(
        CGI::Compile
        CGI::Emulate::PSGI
        Template
        Plack::Middleware::ReverseProxy
        Plack::Middleware::LogWarn
        Email::Sender
        PDF::API2
        Starman
        DBI
        DBD::mysql
    );
    
    print "=== Installation des modules Koha ===\n";
    foreach my \$module (@koha_modules) {
        print "Installation de \$module...\n";
        system("cpanm --notest --force \$module");
    }
    
    print "=== Installation terminée ===\n";
} else {
    print "=== Erreur lors de l'installation de Task::Kensho ===\n";
    exit 1;
}
"@

# Sauvegarder le script Perl
$perlScript = Join-Path $tempDir "install_kensho.pl"
$perlCommands | Out-File -FilePath $perlScript -Encoding UTF8

try {
    Write-Message "Lancement de l'installation Perl..." "INFO"
    
    # Exécuter le script Perl
    $process = Start-Process -FilePath "perl" -ArgumentList $perlScript -WorkingDirectory $tempDir -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        Write-Message "Installation réussie !" "SUCCESS"
        
        # Essayer de copier les modules installés vers notre cache
        Write-Message "Tentative de récupération des modules installés..." "INFO"
        
        # Localiser le répertoire site/lib de Perl
        $perlLibDirs = @(
            "$env:USERPROFILE\.cpanm\work",
            "C:\Strawberry\perl\site\lib",
            "C:\Perl\site\lib"
        )
        
        foreach ($libDir in $perlLibDirs) {
            if (Test-Path $libDir) {
                Write-Message "Répertoire Perl trouvé : $libDir" "INFO"
                break
            }
        }
        
    } else {
        Write-Message "Erreur lors de l'installation (code: $($process.ExitCode))" "ERROR"
    }
}
catch {
    Write-Message "Erreur lors de l'exécution : $($_.Exception.Message)" "ERROR"
}
finally {
    # Nettoyer
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
}

Write-Host ""
Write-Host "┌─────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Blue
Write-Host "│" -ForegroundColor Blue -NoNewline
Write-Host " 💡 RECOMMANDATION".PadRight(75) -ForegroundColor White -NoNewline
Write-Host "│" -ForegroundColor Blue
Write-Host "│" -ForegroundColor Blue -NoNewline
Write-Host " Pour une installation plus fiable, utilisez le Dockerfile.kensho :".PadRight(75) -ForegroundColor Yellow -NoNewline
Write-Host "│" -ForegroundColor Blue
Write-Host "│" -ForegroundColor Blue -NoNewline
Write-Host " 1. Option 9 → Changer de Dockerfile".PadRight(75) -ForegroundColor Cyan -NoNewline
Write-Host "│" -ForegroundColor Blue
Write-Host "│" -ForegroundColor Blue -NoNewline
Write-Host " 2. Choisir 5 (Dockerfile.kensho)".PadRight(75) -ForegroundColor Cyan -NoNewline
Write-Host "│" -ForegroundColor Blue
Write-Host "│" -ForegroundColor Blue -NoNewline
Write-Host " 3. Option 6 → Réinstaller from scratch".PadRight(75) -ForegroundColor Cyan -NoNewline
Write-Host "│" -ForegroundColor Blue
Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Blue
Write-Host ""