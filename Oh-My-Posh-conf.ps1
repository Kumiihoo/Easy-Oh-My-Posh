$OhMyPosh = "JanDeDobbeleer.OhMyPosh"
$isInstalled = (winget list | Select-String $OhMyPosh)

if ($isInstalled) {
    Write-Host "Oh My Posh está instalado en tu sistema."
} else {
    Write-Host "Oh My Posh no está instalado en tu sistema. Se procederá a la instalación..."
    
    Invoke-Expression -Command "winget update"

    Invoke-Expression -Command "winget install JanDeDobbeleer.OhMyPosh -s winget"

    Invoke-Expression -Command "Get-PoshThemes"

    Invoke-Expression -Command "Install-Module -Name Terminal-Icons -Repository PSGallery"

    Invoke-Expression -Command "Install-Script winfetch"

    # Verify Installation
    $sucessInstallation = (winget list | Select-String $OhMyPosh)

    if ($sucessInstallation) {
        Write-Host "JanDeDobbeleer.OhMyPosh se ha instalado correctamente."
    } else {
        Write-Host "No se pudo instalar JanDeDobbeleer.OhMyPosh. Comprueba tu configuración de 'winget' y los permisos de instalación."
    }
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
