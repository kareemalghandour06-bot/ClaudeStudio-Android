@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Build-Android-APK.ps1"
if errorlevel 1 (
  echo.
  echo APK build stopped. Read the message above.
) else (
  echo.
  echo APK build complete! Copy dist\ClaudeStudio-Android.apk to your phone and install it.
)
pause
