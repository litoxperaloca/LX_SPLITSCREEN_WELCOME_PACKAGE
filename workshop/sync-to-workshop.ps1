# ---------------------------------------------------------------
#  LX_SPLITSCREEN_WELCOME_PACKAGE - sincroniza el repo con la carpeta que lee el
#  subidor de Workshop de Project Zomboid.
#  Corre esto cada vez que cambies el mod, ANTES de subir.
# ---------------------------------------------------------------
$ErrorActionPreference = 'Stop'
$ModId = 'LX_SPLITSCREEN_WELCOME_PACKAGE'
$Wsrc  = $PSScriptRoot                       # <repo>\workshop
$Repo  = Split-Path -Parent $PSScriptRoot    # <repo>
$Dst   = Join-Path $env:USERPROFILE "Zomboid\Workshop\$ModId"
$Cont  = Join-Path $Dst "Contents\mods\$ModId"

$srcTxt = Join-Path $Wsrc 'workshop.txt'
$dstTxt = Join-Path $Dst  'workshop.txt'

function Get-WorkshopId($path) {
    if (-not (Test-Path $path)) { return '' }
    foreach ($line in Get-Content -LiteralPath $path) {
        if ($line -match '^id=(.*)$') { return $Matches[1].Trim() }
    }
    return ''
}

Write-Host ''
Write-Host "  Sincronizando $ModId"
Write-Host "    desde : $Repo"
Write-Host "    hacia : $Dst"
Write-Host ''

# 1. El juego escribe el id de Steam en la carpeta de subida despues de la
#    primera publicacion. Lo traemos al repo ANTES de copiar: si lo pisaramos
#    con un id vacio, la proxima subida crearia un item NUEVO en vez de
#    actualizar el que ya existe.
$dstId = Get-WorkshopId $dstTxt
$srcId = Get-WorkshopId $srcTxt
if ($dstId -and -not $srcId) {
    $lines = Get-Content -LiteralPath $srcTxt
    $lines = $lines | ForEach-Object { if ($_ -match '^id=') { "id=$dstId" } else { $_ } }
    # sin BOM: el juego lee este archivo como texto plano
    [System.IO.File]::WriteAllLines($srcTxt, $lines, (New-Object System.Text.UTF8Encoding $false))
    Write-Host "  id de Steam recuperado del subidor y guardado en el repo: $dstId"
    Write-Host "  (acordate de commitearlo)"
    $srcId = $dstId
} elseif ($srcId -and $dstId -and $srcId -ne $dstId) {
    Write-Host "  AVISO: el repo dice id=$srcId y la carpeta de subida id=$dstId."
    Write-Host "         Gana el del repo. Si no es el que queres, corregilo antes de subir."
}
if (-not $srcId) {
    Write-Host "  Sin id todavia: la primera subida va a crear el item y asignarlo."
}

# 2. Copiar el mod a la carpeta que lee el subidor.
New-Item -ItemType Directory -Force -Path $Cont | Out-Null
foreach ($sub in @('42','common')) {
    $from = Join-Path $Repo $sub
    if (Test-Path $from) {
        robocopy $from (Join-Path $Cont $sub) /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy fallo copiando $sub (codigo $LASTEXITCODE)" }
    }
}
Copy-Item $srcTxt $dstTxt -Force
Copy-Item (Join-Path $Wsrc 'preview.png') (Join-Path $Dst 'preview.png') -Force

Write-Host ''
Write-Host '  Listo.'
Write-Host '  Ahora: Project Zomboid - menu principal - Workshop - Create/Update'
Write-Host "  y elegi $ModId."
Write-Host ''
