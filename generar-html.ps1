# generar-html.ps1
# Convierte cheatsheet.md y tarea.md de cada clase a HTML en su carpeta plataforma/
# Requiere: Node.js instalado y haber ejecutado "npm install" en la raiz del repo
# Uso: .\generar-html.ps1 -Clase clase-01
#      .\generar-html.ps1 -Clase clase-01,clase-02
#      .\generar-html.ps1 -Todas

param(
    [string[]]$Clase = @(),
    [switch]$Todas
)

$base = Join-Path $PSScriptRoot 'clases'
$conversor = Join-Path $PSScriptRoot 'convertir.js'

# Verificar que node este disponible
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js no esta instalado o no esta en el PATH."
    exit 1
}

# Verificar que las dependencias esten instaladas
if (-not (Test-Path (Join-Path $PSScriptRoot 'node_modules'))) {
    Write-Host "Instalando dependencias (npm install)..." -ForegroundColor Yellow
    Push-Location $PSScriptRoot
    npm install
    Pop-Location
}

# Determinar que clases procesar
$cantidadOpciones = 0
if ($Clase.Count -gt 0) {
    $cantidadOpciones++
}
if ($Todas) {
    $cantidadOpciones++
}

if ($cantidadOpciones -ne 1) {
    Write-Error "Debes indicar exactamente una opcion: -Clase clase-01[,clase-02] o -Todas."
    exit 1
}

$carpetas = Get-ChildItem -Path $base -Directory | Sort-Object Name
if (-not $Todas) {
    $carpetas = $carpetas | Where-Object { $Clase -contains $_.Name }
    if ($carpetas.Count -eq 0) {
        Write-Error "No se encontraron las clases especificadas: $($Clase -join ', ')"
        exit 1
    }
}

$archivosAConvertir = @('cheatsheet', 'tarea')
$total = 0
$errores = 0

foreach ($carpeta in $carpetas) {
    $destino = Join-Path $carpeta.FullName 'plataforma'

    foreach ($archivo in $archivosAConvertir) {
        $origen = Join-Path $carpeta.FullName "$archivo.md"
        $html   = Join-Path $destino "$archivo.html"

        if (-not (Test-Path $origen)) {
            Write-Warning "[$($carpeta.Name)] $archivo.md no existe, se omite."
            continue
        }

        try {
            node $conversor $origen $html "$($carpeta.Name) - $archivo"
            Write-Host "OK  $($carpeta.Name)/plataforma/$archivo.html" -ForegroundColor Green
            $total++
        } catch {
            Write-Host "ERR $($carpeta.Name)/plataforma/$archivo.html - $_" -ForegroundColor Red
            $errores++
        }
    }
}

Write-Host ""
Write-Host "Generados: $total archivo(s). Errores: $errores." -ForegroundColor Cyan
