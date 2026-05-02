param(
    [string]$CaseDir,
    [string]$LogFile
)

$OutFile = Join-Path $CaseDir "system_info.txt"

"WinTriage - System Information" | Out-File $OutFile
"Generated: $(Get-Date)" | Out-File $OutFile -Append
"" | Out-File $OutFile -Append

"Hostname:" | Out-File $OutFile -Append
$env:COMPUTERNAME | Out-File $OutFile -Append
"" | Out-File $OutFile -Append

"Current User:" | Out-File $OutFile -Append
$env:USERNAME | Out-File $OutFile -Append
"" | Out-File $OutFile -Append

"Operating System:" | Out-File $OutFile -Append
Get-CimInstance Win32_OperatingSystem |
    Select-Object Caption, Version, BuildNumber, OSArchitecture, LastBootUpTime |
    Format-List | Out-File $OutFile -Append
"" | Out-File $OutFile -Append

"Computer System:" | Out-File $OutFile -Append
Get-CimInstance Win32_ComputerSystem |
    Select-Object Manufacturer, Model, TotalPhysicalMemory, Domain |
    Format-List | Out-File $OutFile -Append
"" | Out-File $OutFile -Append

"BIOS:" | Out-File $OutFile -Append
Get-CimInstance Win32_BIOS |
    Select-Object Manufacturer, SMBIOSBIOSVersion, SerialNumber |
    Format-List | Out-File $OutFile -Append
"" | Out-File $OutFile -Append

"Defender Status:" | Out-File $OutFile -Append
try {
    Get-MpComputerStatus |
        Select-Object AMServiceEnabled, AntivirusEnabled, RealTimeProtectionEnabled, AntivirusSignatureLastUpdated |
        Format-List | Out-File $OutFile -Append
}
catch {
    "Unable to collect Microsoft Defender status." | Out-File $OutFile -Append
}
