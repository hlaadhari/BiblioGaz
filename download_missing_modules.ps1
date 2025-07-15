# Script pour télécharger les modules CPAN manquants
# Usage : .\download_missing_modules.ps1

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

# URLs alternatives pour les modules manquants
$missingModules = @{
    "Template-Toolkit-3.100" = "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-3.100.tar.gz"
    "Template-Toolkit-3.009" = "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-3.009.tar.gz"
    "CGI-Compile-0.24" = "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Compile-0.24.tar.gz"
    "CGI-Compile-0.23" = "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Compile-0.23.tar.gz"
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║" -ForegroundColor Blue -NoNewline
Write-Host "                📦 TÉLÉCHARGEMENT MODULES MANQUANTS 📦                       " -ForegroundColor White -NoNewline
Write-Host "║" -ForegroundColor Blue
Write-Host "╚═════════════════════════════════════════════════════════════════════════���════╝" -ForegroundColor Blue
Write-Host ""

$cacheDir = "cpan_cache"
if (-not (Test-Path $cacheDir)) {
    New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    Write-Message "Dossier de cache créé : $cacheDir" "SUCCESS"
}

Write-Message "Tentative de téléchargement des modules manquants..." "INFO"
Write-Host ""

$downloaded = 0
$failed = 0

foreach ($module in $missingModules.GetEnumerator()) {
    $moduleName = $module.Key
    $moduleUrl = $module.Value
    $fileName = Split-Path $moduleUrl -Leaf
    $filePath = Join-Path $cacheDir $fileName
    
    Write-Host "📦 " -NoNewline -ForegroundColor Blue
    Write-Host "Téléchargement de $moduleName..." -NoNewline -ForegroundColor White
    
    try {
        if (Test-Path $filePath) {
            Write-Host " [DÉJÀ PRÉSENT]" -ForegroundColor Yellow
        } else {
            Invoke-WebRequest -Uri $moduleUrl -OutFile $filePath -UseBasicParsing
            if (Test-Path $filePath) {
                Write-Host " [OK]" -ForegroundColor Green
                $downloaded++
            } else {
                Write-Host " [ÉCHEC]" -ForegroundColor Red
                $failed++
            }
        }
    }
    catch {
        Write-Host " [ERREUR: $($_.Exception.Message)]" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Message "Téléchargement terminé !" "SUCCESS"
Write-Message "Modules téléchargés : $downloaded" "INFO"
if ($failed -gt 0) {
    Write-Message "Modules échoués : $failed" "WARNING"
    Write-Message "Les modules manquants seront installés depuis CPAN lors du build Docker" "INFO"
}

# Afficher la taille du cache
$cacheSize = (Get-ChildItem $cacheDir -Recurse | Measure-Object -Property Length -Sum).Sum
$cacheSizeMB = [math]::Round($cacheSize / 1MB, 2)
Write-Message "Taille totale du cache : $cacheSizeMB MB" "INFO"

Write-Host ""
Write-Host "┌─────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "│" -ForegroundColor Green -NoNewline
Write-Host " 🎉 Cache CPAN mis à jour !".PadRight(75) -ForegroundColor White -NoNewline
Write-Host "│" -ForegroundColor Green
Write-Host "│" -ForegroundColor Green -NoNewline
Write-Host " 📁 Dossier : $cacheDir".PadRight(75) -ForegroundColor Cyan -NoNewline
Write-Host "│" -ForegroundColor Green
Write-Host "│" -ForegroundColor Green -NoNewline
Write-Host " 💡 Le Dockerfile.offline est maintenant prêt à être utilisé".PadRight(75) -ForegroundColor Yellow -NoNewline
Write-Host "│" -ForegroundColor Green
Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host ""