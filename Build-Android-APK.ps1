$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$envRoot = Join-Path $PSScriptRoot '.android-build-env'
New-Item -ItemType Directory -Force -Path $envRoot | Out-Null

# Keep all temporary files and Gradle caches on D: (inside .android-build-env) so C: is never filled!
$env:TEMP = $envRoot
$env:TMP = $envRoot
$env:GRADLE_USER_HOME = Join-Path $envRoot 'gradle-home'
$env:ANDROID_USER_HOME = Join-Path $envRoot 'android-user'

Write-Host '=== Claude Studio XPIKI - Android APK Builder (Portable on current drive) ==='

# 1. Portable JDK 17
$jdkDir = Join-Path $envRoot 'jdk17'
$javaExe = Get-ChildItem -Path $jdkDir -Filter 'java.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $javaExe) {
    Write-Host 'Downloading portable OpenJDK 17 into .android-build-env (one-time)...'
    $jdkZip = Join-Path $envRoot 'jdk17.zip'
    Invoke-WebRequest -Uri 'https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse' -OutFile $jdkZip
    Expand-Archive -LiteralPath $jdkZip -DestinationPath $jdkDir -Force
    Remove-Item -LiteralPath $jdkZip -Force
    $javaExe = Get-ChildItem -Path $jdkDir -Filter 'java.exe' -Recurse | Select-Object -First 1
}
$env:JAVA_HOME = $javaExe.Directory.Parent.FullName
$env:PATH = "$($javaExe.Directory.FullName);$env:PATH"
Write-Host "Using JAVA_HOME: $env:JAVA_HOME"

# 2. Portable Android SDK Command-Line Tools
$sdkRoot = Join-Path $envRoot 'android-sdk'
$sdkManager = Join-Path $sdkRoot 'cmdline-tools\latestin\sdkmanager.bat'
if (-not (Test-Path -LiteralPath $sdkManager)) {
    Write-Host 'Downloading Android Command-Line Tools into .android-build-env (one-time)...'
    $cmdZip = Join-Path $envRoot 'cmdline-tools.zip'
    Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip' -OutFile $cmdZip
    $extractTmp = Join-Path $envRoot 'cmdline-extract'
    if (Test-Path -LiteralPath $extractTmp) { Remove-Item -LiteralPath $extractTmp -Recurse -Force }
    Expand-Archive -LiteralPath $cmdZip -DestinationPath $extractTmp -Force
    Remove-Item -LiteralPath $cmdZip -Force
    $latestDir = Join-Path $sdkRoot 'cmdline-tools\latest'
    New-Item -ItemType Directory -Force -Path $latestDir | Out-Null
    Get-ChildItem -LiteralPath (Join-Path $extractTmp 'cmdline-tools') -Force | ForEach-Object {
        Move-Item -LiteralPath $_.FullName -Destination $latestDir -Force
    }
    Remove-Item -LiteralPath $extractTmp -Recurse -Force
}
$env:ANDROID_HOME = $sdkRoot
$env:ANDROID_SDK_ROOT = $sdkRoot

Write-Host 'Accepting Android SDK licenses and installing platform-34 & build-tools 34.0.0...'
$yesInput = ("y`n" * 30)
$yesInput | & $sdkManager --sdk_root=$sdkRoot --licenses | Out-Null
& $sdkManager --sdk_root=$sdkRoot "platforms;android-34" "build-tools;34.0.0"

# 3. Portable Gradle 8.5
$gradleDir = Join-Path $envRoot 'gradle-8.5'
$gradleBat = Join-Path $gradleDir 'gradle-8.5in\gradle.bat'
if (-not (Test-Path -LiteralPath $gradleBat)) {
    Write-Host 'Downloading portable Gradle 8.5 into .android-build-env (one-time)...'
    $gradleZip = Join-Path $envRoot 'gradle.zip'
    Invoke-WebRequest -Uri 'https://services.gradle.org/distributions/gradle-8.5-bin.zip' -OutFile $gradleZip
    Expand-Archive -LiteralPath $gradleZip -DestinationPath $gradleDir -Force
    Remove-Item -LiteralPath $gradleZip -Force
}

Write-Host 'Compiling signed Android APK...'
& $gradleBat assembleRelease --no-daemon
if ($LASTEXITCODE -ne 0) {
    throw "Gradle APK build failed (exit $LASTEXITCODE)."
}

$distDir = Join-Path $PSScriptRoot 'dist'
New-Item -ItemType Directory -Force -Path $distDir | Out-Null
$builtApk = Join-Path $PSScriptRoot 'appuild\outputspkeleasepp-release.apk'
$finalApk = Join-Path $distDir 'ClaudeStudio-Android.apk'
Copy-Item -LiteralPath $builtApk -Destination $finalApk -Force
Write-Host "Finished: $finalApk"
