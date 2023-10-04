$packageName = "JanDeDobbeleer.OhMyPosh"
$isInstalled = (winget list | Select-String $packageName)

if ($isInstalled) {
    Write-Host "JanDeDobbeleer.OhMyPosh está instalado en tu sistema."
} else {
    Write-Host "JanDeDobbeleer.OhMyPosh no está instalado en tu sistema. Se procederá a la instalación..."

    $install = "winget install JanDeDobbeleer.OhMyPosh -s winget"

    Invoke-Expression -Command $install

    # Verify Installation
    $sucessInstallation = (winget list | Select-String $packageName)

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
        Set-Content -Path $ConfNameFileLoc -Value $Content
        Write-Host "Se ha creado el archivo: $ConfNameFileLoc"
    }
}


$ConfNameFileLoc = "$PROFILE"
$Content = @"
Write-Host 'oh-my-posh init pwsh --config '$env:POSH_THEMES_PATH\clean-detailed.omp.json' | Invoke-Expression
Import-Module -Name Terminal-Icons
winfetch


Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView'
"@

ScriptConf -ConfNameFileLoc $ConfNameFileLoc -Content $Content
