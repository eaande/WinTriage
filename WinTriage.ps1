# WinTriage
# Windows DFIR Triage Tool

param(
    [switch]$Quick,
    [switch]$Full,
    [switch]$EventsOnly,
    [switch]$NoReport,
    [switch]$Help
)

if ($Help) {
    Write-Host ""
    Write-Host "WinTriage - Windows DFIR Triage Tool"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\WinTriage.ps1 -Quick"
    Write-Host "  .\WinTriage.ps1 -Full"
    Write-Host "  .\WinTriage.ps1 -EventsOnly"
    Write-Host "  .\WinTriage.ps1 -Full -NoReport"
    Write-Host ""
    exit
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutputRoot = Join-Path $Root "output"
$CaseDir = Join-Path $OutputRoot "case_$Timestamp"
$LogFile = Join-Path $CaseDir "collection_log.txt"
$Modules = Join-Path $Root "modules"

New-Item -ItemType Directory -Force -Path $CaseDir | Out-Null

function Write-CollectionLog {
    param([string]$Message)

    $Line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Add-Content -Path $LogFile -Value $Line
    Write-Host $Line
}

function Run-Module {
    param(
        [string]$Name,
        [string]$Path
    )

    if (Test-Path $Path) {
        Write-CollectionLog "Running module: $Name"
        & $Path -CaseDir $CaseDir -LogFile $LogFile
    }
    else {
        Write-CollectionLog "Missing module: $Name"
    }
}

Write-CollectionLog "Starting WinTriage collection"
Write-CollectionLog "Case directory: $CaseDir"

if ($EventsOnly) {
    Run-Module "Windows Event Logs" "$Modules\Collect-Events.ps1"
}
elseif ($Quick) {
    Run-Module "System Information" "$Modules\Collect-System.ps1"
    Run-Module "Users and Groups" "$Modules\Collect-Users.ps1"
    Run-Module "Running Processes" "$Modules\Collect-Processes.ps1"
    Run-Module "Network Connections" "$Modules\Collect-Network.ps1"
    Run-Module "Windows Event Logs" "$Modules\Collect-Events.ps1"
}
else {
    Run-Module "System Information" "$Modules\Collect-System.ps1"
    Run-Module "Users and Groups" "$Modules\Collect-Users.ps1"
    Run-Module "Running Processes" "$Modules\Collect-Processes.ps1"
    Run-Module "Network Connections" "$Modules\Collect-Network.ps1"
    Run-Module "Services" "$Modules\Collect-Services.ps1"
    Run-Module "Persistence" "$Modules\Collect-Persistence.ps1"
    Run-Module "Recent Files" "$Modules\Collect-Files.ps1"
    Run-Module "Windows Event Logs" "$Modules\Collect-Events.ps1"
}

if (-not $NoReport) {
    Run-Module "Build Report" "$Modules\Build-Report.ps1"
}

Write-CollectionLog "WinTriage collection complete"
