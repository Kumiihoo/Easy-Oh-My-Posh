# IMPORTANTE: Guarda este archivo de script (.ps1) usando la codificación UTF-8 con BOM
#            para evitar problemas con caracteres especiales y emojis.
#            En VS Code: Clic en la codificación (abajo a la derecha) > Guardar con codificación > UTF-8 con BOM.
#            En Notepad: Archivo > Guardar como > Codificación: UTF-8 con BOM.

$OhMyPosh = "JanDeDobbeleer.OhMyPosh"
$PShell = "Microsoft.PowerShell"
$Terminal = "Microsoft.WindowsTerminal"

# Aceptar automáticamente los prompts de winget (úsalo con precaución)
$env:ACCEPT_WINGET_INSTALLER_PROMPTS = "yes"

# Función para esperar si winget ya está en ejecución
function WaitWingetIfRunning {
    # Bucle para esperar si winget está corriendo
    while (Get-Process -Name "winget" -ErrorAction SilentlyContinue) {
        Write-Host "Esperando a que finalice una instalación previa de winget..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
}

# Instalar Windows Terminal si no está presente
if (!(winget list --id $Terminal --accept-source-agreements | Select-String $Terminal)) {
    Write-Host "Instalando Windows Terminal..."
    WaitWingetIfRunning
    winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
    WaitWingetIfRunning
    winget install --id $Terminal -e --accept-package-agreements --accept-source-agreements
    WaitWingetIfRunning
} else {
    Write-Host "✅ Windows Terminal ya está instalado." -ForegroundColor Green
}

# Instalar PowerShell 7 si no está presente
if (!(winget list --id $PShell --accept-source-agreements | Select-String $PShell)) {
    Write-Host "Instalando PowerShell 7..."
    WaitWingetIfRunning
    winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
    WaitWingetIfRunning
    winget install --id $PShell -e --accept-package-agreements --accept-source-agreements
    WaitWingetIfRunning
} else {
    Write-Host "✅ PowerShell 7 ya está instalado." -ForegroundColor Green
}

# Instalar Oh My Posh si no está presente
if (!(winget list --id $OhMyPosh --accept-source-agreements | Select-String $OhMyPosh)) {
    Write-Host "Instalando Oh My Posh..."
    WaitWingetIfRunning
    winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
    WaitWingetIfRunning
    winget install --id $OhMyPosh -e --accept-package-agreements --accept-source-agreements
    WaitWingetIfRunning
} else {
    Write-Host "✅ Oh My Posh ya está instalado." -ForegroundColor Green
}

# Scriptblock para instalar módulos de PowerShell (se ejecutará como admin si es necesario)
$InstallModulesScript = {
    param($CurrentUserName) # Pasar el nombre de usuario para el Scope

    # Instalar Terminal-Icons si no está presente para el usuario actual
    if (!(Get-Module -Name "Terminal-Icons" -ListAvailable -Scope CurrentUser)) {
        Write-Host "Instalando módulo Terminal-Icons para $CurrentUserName..."
        Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser -Confirm:$false -SkipPublisherCheck
    } else {
         Write-Host "✅ Módulo Terminal-Icons ya está instalado para $CurrentUserName." -ForegroundColor Green
    }

    # Instalar winfetch si no está presente para el usuario actual
    if (!(Get-Command winfetch -ErrorAction SilentlyContinue)) {
        Write-Host "Instalando script winfetch para $CurrentUserName..."
        Install-Script winfetch -Force -Scope CurrentUser -Confirm:$false -SkipPublisherCheck
    } else {
        Write-Host "✅ Script winfetch ya está instalado para $CurrentUserName." -ForegroundColor Green
    }
}

# Determinar si se necesita elevación para instalar módulos/scripts y ejecutarlos
$currentUserIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentUserPrincipal = New-Object Security.Principal.WindowsPrincipal($currentUserIdentity)
$CurrentUserName = $currentUserIdentity.Name

if ($currentUserPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Ya es administrador, ejecutar directamente
    Write-Host "Ejecutando instalación de módulos/scripts como Administrador..."
    Invoke-Command -ScriptBlock $InstallModulesScript -ArgumentList $CurrentUserName
} else {
    # No es administrador, intentar ejecutar como usuario normal (Scope CurrentUser debería funcionar)
     Write-Host "Ejecutando instalación de módulos/scripts como usuario estándar ($CurrentUserName)..."
     try {
        Invoke-Command -ScriptBlock $InstallModulesScript -ArgumentList $CurrentUserName -ErrorAction Stop
     } catch {
        Write-Warning "Falló la instalación de módulos/scripts como usuario estándar. Puede que necesites ejecutar el script completo como Administrador la primera vez."
        Write-Warning $_.Exception.Message
     }
}


# --- Configuración del Perfil de PowerShell 7 ---
$PS7ProfilePath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$ProfileDir = Split-Path -Path $PS7ProfilePath -Parent

# Asegurarse de que el directorio del perfil exista
if (!(Test-Path -Path $ProfileDir)) {
    Write-Host "Creando directorio para el perfil de PowerShell 7: $ProfileDir"
    New-Item -Path $ProfileDir -ItemType Directory -Force
}

# Contenido para el perfil de PowerShell 7
$ProfileContent = @'
# Inicializar Oh My Posh con un tema específico
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\clean-detailed.omp.json" | Invoke-Expression

# Importar Terminal-Icons si está disponible
if (Get-Module -Name "Terminal-Icons" -ListAvailable) {
    Import-Module -Name Terminal-Icons
}

# Ejecutar winfetch si está disponible
if (Get-Command winfetch -ErrorAction SilentlyContinue) {
    winfetch
}

# Configurar PSReadLine con predicciones (solo para PS 7.2+)
if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSVersionTable.PSVersion.Minor -ge 2) {
    try {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView
        Set-PSReadLineOption -EditMode Windows # Opcional: asegura modo de edición estándar
    } catch {
        Write-Host "ℹ️ No se pudo configurar PSReadLine con predicciones (opción no compatible o error)." -ForegroundColor Yellow
    }
}
'@

# Escribir el contenido en el archivo de perfil de PowerShell 7
Set-Content -Path $PS7ProfilePath -Value $ProfileContent -Force -Encoding UTF8 # Asegurar codificación UTF8
Write-Host "✅ Perfil de PowerShell 7 configurado en: $PS7ProfilePath" -ForegroundColor Green


# --- Limpieza del Perfil de PowerShell 5.1 (Opcional) ---
$profile51 = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path $profile51) {
    try {
        $original = Get-Content $profile51 -Raw -Encoding Default # Leer con la codificación por defecto del sistema
        # Intentar quitar líneas de configuración de predicción que no son válidas en PS 5.1
        $cleaned = $original -split '(\r?\n)' | Where-Object { $_ -notmatch 'Set-PSReadLineOption\s+-(PredictionSource|PredictionViewStyle)' }
        $newContent = $cleaned -join ''

        if ($original.Length -ne $newContent.Length) {
             # Guardar con codificación que preserve caracteres si es posible (UTF8 con BOM es seguro)
            Set-Content $profile51 -Value $newContent -Encoding UTF8 -Force
            Write-Host "🧹 Perfil de PowerShell 5.1 limpiado (líneas inválidas eliminadas)." -ForegroundColor Green
        } else {
            Write-Host "✅ Perfil de PowerShell 5.1 no necesitó limpieza." -ForegroundColor Green
        }
    } catch {
        Write-Warning "No se pudo procesar el perfil de PowerShell 5.1 en '$profile51'."
        Write-Warning $_.Exception.Message
    }
} else {
    Write-Host "ℹ️ No se encontró perfil de PowerShell 5.1 en '$profile51', nada que limpiar."
}


# --- Descarga de Nerd Font (JetBrainsMono) ---
$downloadUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" # Usar 'latest'
$fileName = "JetBrainsMonoNerdFont.zip" # Nombre más descriptivo

# --- Obtener la ruta de Descargas usando Shell.Application COM (Más robusto) ---
$downloadsPath = $null # Inicializar por si falla
try {
    $shell = New-Object -ComObject Shell.Application
    # Obtener la ruta de la carpeta de descargas del usuario actual
    $downloadsPath = $shell.NameSpace('shell:Downloads').Self.Path
    # Liberar el objeto COM (buena práctica)
    if ($shell) { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell) | Out-Null }
    Remove-Variable shell -ErrorAction SilentlyContinue # Limpiar variable
} catch {
    Write-Error "❌ No se pudo obtener la ruta de Descargas usando Shell.Application: $($_.Exception.Message)"
}

# --- Verificar si se obtuvo la ruta y continuar ---
if (-not [string]::IsNullOrWhiteSpace($downloadsPath) -and (Test-Path -Path $downloadsPath -PathType Container)) {
    # La ruta se obtuvo correctamente, definir $destPath
    Write-Host "ℹ️ Usando la ruta de descargas: $downloadsPath" -ForegroundColor Cyan
    $destPath = Join-Path -Path $downloadsPath -ChildPath $fileName

    # --- Lógica de descarga de la fuente (solo si la ruta es válida) ---
    if (Test-Path -LiteralPath $destPath) {
        Write-Host "🎉 La fuente ya se encuentra descargada en: $destPath" -ForegroundColor Green
        # Start-Process -FilePath explorer.exe -ArgumentList "/select,`"$destPath`"" # Descomentar si quieres abrir explorador
    } else {
        Write-Host "⬇️ Descargando JetBrainsMono Nerd Font a $destPath"
        # --- INICIO: Descarga manual con Write-Progress ---
        $client = $null
        $response = $null
        $stream = $null
        $fileStream = $null
        try {
             # Asegurar que System.Net.Http está disponible (generalmente sí en PS 5.1+)
            Add-Type -AssemblyName System.Net.Http -ErrorAction SilentlyContinue

            $client = New-Object System.Net.Http.HttpClient
            # Configurar timeout (ej: 2 minutos)
            $client.Timeout = New-TimeSpan -Minutes 2

            # Obtener respuesta (solo cabeceras primero)
            $response = $client.GetAsync($downloadUrl, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
            $response.EnsureSuccessStatusCode() | Out-Null # Lanza error si no es 2xx

            $totalBytes = $response.Content.Headers.ContentLength # Puede ser null si el servidor no lo envía

            # Abrir streams
            $stream = $response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
            $fileStream = [System.IO.File]::OpenWrite($destPath)

            # Buffer de descarga
            $buffer = New-Object byte[] 8192 # Buffer de 8KB
            $bytesRead = 0
            $totalRead = 0
            $lastPercent = -1

            # Bucle de lectura/escritura
            while (($bytesRead = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $fileStream.Write($buffer, 0, $bytesRead)
                $totalRead += $bytesRead

                if ($totalBytes -and $totalBytes -gt 0) {
                    # Calcular porcentaje si se conoce el tamaño total
                    $percent = [math]::Min(100, [math]::Round(($totalRead / $totalBytes) * 100)) # Asegurar que no pase de 100
                    if ($percent -ne $lastPercent) {
                        # Mostrar progreso con MB
                        $statusText = "{0:N2} MB / {1:N2} MB ({2}%)" -f ($totalRead / 1MB), ($totalBytes / 1MB), $percent
                        Write-Progress -Activity "Descargando fuente JetBrainsMono..." `
                                       -Status $statusText `
                                       -PercentComplete $percent `
                                       -CurrentOperation "Descargando..."
                        $lastPercent = $percent
                    }
                } else {
                    # Mostrar progreso sin porcentaje si no se conoce el tamaño total
                     $statusText = "{0:N2} MB descargados" -f ($totalRead / 1MB)
                     Write-Progress -Activity "Descargando fuente JetBrainsMono..." `
                                       -Status $statusText `
                                       -PercentComplete -1 `
                                       -CurrentOperation "Descargando..." # PercentComplete -1 indica indeterminado
                }
            } # Fin del while

            # Completar la barra de progreso
             Write-Progress -Activity "Descargando fuente JetBrainsMono..." -Completed

             Write-Host "`n✅ Fuente descargada en: $destPath" -ForegroundColor Green
             # Start-Process -FilePath explorer.exe -ArgumentList "/select,`"$destPath`"" # Descomentar si quieres abrir explorador
             Write-Host "ℹ️ Recuerda descomprimir el archivo '$fileName' e instalar las fuentes manualmente (clic derecho > Instalar)." -ForegroundColor Yellow

        } catch {
            Write-Error "❌ Error durante la descarga manual de la fuente: $($_.Exception.Message)"
            # Asegurarse de completar/cerrar la barra de progreso en caso de error
             Write-Progress -Activity "Descargando fuente JetBrainsMono..." -Completed
            # Opcional: eliminar archivo parcial si falló la descarga
            if (Test-Path -LiteralPath $destPath) {
                 try { $fileStream.Close() } catch {} # Intentar cerrar el archivo antes de borrar
                 Remove-Item -Path $destPath -Force -ErrorAction SilentlyContinue
            }
        } finally {
            # Asegurarse de cerrar y liberar recursos en cualquier caso (éxito o error)
            if ($fileStream -ne $null) { $fileStream.Close() }
            if ($stream -ne $null) { $stream.Dispose() }
            if ($response -ne $null) { $response.Dispose() }
            if ($client -ne $null) { $client.Dispose() }
        }
        # --- FIN: Descarga manual con Write-Progress ---
    }
    # --- Fin de la lógica de descarga ---

} else {
    # Falló la obtención de la ruta de descargas
    Write-Error "❌ No se pudo determinar una ruta de Descargas válida. Saltando la descarga de la fuente."
    # El script continuará con las siguientes secciones (validación de settings.json, etc.)
}


# --- Validación de la Configuración de Windows Terminal ---
$settingsPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$backupPath   = $settingsPath + ".bak"

function Test-ValidJson {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    try {
        Get-Content -Path $Path -Raw | ConvertFrom-Json -ErrorAction Stop | Out-Null
        return $true
    } catch {
        Write-Warning "Error al validar JSON en '$Path': $($_.Exception.Message)"
        return $false
    }
}

# Validar el archivo settings.json
if (Test-Path $settingsPath) {
    if (!(Test-ValidJson -Path $settingsPath)) {
        Write-Host "`n⚠️ El archivo settings.json de Windows Terminal parece estar corrupto." -ForegroundColor Yellow
        if (Test-Path $backupPath) {
            Write-Host "Intentando restaurar desde el backup: $backupPath"
            if (Test-ValidJson -Path $backupPath) {
                try {
                    Copy-Item -Path $backupPath -Destination $settingsPath -Force -ErrorAction Stop
                    Write-Host "✅ Configuración restaurada desde $backupPath correctamente." -ForegroundColor Green
                } catch {
                    Write-Error "❌ No se pudo restaurar desde el backup: $($_.Exception.Message)"
                }
            } else {
                 Write-Warning "❌ El archivo de backup '$backupPath' también parece estar dañado. Requiere revisión manual de '$settingsPath'."
            }
        } else {
            Write-Warning "❌ No se encontró backup '$backupPath'. Revisa manualmente '$settingsPath'."
        }
    } else {
        Write-Host "✅ La configuración de Windows Terminal ($settingsPath) es válida." -ForegroundColor Green
    }
} else {
     Write-Host "ℹ️ No se encontró el archivo settings.json en '$settingsPath'. Windows Terminal usará/creará valores predeterminados." -ForegroundColor Yellow
}


# --- Finalización ---
Write-Host "`n✅ Instalación y configuración básica completada." -ForegroundColor Green
Write-Host "La configuración ha terminado. Se abrirá una nueva pestaña de PowerShell 7." -ForegroundColor Cyan
Write-Host "PRESIONA CUALQUIER TECLA PARA FINALIZAR..." -ForegroundColor Yellow

# Esperar a que el usuario presione una tecla (sin mostrar la tecla presionada)
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null

# Mensaje justo antes de abrir la nueva pestaña
Write-Host "`nAbriendo nueva pestaña de PowerShell 7..." -ForegroundColor Cyan

# Abrir nueva pestaña en Windows Terminal usando el perfil "PowerShell 7"
Start-Process wt.exe

# Mensaje final antes de salir del script
Write-Host "Script finalizado. Puedes cerrar esta pestaña/ventana manualmente si lo deseas." -ForegroundColor DarkGray

# Salir del script (la ventana/tab actual NO se cerrará automáticamente)
exit