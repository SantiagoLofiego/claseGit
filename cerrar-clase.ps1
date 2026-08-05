# cerrar-clase.ps1
# Prepara el cierre operativo de una clase:
# - valida estructura minima
# - regenera HTML de plataforma
# - muestra checklist de cierre
#
# Uso:
#   .\cerrar-clase.ps1 -NumeroClase 1
#   .\cerrar-clase.ps1 -NumeroClase 01
#   .\cerrar-clase.ps1 -NumeroClase 1 -SinHtml

param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d{1,2}$')]
    [string]$NumeroClase,

    [switch]$SinHtml
)

$numeroNormalizado = '{0:D2}' -f [int]$NumeroClase
$claseNombre = "clase-$numeroNormalizado"
$raiz = $PSScriptRoot
$claseDir = Join-Path $raiz "clases\$claseNombre"

if (-not (Test-Path $claseDir)) {
    Write-Error "No existe la carpeta de la clase: $claseNombre"
    exit 1
}

$requeridos = @(
    'resumen.md',
    'actividad.md',
    'tarea.md',
    'cheatsheet.md',
    'plataforma'
)

$faltantes = @()
foreach ($item in $requeridos) {
    $ruta = Join-Path $claseDir $item
    if (-not (Test-Path $ruta)) {
        $faltantes += $item
    }
}

if ($faltantes.Count -gt 0) {
    Write-Error "Faltan archivos/carpeta en ${claseNombre}: $($faltantes -join ', ')"
    exit 1
}

if (-not $SinHtml) {
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Error 'Node.js no esta instalado o no esta en el PATH.'
        exit 1
    }

    $conversor = Join-Path $raiz 'convertir.js'
    if (-not (Test-Path $conversor)) {
        Write-Error 'No se encontro convertir.js en la raiz del repo.'
        exit 1
    }

    if (-not (Test-Path (Join-Path $raiz 'node_modules'))) {
        Write-Host 'Instalando dependencias (npm install)...' -ForegroundColor Yellow
        Push-Location $raiz
        npm install
        Pop-Location
    }

    $cheatsheetMd = Join-Path $claseDir 'cheatsheet.md'
    $tareaMd = Join-Path $claseDir 'tarea.md'
    $cheatsheetHtml = Join-Path $claseDir 'plataforma\cheatsheet.html'
    $tareaHtml = Join-Path $claseDir 'plataforma\tarea.html'

    node $conversor $cheatsheetMd $cheatsheetHtml "$claseNombre - cheatsheet"
    node $conversor $tareaMd $tareaHtml "$claseNombre - tarea"

    Write-Host "OK  $claseNombre/plataforma/cheatsheet.html" -ForegroundColor Green
    Write-Host "OK  $claseNombre/plataforma/tarea.html" -ForegroundColor Green
}

$programaPath = 'programa-capacitacion-springboot.md'
$instructionsPath = '.github/copilot-instructions.md'
$status = git status --porcelain
$programaTocado = $status | Where-Object { $_ -match [regex]::Escape($programaPath) }
$instructionsTocado = $status | Where-Object { $_ -match [regex]::Escape($instructionsPath) }

Write-Host ''
Write-Host "Checklist de cierre - $claseNombre" -ForegroundColor Cyan
Write-Host "[ ] Material de clase actualizado (resumen, actividad, tarea, cheatsheet)"
Write-Host "[ ] HTML de plataforma regenerado para la clase"
Write-Host "[ ] $programaPath revisado/actualizado"
Write-Host "[ ] $instructionsPath revisado/actualizado"
Write-Host "[ ] Cambios validados antes del commit"

if (-not $programaTocado) {
    Write-Host "Aviso: $programaPath no aparece modificado en este cierre." -ForegroundColor Yellow
}
if (-not $instructionsTocado) {
    Write-Host "Aviso: $instructionsPath no aparece modificado en este cierre." -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Estado actual (git status --short):' -ForegroundColor Cyan
git status --short
