# set-default-browser.ps1
# Overrides the MSEdgeHTM ProgId in HKCU so that http/https links open your
# chosen browser.

$appDir   = Join-Path $env:LOCALAPPDATA "MyBrowserMyChoice"
$confFile = Join-Path $appDir "browser.conf"
$logFile  = Join-Path $appDir "browser-override.log"

function Write-Log {
    param([string]$Message)
    if (-not (Test-Path $appDir)) {
        New-Item -ItemType Directory -Path $appDir -Force | Out-Null
    }
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message" | Add-Content -Path $logFile -Encoding UTF8
}

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
    Write-Log "No browser executable found"
    exit 1
}

# === Step 2: Override MSEdgeHTM -> chosen browser in HKCU ===
# HKCU\SOFTWARE\Classes takes precedence over HKLM for the current user.
$command = "`"$browserExe`" `"%1`""
$regPath = "HKCU:\SOFTWARE\Classes\MSEdgeHTM\shell\open\command"

New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name "(default)" -Value $command
Write-Log "Set MSEdgeHTM command to $command"

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
Write-Log "Shell association cache refresh requested"
