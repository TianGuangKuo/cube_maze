---
description: Launch 魔方钢珠迷宫 Flutter app in Chrome browser
---

# Run 魔方钢珠迷宫

Flutter SDK is at `D:\flutter_windows_3.44.1-stable\flutter` (not in PATH).

## Launch

```powershell
Set-Location "C:\Users\guang\Desktop\cube_maze"
D:\flutter_windows_3.44.1-stable\flutter\bin\flutter.bat run -d chrome
```

The app compiles and opens Chrome automatically (~15s first time). When you see:

```
Flutter run key commands.
r Hot reload. ...
```

The game is live. No further action needed — Chrome opens automatically.

## If it fails

**Symlink error** → Enable Windows Developer Mode: `Start-Process "ms-settings:developers"`

**Visual Studio error** → Use `-d chrome` instead of `-d windows`

**AssetManifest error** → Run `flutter clean` then `flutter pub get` then relaunch

**Port conflict / stale process** → Kill dart/chrome processes:
```powershell
Get-Process | Where-Object { $_.Name -match "dart|flutter" } | Stop-Process -Force
```

## First-time setup (if platform files missing)

```powershell
D:\flutter_windows_3.44.1-stable\flutter\bin\flutter.bat create . --project-name cube_maze
D:\flutter_windows_3.44.1-stable\flutter\bin\flutter.bat pub get
```
