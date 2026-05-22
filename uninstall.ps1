# uninstall.ps1
# Removes the startup shortcut, local config, and user-level browser override.

$appDir  = Join-Path $env:LOCALAPPDATA "MyBrowserMyChoice"
$startup = [Environment]::GetFolderPath('Startup')

Remove-Item "$startup\SetDefaultBrowser.lnk" -Force -ErrorAction SilentlyContinue
Remove-Item "$startup\SetZenDefault.lnk" -Force -ErrorAction SilentlyContinue
Remove-Item "HKCU:\SOFTWARE\Classes\MSEdgeHTM" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $appDir -Recurse -Force -ErrorAction SilentlyContinue

# Clean up files from early versions.
Remove-Item "C:\Scripts\set-default-browser.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Scripts\browser.conf" -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Scripts\set-zen-default.ps1" -Force -ErrorAction SilentlyContinue

Write-Host "[OK] Removed My Browser My Choice" -ForegroundColor Green
