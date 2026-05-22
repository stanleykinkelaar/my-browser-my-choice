# set-default-browser.ps1
# Runs silently on every login. Overrides the MSEdgeHTM ProgId in HKCU so that
# http/https links open your chosen browser, even if company policy forces
# UserChoice back to MSEdgeHTM.

# Wait for Group Policy / company defaults to apply first
Start-Sleep -Seconds 30

$confFile = "C:\Scripts\browser.conf"

# === Step 1: Find the browser exe ===
$browserExe = $null

if (Test-Path $confFile) {
    $browserExe = (Get-Content $confFile -Raw).Trim()
    if (-not (Test-Path $browserExe)) {
        $browserExe = $null
    }
}

# Fallback: scan for common browsers if config is missing or stale
if (-not $browserExe) {
    $fallbacks = @(
        "$env:LOCALAPPDATA\Zen Browser\zen.exe",
        "$env:PROGRAMFILES\Zen Browser\zen.exe",
        "$env:PROGRAMFILES\Mozilla Firefox\firefox.exe",
        "${env:PROGRAMFILES(x86)}\Mozilla Firefox\firefox.exe",
        "$env:PROGRAMFILES\Google\Chrome\Application\chrome.exe",
        "${env:PROGRAMFILES(x86)}\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
    )
    foreach ($path in $fallbacks) {
        if (Test-Path $path) {
            $browserExe = $path
            break
        }
    }
}

if (-not $browserExe) {
    exit 1
}

# === Step 2: Override MSEdgeHTM -> chosen browser in HKCU ===
# HKCU\SOFTWARE\Classes takes precedence over HKLM, so this shadows
# the system MSEdgeHTM definition without needing admin rights.
$command = "`"$browserExe`" `"%1`""
$regPath = "HKCU:\SOFTWARE\Classes\MSEdgeHTM\shell\open\command"

New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name "(default)" -Value $command

# === Step 3: Notify shell to refresh association cache ===
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Shell32 {
    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(uint wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);
}
"@
[Shell32]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)
