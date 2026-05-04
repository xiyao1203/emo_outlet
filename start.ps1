param(
    [ValidateSet("chrome", "edge", "web-server", "windows", "none")]
    [string]$FrontendMode = "chrome",
    [int]$FrontendPort = 5177,
    [int]$BackendPort = 8686,
    [switch]$SkipPubGet,
    [switch]$SkipBackend,
    [switch]$SkipFrontend
)

$ErrorActionPreference = "Stop"

function Write-Section {
    param(
        [string]$Text,
        [ConsoleColor]$Color = [ConsoleColor]::Cyan
    )

    Write-Host ""
    Write-Host ("=" * 56) -ForegroundColor $Color
    Write-Host $Text -ForegroundColor $Color
    Write-Host ("=" * 56) -ForegroundColor $Color
}

function Test-CommandExists {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Start-DevWindow {
    param(
        [string]$Title,
        [string]$WorkingDirectory,
        [string[]]$Commands
    )

    $commandText = @(
        "Set-Location -LiteralPath '$WorkingDirectory'"
        "`$Host.UI.RawUI.WindowTitle = '$Title'"
        $Commands
    ) -join "; "

    Start-Process -FilePath "powershell" -ArgumentList @(
        "-NoExit",
        "-ExecutionPolicy", "Bypass",
        "-Command", $commandText
    ) -WindowStyle Normal | Out-Null
}

function Get-FrontendCommand {
    param(
        [string]$Mode,
        [int]$Port
    )

    switch ($Mode) {
        "chrome"     { return "flutter run -d chrome --web-port=$Port" }
        "edge"       { return "flutter run -d edge --web-port=$Port" }
        "web-server" { return "flutter run -d web-server --web-port=$Port" }
        "windows"    { return "flutter run -d windows" }
        "none"       { return $null }
        default      { throw "Unsupported frontend mode: $Mode" }
    }
}

$rootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $rootDir "emo_outlet_api"
$frontendDir = Join-Path $rootDir "emo_outlet_app"

Write-Section "Emo Outlet dev launcher"
Write-Host "Root: $rootDir" -ForegroundColor Gray
Write-Host "Frontend mode: $FrontendMode" -ForegroundColor Gray
Write-Host "Backend port : $BackendPort" -ForegroundColor Gray
if ($FrontendMode -eq "web-server" -or $FrontendMode -eq "chrome" -or $FrontendMode -eq "edge") {
    Write-Host "Frontend port: $FrontendPort" -ForegroundColor Gray
}

if (-not $SkipBackend) {
    if (-not (Test-CommandExists "uvicorn")) {
        throw "uvicorn was not found. Activate your Python environment or install backend dependencies first."
    }

    Write-Section "Starting backend"
    Write-Host "API docs: http://localhost:$BackendPort/docs" -ForegroundColor Yellow
    Start-DevWindow `
        -Title "Emo Outlet backend" `
        -WorkingDirectory $backendDir `
        -Commands @(
            "Write-Host 'Starting FastAPI with reload on port $BackendPort' -ForegroundColor Cyan",
            "uvicorn app.main:app --reload --host 0.0.0.0 --port $BackendPort"
        )

    Start-Sleep -Seconds 2
}

if (-not $SkipFrontend -and $FrontendMode -ne "none") {
    if (-not (Test-CommandExists "flutter")) {
        throw "flutter was not found. Install Flutter SDK or add it to PATH."
    }

    if (-not $SkipPubGet) {
        Write-Section "Syncing Flutter dependencies"
        Push-Location $frontendDir
        try {
            flutter pub get
        } finally {
            Pop-Location
        }
    }

    $frontendCommand = Get-FrontendCommand -Mode $FrontendMode -Port $FrontendPort
    Write-Section "Starting frontend"
    if ($FrontendMode -eq "web-server") {
        Write-Host "Preview URL: http://localhost:$FrontendPort" -ForegroundColor Yellow
        Write-Host "Note: web-server is good for shared preview, but chrome/edge is better for hot reload." -ForegroundColor DarkYellow
    } elseif ($FrontendMode -eq "chrome" -or $FrontendMode -eq "edge") {
        Write-Host "Using browser dev mode for fast hot reload." -ForegroundColor Green
    } elseif ($FrontendMode -eq "windows") {
        Write-Host "Launching native Windows Flutter app." -ForegroundColor Green
    }

    Start-DevWindow `
        -Title "Emo Outlet frontend" `
        -WorkingDirectory $frontendDir `
        -Commands @(
            "Write-Host 'Starting Flutter in $FrontendMode mode' -ForegroundColor Cyan",
            $frontendCommand
        )
}

Write-Section "Done" ([ConsoleColor]::Green)
Write-Host "Backend : http://localhost:$BackendPort" -ForegroundColor Green
Write-Host "Swagger : http://localhost:$BackendPort/docs" -ForegroundColor Green
switch ($FrontendMode) {
    "web-server" { Write-Host "Frontend: http://localhost:$FrontendPort" -ForegroundColor Green }
    "chrome"     { Write-Host "Frontend: Chrome dev session on port $FrontendPort" -ForegroundColor Green }
    "edge"       { Write-Host "Frontend: Edge dev session on port $FrontendPort" -ForegroundColor Green }
    "windows"    { Write-Host "Frontend: native Windows app window" -ForegroundColor Green }
}

Write-Host ""
Write-Host "Examples:" -ForegroundColor Cyan
Write-Host "  ./start.ps1" -ForegroundColor Gray
Write-Host "  ./start.ps1 -FrontendMode web-server" -ForegroundColor Gray
Write-Host "  ./start.ps1 -FrontendMode windows -SkipPubGet" -ForegroundColor Gray
