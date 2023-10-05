$OhMyPosh = "JanDeDobbeleer.OhMyPosh"

if (winget list | Select-String $OhMyPosh) {
    Write-Host "Oh My Posh está instalado en tu sistema."
}
else {
    Write-Host "Oh My Posh no está instalado en tu sistema. Se procederá a la instalación..."
    
    Invoke-Expression -Command "winget update"

    Invoke-Expression -Command "winget install JanDeDobbeleer.OhMyPosh -s winget"

    $previousInstallationRunning = Get-Process | Where-Object { $_.ProcessName -eq "winget" }

    if ($previousInstallationRunning) {
        Write-Host "Esperando a que la instalación previa termine..."
        $previousInstallationRunning.WaitForExit()
    }

    # Verify Installation
    $sucessInstallation = (winget list | Select-String $OhMyPosh)

    if ($sucessInstallation) {
        Write-Host "Oh My Posh se ha instalado correctamente."
        # Restart PowerShell and continue execution
        Write-Host "Restarting PowerShell and continuing script execution..."
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File $MyInvocation.ScriptName
    }
    else {
        Write-Host "No se pudo instalar Oh My Posh. Comprueba tu configuración de 'winget' y los permisos de instalación."
    }

    Invoke-Expression -Command "Get-PoshThemes"

    if (Get-Module -Name "Terminal-Icons" -ListAvailable) {
        Write-Host "Terminal-Icons ya está instalado en tu sistema."
    }
    else {
        Write-Host "Terminal-Icons no está instalado en tu sistema. Se procederá a la instalación."
        Invoke-Expression -Command "Install-Module -Name Terminal-Icons -Repository PSGallery"
    }

    Invoke-Expression -Command "Install-Script winfetch"
}

function ScriptConf {
    param(
        [string]$ConfNameFileLoc,
        [string]$Content
    )

    # Check if the file is already exist
    if (Test-Path $ConfNameFileLoc) {
        # Replace the profile
        Set-Content -Path $ConfNameFileLoc -Value $Content
        Write-Host "Se ha reemplazado el archivo: $ConfNameFileLoc"
    }
    else {
        # Create a new profile
        New-Item -ItemType File -Path $PROFILE -Force
        Set-Content -Path $ConfNameFileLoc -Value $Content
        Write-Host "Se ha creado el archivo: $ConfNameFileLoc"
    }
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
