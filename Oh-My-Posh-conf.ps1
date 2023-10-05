$OhMyPosh = "JanDeDobbeleer.OhMyPosh"
$PShell = "Microsoft.PowerShell"
$Terminal = "Microsoft.WindowsTerminal"

if (winget list | Select-String $Terminal) {
    Write-Host "Windows Terminal ya está instalado en tu sistema."
    # Comando para abrir una nueva ventana de Windows Terminal y ejecutar el script en ella
    $commandToRun = "wt -p `"$PSCommandPath`""

    # Ejecutar el comando para abrir la nueva ventana de Windows Terminal
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoExit -Command $commandToRun"
    # Exit the current PowerShell session
    exit
}
else {
    Write-Host "Windows Terminal no está instalado en tu sistema. Se procederá a la instalación..."
    
    Invoke-Expression -Command "winget update -y"

    Invoke-Expression -Command "winget install Microsoft.WindowsTerminal -y"

    $previousInstallationRunning = Get-Process | Where-Object { $_.ProcessName -eq "winget" }

    if ($previousInstallationRunning) {
        Write-Host "Esperando a que la instalación previa termine..."
        $previousInstallationRunning.WaitForExit()
    }

    # Verify Installation
    $sucessInstallation = (winget list | Select-String $Terminal)

    if ($sucessInstallation) {
        Write-Host "Windows Terminal se ha instalado correctamente."
        # Open a new Windows Terminal window and continue the script
        Start-Process -FilePath "wt" -ArgumentList "pwsh.exe -NoExit -File `"$PSCommandPath`""
        # Exit the current PowerShell session
        exit
    }
    else {
        Write-Host "No se pudo instalar Windows Terminal Comprueba tu configuración de 'winget' y los permisos de instalación."
    }
}

if (winget list | Select-String $PShell) {
    Write-Host "PowerShell ya está instalado en tu sistema."
}
else {
    Write-Host "PowerShell no está instalado en tu sistema. Se procederá a la instalación..."
    
    Invoke-Expression -Command "winget update"

    Invoke-Expression -Command "winget install Microsoft.PowerShell"

    $previousInstallationRunning = Get-Process | Where-Object { $_.ProcessName -eq "winget" }

    if ($previousInstallationRunning) {
        Write-Host "Esperando a que la instalación previa termine..."
        $previousInstallationRunning.WaitForExit()
    }

    # Verify Installation
    $sucessInstallation = (winget list | Select-String $PShell)

    if ($sucessInstallation) {
        Write-Host "PowerShell se ha instalado correctamente."
    }
    else {
        Write-Host "No se pudo instalar PowerShell. Comprueba tu configuración de 'winget' y los permisos de instalación."
    }
}

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
        # Open a new Windows Terminal window and continue the script
        Start-Process -FilePath "wt" -ArgumentList "pwsh.exe -NoExit -File `"$PSCommandPath`""
        # Exit the current PowerShell session
        exit
    }
    else {
        Write-Host "No se pudo instalar Oh My Posh. Comprueba tu configuración de 'winget' y los permisos de instalación."
    }
}

Invoke-Expression -Command "Get-PoshThemes"

if (Get-Module -Name "Terminal-Icons" -ListAvailable) {
    Write-Host "Terminal-Icons ya está instalado en tu sistema."
}
else {
    Write-Host "Terminal-Icons no está instalado en tu sistema. Se procederá a la instalación..."
    Invoke-Expression -Command "Install-Module -Name Terminal-Icons -Repository PSGallery"
}

Invoke-Expression -Command "Install-Script winfetch"

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
