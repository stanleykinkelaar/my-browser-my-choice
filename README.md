# my-browser-my-choice

Keep your preferred browser as the default on Windows, even when something else keeps resetting it.

## How it works

Windows stores the default browser via a registry key called `MSEdgeHTM`. This tool overrides what `MSEdgeHTM` actually launches by defining it in `HKCU\SOFTWARE\Classes`, which takes precedence over the system definition. No admin rights required.

Supports Chrome, Firefox, and Zen Browser.

## Installation

1. Clone this repository:

```powershell
git clone https://github.com/stanleykinkelaar/my-browser-my-choice.git
cd my-browser-my-choice
```

2. Run the installer:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\install.ps1
```

3. Pick your browser from the menu. Done.

The script copies itself to `C:\Scripts\` and creates a startup shortcut so the override is re-applied automatically on every login.

## Switching browsers

Re-run `install.ps1` at any time and pick a different browser.

## Uninstalling

1. Delete `C:\Scripts\set-default-browser.ps1` and `C:\Scripts\browser.conf`
2. Delete `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\SetDefaultBrowser.lnk`
3. Delete `HKCU\SOFTWARE\Classes\MSEdgeHTM` from the registry
