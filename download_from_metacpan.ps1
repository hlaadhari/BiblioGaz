# Script pour télécharger les modules depuis MetaCPAN
# Usage : .\download_from_metacpan.ps1

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
Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║" -ForegroundColor Blue -NoNewline
Write-Host "                📦 TÉLÉCHARGEMENT DEPUIS METACPAN 📦                         " -ForegroundColor White -NoNewline
Write-Host "║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

$cacheDir = "cpan_cache"
if (-not (Test-Path $cacheDir)) {
    New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    Write-Message "Dossier de cache créé : $cacheDir" "SUCCESS"
}

# URLs directes basées sur les dernières versions disponibles sur MetaCPAN
$modules = @{
    "CGI-Compile" = @(
        "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Compile-0.26.tar.gz",
        "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Compile-0.25.tar.gz",
        "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Compile-0.24.tar.gz",
        "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Compile-0.23.tar.gz"
    )
    "Template-Toolkit" = @(
        "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-3.102.tar.gz",
        "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-3.101.tar.gz",
        "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-3.100.tar.gz",
        "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-3.010.tar.gz",
        "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-3.009.tar.gz"
    )
}

$downloaded = 0
$failed = 0

foreach ($module in $modules.GetEnumerator()) {
    $moduleName = $module.Key
    $urls = $module.Value
    
    Write-Host "📦 " -NoNewline -ForegroundColor Blue
    Write-Host "Téléchargement de $moduleName..." -NoNewline -ForegroundColor White
    
    $success = $false
    
    foreach ($url in $urls) {
        $fileName = Split-Path $url -Leaf
        $filePath = Join-Path $cacheDir $fileName
        
        # Vérifier si le fichier existe déjà
        if (Test-Path $filePath) {
            Write-Host " [DÉJÀ PRÉSENT: $fileName]" -ForegroundColor Yellow
            $success = $true
            break
        }
        
        try {
            Write-Host " [Essai: $fileName]" -ForegroundColor Cyan -NoNewline
            
            # Télécharger avec timeout
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($url, $filePath)
            
            if (Test-Path $filePath -and (Get-Item $filePath).Length -gt 0) {
                Write-Host " [OK]" -ForegroundColor Green
                $downloaded++
                $success = $true
                break
            } else {
                Write-Host " [VIDE]" -ForegroundColor Red -NoNewline
                if (Test-Path $filePath) {
                    Remove-Item $filePath -Force
                }
            }
        }
        catch {
            Write-Host " [ÉCHEC]" -ForegroundColor Red -NoNewline
            if (Test-Path $filePath) {
                Remove-Item $filePath -Force
            }
        }
    }
    
    if (-not $success) {
        Write-Host " [TOUS LES LIENS ÉCHOUÉS]" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Message "Téléchargement terminé !" "SUCCESS"
Write-Message "Modules téléchargés : $downloaded" "INFO"
if ($failed -gt 0) {
    Write-Message "Modules échoués : $failed" "WARNING"
}

# Afficher la taille du cache
$cacheSize = (Get-ChildItem $cacheDir -Recurse | Measure-Object -Property Length -Sum).Sum
$cacheSizeMB = [math]::Round($cacheSize / 1MB, 2)
Write-Message "Taille totale du cache : $cacheSizeMB MB" "INFO"

# Lister les fichiers dans le cache
Write-Host ""
Write-Message "Contenu du cache :" "INFO"
Get-ChildItem $cacheDir | ForEach-Object {
    $sizeMB = [math]::Round($_.Length / 1MB, 2)
    Write-Host "  📦 " -NoNewline -ForegroundColor Blue
    Write-Host "$($_.Name) " -NoNewline -ForegroundColor White
    Write-Host "($sizeMB MB)" -ForegroundColor Gray
}

Write-Host ""
if ($downloaded -gt 0 -or (Get-ChildItem $cacheDir).Count -gt 10) {
    Write-Host "┌─────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
    Write-Host "│" -ForegroundColor Green -NoNewline
    Write-Host " 🎉 Cache CPAN complet !".PadRight(75) -ForegroundColor White -NoNewline
    Write-Host "│" -ForegroundColor Green
    Write-Host "│" -ForegroundColor Green -NoNewline
    Write-Host " 📁 Dossier : $cacheDir".PadRight(75) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor Green
    Write-Host "│" -ForegroundColor Green -NoNewline
    Write-Host " 💡 Utilisez maintenant l'option 9 → 4 pour le mode offline".PadRight(75) -ForegroundColor Yellow -NoNewline
    Write-Host "│" -ForegroundColor Green
    Write-Host "│" -ForegroundColor Green -NoNewline
    Write-Host " 🚀 Installation prévue : 30 secondes - 2 minutes".PadRight(75) -ForegroundColor Magenta -NoNewline
    Write-Host "│" -ForegroundColor Green
    Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
} else {
    Write-Host "┌─────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
    Write-Host "│" -ForegroundColor Yellow -NoNewline
    Write-Host " ⚠️  Cache partiel".PadRight(75) -ForegroundColor White -NoNewline
    Write-Host "│" -ForegroundColor Yellow
    Write-Host "│" -ForegroundColor Yellow -NoNewline
    Write-Host " 📁 Dossier : $cacheDir".PadRight(75) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor Yellow
    Write-Host "│" -ForegroundColor Yellow -NoNewline
    Write-Host " 💡 Le mode offline fonctionnera quand même avec les modules disponibles".PadRight(75) -ForegroundColor White -NoNewline
    Write-Host "│" -ForegroundColor Yellow
    Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
}
Write-Host ""