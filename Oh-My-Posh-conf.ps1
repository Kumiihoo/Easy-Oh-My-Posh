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


$ConfNameFileLoc = "$PROFILE.Microsoft.PowerShell_profile.ps1"
$Content = @"
Write-Host "oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/clean-detailed.omp.json" | Invoke-Expression
Import-Module -Name Terminal-Icons
winfetch


Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView"
"@

ScriptConf -ConfNameFileLoc $ConfNameFileLoc -Content $Content
