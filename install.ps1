# install.ps1
# Run this once to choose your default browser and set up the automatic override.
# Re-run at any time to switch to a different browser.

$scriptsDir = "C:\Scripts"
$confFile   = "$scriptsDir\browser.conf"
$scriptDest = "$scriptsDir\set-default-browser.ps1"
$scriptSrc  = Join-Path $PSScriptRoot "set-default-browser.ps1"

# === Step 1: Detect installed browsers ===
$candidates = @(
    @{ Name = "Zen Browser"; Exe = "$env:LOCALAPPDATA\Zen Browser\zen.exe" },
    @{ Name = "Zen Browser"; Exe = "$env:PROGRAMFILES\Zen Browser\zen.exe" },
    @{ Name = "Firefox";     Exe = "$env:PROGRAMFILES\Mozilla Firefox\firefox.exe" },
    @{ Name = "Firefox";     Exe = "${env:PROGRAMFILES(x86)}\Mozilla Firefox\firefox.exe" },
    @{ Name = "Chrome";      Exe = "$env:PROGRAMFILES\Google\Chrome\Application\chrome.exe" },
    @{ Name = "Chrome";      Exe = "${env:PROGRAMFILES(x86)}\Google\Chrome\Application\chrome.exe" },
    @{ Name = "Chrome";      Exe = "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe" }
)

$found = @()
$seen  = @{}
foreach ($b in $candidates) {
    if ((Test-Path $b.Exe) -and -not $seen[$b.Exe]) {
        $found += $b
        $seen[$b.Exe] = $true
    }
}

if ($found.Count -eq 0) {
    Write-Host "[ERROR] No supported browser found. Install Chrome, Firefox, or Zen Browser first." -ForegroundColor Red
    exit 1
}

# === Step 2: Pick a browser ===
$chosen = $null

if ($found.Count -eq 1) {
    $chosen = $found[0]
    Write-Host "[OK] Only one browser found: $($chosen.Name)" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Installed browsers:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $found.Count; $i++) {
        Write-Host "  [$($i+1)] $($found[$i].Name)  ($($found[$i].Exe))"
    }
    Write-Host ""
    do {
        $input = Read-Host "Pick a number"
        $idx   = [int]$input - 1
    } while ($idx -lt 0 -or $idx -ge $found.Count)
    $chosen = $found[$idx]
}

Write-Host "[OK] Selected: $($chosen.Name) ($($chosen.Exe))" -ForegroundColor Green

# === Step 3: Copy script and save config ===
if (-not (Test-Path $scriptsDir)) {
    New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
}

Copy-Item -Path $scriptSrc -Destination $scriptDest -Force
Set-Content -Path $confFile -Value $chosen.Exe -Encoding UTF8

Write-Host "[OK] Script installed to $scriptDest" -ForegroundColor Green

# === Step 4: Create startup shortcut ===
$startup  = [Environment]::GetFolderPath('Startup')
$shortcut = "$startup\SetDefaultBrowser.lnk"
$shell    = New-Object -ComObject WScript.Shell
$link     = $shell.CreateShortcut($shortcut)
$link.TargetPath = "powershell.exe"
$link.Arguments  = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptDest`""
$link.Save()

Write-Host "[OK] Startup shortcut created" -ForegroundColor Green

# === Step 5: Apply immediately ===
Write-Host "Applying now..." -ForegroundColor Cyan
& powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File $scriptDest

Write-Host ""
Write-Host "[OK] Done! $($chosen.Name) is now your default browser." -ForegroundColor Green
Write-Host "     It will be re-applied automatically on every login." -ForegroundColor Gray
Write-Host "     Re-run this script at any time to switch browsers." -ForegroundColor Gray
