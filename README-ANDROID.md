# Claude / XPIKI Studio — Android Edition (v1.1.0)

This folder contains the complete Android application for XPIKI with the Claude starburst emblem, full-screen Gemini/Claude-style chat layout, native Arabic & English rendering, local history, image/document attachments, Quick/Full/Cancel large-document coverage, and encrypted API key storage.

## Two Ways to Get It on Your Android Phone

### Option 1: Build the Native `.apk` on Your Windows `D:` Drive (1-Click)
1. Extract this folder onto your **`D:`** drive (where you have free space).
2. Double-click **`Build-Android-APK.bat`**.
   - It automatically downloads a portable OpenJDK 17, Android SDK 34 build-tools, and Gradle 8.5 inside `.android-build-env` on your `D:` drive (never touching `C:`).
   - It compiles and signs **`dist\ClaudeStudio-Android.apk`**.
3. Copy **`dist\ClaudeStudio-Android.apk`** to your Android phone (via USB, Telegram, WhatsApp, or Google Drive) and tap it to install.

### Option 2: Instant Standalone File (`ClaudeStudio-Mobile-Standalone.html`)
- You can also copy **`ClaudeStudio-Mobile-Standalone.html`** directly to your phone and open it in Chrome/Brave, or tap **Add to Home screen** to install it immediately without waiting for an APK build.
