# Script pour rechercher et télécharger les modules CPAN manquants
# Usage : .\find_and_download_modules.ps1

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

# Fonction pour rechercher un module sur MetaCPAN
function Find-ModuleUrl {
    param([string]$ModuleName)
    
    try {
        $searchUrl = "https://fastapi.metacpan.org/v1/release/$ModuleName"
        $response = Invoke-RestMethod -Uri $searchUrl -UseBasicParsing
        if ($response.download_url) {
            return $response.download_url
        }
    }
    catch {
        Write-Host " [Recherche API échouée]" -ForegroundColor Yellow -NoNewline
    }
    
    # URLs de fallback connues
    $fallbackUrls = @{
        "Template-Toolkit" = @(
            "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-3.010.tar.gz",
            "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-2.29.tar.gz"
        )
        "CGI-Compile" = @(
            "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Compile-0.22.tar.gz",
            "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Compile-0.21.tar.gz"
        )
    }
    
    if ($fallbackUrls.ContainsKey($ModuleName)) {
        return $fallbackUrls[$ModuleName]
    }
    
    return $null
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║" -ForegroundColor Blue -NoNewline
Write-Host "              🔍 RECHERCHE ET TÉLÉCHARGEMENT MODULES MANQUANTS 🔍             " -ForegroundColor White -NoNewline
Write-Host "║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

$cacheDir = "cpan_cache"
if (-not (Test-Path $cacheDir)) {
    New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    Write-Message "Dossier de cache créé : $cacheDir" "SUCCESS"
}

$missingModules = @("Template-Toolkit", "CGI-Compile")
$downloaded = 0
$failed = 0

foreach ($moduleName in $missingModules) {
    Write-Host "🔍 " -NoNewline -ForegroundColor Blue
    Write-Host "Recherche de $moduleName..." -NoNewline -ForegroundColor White
    
    $urls = Find-ModuleUrl $moduleName
    
    if ($urls) {
        if ($urls -is [array]) {
            $urlsToTry = $urls
        } else {
            $urlsToTry = @($urls)
        }
        
        $success = $false
        foreach ($url in $urlsToTry) {
            $fileName = Split-Path $url -Leaf
            $filePath = Join-Path $cacheDir $fileName
            
            if (Test-Path $filePath) {
                Write-Host " [DÉJÀ PRÉSENT]" -ForegroundColor Yellow
                $success = $true
                break
            }
            
            try {
                Write-Host " [Tentative: $(Split-Path $url -Leaf)]" -ForegroundColor Cyan -NoNewline
                Invoke-WebRequest -Uri $url -OutFile $filePath -UseBasicParsing -TimeoutSec 30
                if (Test-Path $filePath) {
                    Write-Host " [OK]" -ForegroundColor Green
                    $downloaded++
                    $success = $true
                    break
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
    } else {
        Write-Host " [AUCUNE URL TROUVÉE]" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Message "Recherche terminée !" "SUCCESS"
Write-Message "Modules téléchargés : $downloaded" "INFO"
if ($failed -gt 0) {
    Write-Message "Modules échoués : $failed" "WARNING"
    Write-Message "Les modules manquants seront installés depuis CPAN lors du build Docker" "INFO"
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
Write-Host "┌─────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "│" -ForegroundColor Green -NoNewline
Write-Host " 🎉 Cache CPAN mis à jour !".PadRight(75) -ForegroundColor White -NoNewline
Write-Host "│" -ForegroundColor Green
Write-Host "│" -ForegroundColor Green -NoNewline
Write-Host " 📁 Dossier : $cacheDir".PadRight(75) -ForegroundColor Cyan -NoNewline
Write-Host "│" -ForegroundColor Green
Write-Host "│" -ForegroundColor Green -NoNewline
Write-Host " 💡 Le Dockerfile.offline est prêt à être utilisé".PadRight(75) -ForegroundColor Yellow -NoNewline
Write-Host "│" -ForegroundColor Green
Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host ""