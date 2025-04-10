$OhMyPosh = "JanDeDobbeleer.OhMyPosh"
$PShell = "Microsoft.PowerShell"
$Terminal = "Microsoft.WindowsTerminal"

# Aceptar términos automáticamente para winget
$env:ACCEPT_WINGET_INSTALLER_PROMPTS = "yes"

function WaitWingetIfRunning {
    $wingetProcess = Get-Process -Name "winget" -ErrorAction SilentlyContinue
    if ($wingetProcess) {
        Write-Host "Esperando a que finalice una instalación previa de winget..."
        Start-Sleep -Seconds 5
    }
}

# -------------------------------
# Instalar Windows Terminal
# -------------------------------
if (!(Test-Path -Path "C:\Program Files\WindowsApps\Microsoft.WindowsTerminal*")) {
    Write-Host "Windows Terminal no está instalado. Instalando..."
    winget update -y
    winget install --id Microsoft.WindowsTerminal -e --accept-package-agreements --accept-source-agreements
    WaitWingetIfRunning

    if (winget list | Select-String $Terminal) {
        Write-Host "Windows Terminal se ha instalado correctamente."
    } else {
        Write-Host "❌ No se pudo instalar Windows Terminal. Revisa la configuración de 'winget' y permisos."
    }
}

# -------------------------------
# Instalar PowerShell (si no está)
# -------------------------------
if (!(winget list | Select-String $PShell)) {
    Write-Host "PowerShell no está instalado. Instalando..."
    winget update
    winget install --id Microsoft.PowerShell -e --accept-package-agreements --accept-source-agreements
    WaitWingetIfRunning

    if (winget list | Select-String $PShell) {
        Write-Host "PowerShell se ha instalado correctamente."
    } else {
        Write-Host "❌ No se pudo instalar PowerShell. Revisa la configuración de 'winget' y permisos."
    }
}

# -------------------------------
# Instalar Oh My Posh
# -------------------------------
if (!(winget list | Select-String $OhMyPosh)) {
    Write-Host "Oh My Posh no está instalado. Instalando..."
    winget update
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-package-agreements --accept-source-agreements
    WaitWingetIfRunning

    if (winget list | Select-String $OhMyPosh) {
        Write-Host "Oh My Posh se ha instalado correctamente."
    } else {
        Write-Host "❌ No se pudo instalar Oh My Posh. Revisa la configuración de 'winget' y permisos."
        Exit
    }
} else {
    Write-Host "Oh My Posh ya está instalado."
}

# -------------------------------
# Instalar módulo Terminal-Icons
# -------------------------------
if (!(Get-Module -Name "Terminal-Icons" -ListAvailable)) {
    Write-Host "Terminal-Icons no está instalado. Instalando desde PSGallery..."
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser
} else {
    Write-Host "Terminal-Icons ya está instalado."
}

# -------------------------------
# Instalar winfetch
# -------------------------------
try {
    Install-Script winfetch -Force -Scope CurrentUser -ErrorAction Stop
} catch {
    Write-Host "⚠️ No se pudo instalar winfetch. Puedes instalarlo manualmente con 'Install-Script winfetch'."
}

# -------------------------------
# Aplicar configuración del perfil
# -------------------------------
function ScriptConf {
    param (
        [string]$ConfNameFileLoc,
        [string]$Content
    )

    Set-Content -Path $ConfNameFileLoc -Value $Content -Force
    Write-Host "✔️ Perfil actualizado en: $ConfNameFileLoc"
}

$ConfNameFileLoc = "$PROFILE"
$Content = @"
oh-my-posh init pwsh --config `'$env:POSH_THEMES_PATH\clean-detailed.omp.json`' | Invoke-Expression
Import-Module -Name Terminal-Icons
winfetch

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
"@

ScriptConf -ConfNameFileLoc $ConfNameFileLoc -Content $Content

# -------------------------------
# Reiniciar terminal con nueva configuración
# -------------------------------
Write-Host "Reiniciando Windows Terminal con nueva configuración..."
Start-Process -FilePath "wt" -ArgumentList "pwsh.exe -NoExit -Command Get-PoshThemes"

Exit
