# Script pour télécharger les modules CPAN localement
# Usage : .\download_cpan_modules.ps1

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

# Liste des modules CPAN essentiels avec leurs URLs
$modules = @{
    "DBI" = "https://cpan.metacpan.org/authors/id/H/HM/HMBRAND/DBI-1.647.tgz"
    "Try-Tiny" = "https://cpan.metacpan.org/authors/id/E/ET/ETHER/Try-Tiny-0.32.tar.gz"
    "JSON" = "https://cpan.metacpan.org/authors/id/I/IS/ISHIGAKI/JSON-4.10.tar.gz"
    "Modern-Perl" = "https://cpan.metacpan.org/authors/id/C/CH/CHROMATIC/Modern-Perl-1.20250607.tar.gz"
    "Plack" = "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/Plack-1.0051.tar.gz"
    "Starman" = "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/Starman-0.4017.tar.gz"
    "Template-Toolkit" = "https://cpan.metacpan.org/authors/id/A/AB/ABW/Template-Toolkit-3.101.tar.gz"
    "XML-LibXML" = "https://cpan.metacpan.org/authors/id/S/SH/SHLOMIF/XML-LibXML-2.0210.tar.gz"
    "DateTime" = "https://cpan.metacpan.org/authors/id/D/DR/DROLSKY/DateTime-1.66.tar.gz"
    "List-MoreUtils" = "https://cpan.metacpan.org/authors/id/R/RE/REHSACK/List-MoreUtils-0.430.tar.gz"
    "YAML-XS" = "https://cpan.metacpan.org/authors/id/T/TI/TINITA/YAML-LibYAML-v0.904.0.tar.gz"
    "CGI-Emulate-PSGI" = "https://cpan.metacpan.org/authors/id/T/TO/TOKUHIROM/CGI-Emulate-PSGI-0.23.tar.gz"
    "CGI-Compile" = "https://cpan.metacpan.org/authors/id/M/MI/MIYAGAWA/CGI-Compile-0.25.tar.gz"
}

Write-Host ""
Write-Host "╔═════════════════���════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║" -ForegroundColor Blue -NoNewline
Write-Host "                    📦 TÉLÉCHARGEMENT MODULES CPAN 📦                         " -ForegroundColor White -NoNewline
Write-Host "║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# Créer le dossier de cache s'il n'existe pas
$cacheDir = "cpan_cache"
if (-not (Test-Path $cacheDir)) {
    New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    Write-Message "Dossier de cache créé : $cacheDir" "SUCCESS"
}

Write-Message "Téléchargement de $($modules.Count) modules CPAN..." "INFO"
Write-Host ""

$downloaded = 0
$failed = 0

foreach ($module in $modules.GetEnumerator()) {
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
}

# Afficher la taille du cache
$cacheSize = (Get-ChildItem $cacheDir -Recurse | Measure-Object -Property Length -Sum).Sum
$cacheSizeMB = [math]::Round($cacheSize / 1MB, 2)
Write-Message "Taille du cache : $cacheSizeMB MB" "INFO"

Write-Host ""
Write-Host "┌───────────────────────────────────────────────��─────────────────────────────┐" -ForegroundColor Green
Write-Host "│" -ForegroundColor Green -NoNewline
Write-Host " 🎉 Cache CPAN prêt !".PadRight(75) -ForegroundColor White -NoNewline
Write-Host "│" -ForegroundColor Green
Write-Host "│" -ForegroundColor Green -NoNewline
Write-Host " 📁 Dossier : $cacheDir".PadRight(75) -ForegroundColor Cyan -NoNewline
Write-Host "│" -ForegroundColor Green
Write-Host "│" -ForegroundColor Green -NoNewline
Write-Host " 💡 Utilisez maintenant le Dockerfile.offline pour une installation rapide".PadRight(75) -ForegroundColor Yellow -NoNewline
Write-Host "│" -ForegroundColor Green
Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host ""