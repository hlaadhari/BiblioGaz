# Script pour télécharger Task::Kensho et autres bundles CPAN
# Usage : .\download_task_bundles.ps1

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
Write-Host "╔═════════���════════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║" -ForegroundColor Blue -NoNewline
Write-Host "                📦 TÉLÉCHARGEMENT TASK BUNDLES CPAN 📦                       " -ForegroundColor White -NoNewline
Write-Host "║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

$cacheDir = "cpan_cache"
if (-not (Test-Path $cacheDir)) {
    New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    Write-Message "Dossier de cache créé : $cacheDir" "SUCCESS"
}

# Bundles et modules utiles avec plusieurs versions
$modules = @{
    "Task-Kensho" = @(
        "https://cpan.metacpan.org/authors/id/E/ET/ETHER/Task-Kensho-0.41.tar.gz",
        "https://cpan.metacpan.org/authors/id/E/ET/ETHER/Task-Kensho-0.40.tar.gz"
    )
    "Bundle-CPAN" = @(
        "https://cpan.metacpan.org/authors/id/A/AN/ANDK/Bundle-CPAN-1.861.tar.gz"
    )
    "CGI-Compile" = @(
        "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Compile-0.26.tar.gz",
        "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Compile-0.25.tar.gz"
    )
    "Template-Toolkit" = @(
        "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-3.102.tar.gz",
        "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-3.101.tar.gz",
        "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-3.100.tar.gz"
    )
    "Plack-Middleware-ReverseProxy" = @(
        "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/Plack-Middleware-ReverseProxy-0.16.tar.gz"
    )
    "Plack-Middleware-LogWarn" = @(
        "https://cpan.metacpan.org/authors/id/A/AP/APOCAL/Plack-Middleware-LogWarn-0.001002.tar.gz"
    )
    "Email-Sender" = @(
        "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/Email-Sender-2.601.tar.gz"
    )
    "PDF-API2" = @(
        "https://cpan.metacpan.org/authors/id/S/SS/SSIMMS/PDF-API2-2.047.tar.gz"
    )
}

$downloaded = 0
$failed = 0
$totalModules = $modules.Count

Write-Message "Téléchargement de $totalModules bundles/modules..." "INFO"
Write-Host ""

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
            $fileSize = (Get-Item $filePath).Length
            if ($fileSize -gt 1000) {  # Au moins 1KB
                Write-Host " [DÉJÀ PRÉSENT: $fileName]" -ForegroundColor Yellow
                $success = $true
                break
            } else {
                Remove-Item $filePath -Force
            }
        }
        
        try {
            Write-Host " [Essai: $fileName]" -ForegroundColor Cyan -NoNewline
            
            # Utiliser Invoke-WebRequest avec gestion d'erreur
            $response = Invoke-WebRequest -Uri $url -OutFile $filePath -UseBasicParsing -TimeoutSec 60 -PassThru
            
            if (Test-Path $filePath) {
                $fileSize = (Get-Item $filePath).Length
                if ($fileSize -gt 1000) {  # Au moins 1KB
                    $sizeMB = [math]::Round($fileSize / 1MB, 2)
                    Write-Host " [OK - $sizeMB MB]" -ForegroundColor Green
                    $downloaded++
                    $success = $true
                    break
                } else {
                    Write-Host " [TROP PETIT]" -ForegroundColor Red -NoNewline
                    Remove-Item $filePath -Force
                }
            }
        }
        catch {
            Write-Host " [ÉCHEC: $($_.Exception.Message.Split('.')[0])]" -ForegroundColor Red -NoNewline
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
Write-Message "Modules échoués : $failed" "WARNING"

# Afficher la taille du cache
$cacheSize = (Get-ChildItem $cacheDir -Recurse | Measure-Object -Property Length -Sum).Sum
$cacheSizeMB = [math]::Round($cacheSize / 1MB, 2)
Write-Message "Taille totale du cache : $cacheSizeMB MB" "INFO"

# Lister les fichiers dans le cache
Write-Host ""
Write-Message "Contenu du cache :" "INFO"
Get-ChildItem $cacheDir | Sort-Object Name | ForEach-Object {
    $sizeMB = [math]::Round($_.Length / 1MB, 2)
    Write-Host "  📦 " -NoNewline -ForegroundColor Blue
    Write-Host "$($_.Name) " -NoNewline -ForegroundColor White
    Write-Host "($sizeMB MB)" -ForegroundColor Gray
}

$totalFiles = (Get-ChildItem $cacheDir).Count

Write-Host ""
if ($totalFiles -ge 15) {
    Write-Host "┌─────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
    Write-Host "│" -ForegroundColor Green -NoNewline
    Write-Host " 🎉 Cache CPAN excellent ! ($totalFiles modules)".PadRight(75) -ForegroundColor White -NoNewline
    Write-Host "│" -ForegroundColor Green
    Write-Host "│" -ForegroundColor Green -NoNewline
    Write-Host " 📁 Dossier : $cacheDir ($cacheSizeMB MB)".PadRight(75) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor Green
    Write-Host "│" -ForegroundColor Green -NoNewline
    Write-Host " 💡 Utilisez l'option 9 → 4 pour le mode offline ultra-rapide".PadRight(75) -ForegroundColor Yellow -NoNewline
    Write-Host "│" -ForegroundColor Green
    Write-Host "│" -ForegroundColor Green -NoNewline
    Write-Host " 🚀 Installation prévue : 30 secondes - 1 minute".PadRight(75) -ForegroundColor Magenta -NoNewline
    Write-Host "│" -ForegroundColor Green
    Write-Host "└─��───────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
} elseif ($totalFiles -ge 10) {
    Write-Host "┌─────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
    Write-Host "│" -ForegroundColor Yellow -NoNewline
    Write-Host " ⚡ Cache CPAN bon ! ($totalFiles modules)".PadRight(75) -ForegroundColor White -NoNewline
    Write-Host "│" -ForegroundColor Yellow
    Write-Host "│" -ForegroundColor Yellow -NoNewline
    Write-Host " 📁 Dossier : $cacheDir ($cacheSizeMB MB)".PadRight(75) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor Yellow
    Write-Host "│" -ForegroundColor Yellow -NoNewline
    Write-Host " 💡 Le mode offline fonctionnera bien".PadRight(75) -ForegroundColor White -NoNewline
    Write-Host "│" -ForegroundColor Yellow
    Write-Host "│" -ForegroundColor Yellow -NoNewline
    Write-Host " 🚀 Installation prévue : 1-3 minutes".PadRight(75) -ForegroundColor Magenta -NoNewline
    Write-Host "│" -ForegroundColor Yellow
    Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
} else {
    Write-Host "┌─────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Red
    Write-Host "│" -ForegroundColor Red -NoNewline
    Write-Host " ⚠️  Cache CPAN partiel ($totalFiles modules)".PadRight(75) -ForegroundColor White -NoNewline
    Write-Host "│" -ForegroundColor Red
    Write-Host "│" -ForegroundColor Red -NoNewline
    Write-Host " 📁 Dossier : $cacheDir ($cacheSizeMB MB)".PadRight(75) -ForegroundColor Cyan -NoNewline
    Write-Host "│" -ForegroundColor Red
    Write-Host "│" -ForegroundColor Red -NoNewline
    Write-Host " 💡 Utilisez le mode minimal ou normal".PadRight(75) -ForegroundColor White -NoNewline
    Write-Host "│" -ForegroundColor Red
    Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Red
}
Write-Host ""