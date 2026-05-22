# my-browser-my-choice

Keep your preferred browser as the default on Windows.

## Warning

Use this tool at your own risk.

## How It Works

Windows opens web links through a registry entry called `MSEdgeHTM`. This tool creates a registry entry for the current user and points it to your chosen browser.

Supports Chrome, Firefox, and Zen Browser.

## Installation

This tool must be run from PowerShell. Other terminals are not supported.

1. Clone this repository:

```powershell
git clone https://github.com/stanleykinkelaar/my-browser-my-choice.git
cd my-browser-my-choice
```

2. Run the installer from PowerShell:

```powershell
powershell.exe -NoProfile -File .\install.ps1
```

3. Pick your browser from the menu.

The installer copies the runtime script to `%LOCALAPPDATA%\MyBrowserMyChoice` and creates a startup shortcut so the override is applied on every login.

## Switching Browsers

Run `install.ps1` again and pick a different browser.

## Uninstalling

Run:

```powershell
powershell.exe -NoProfile -File .\uninstall.ps1
```

This removes the startup shortcut, local config, runtime script, and `MSEdgeHTM` user registry override.

## Troubleshooting

Check the saved browser path:

```powershell
Get-Content "$env:LOCALAPPDATA\MyBrowserMyChoice\browser.conf"
```

Check the active override:

```powershell
(Get-ItemProperty "HKCU:\SOFTWARE\Classes\MSEdgeHTM\shell\open\command").'(default)'
```

Check the runtime log:

```powershell
Get-Content "$env:LOCALAPPDATA\MyBrowserMyChoice\browser-override.log"
```
