@echo off
title MYTHRIX.AI - Launching
cd /d C:\FlutterProjects\Mythrix_AI
echo ===========================================
echo   MYTHRIX.AI - Launching (clean build)
echo ===========================================
echo.
echo Killing any existing dart/flutter processes...
taskkill /F /IM dart.exe >nul 2>&1
taskkill /F /IM flutter.exe >nul 2>&1
echo.
echo [1/3] Cleaning build cache (flutter clean)...
echo.
call flutter clean
echo.
echo [2/3] Fetching dependencies (flutter pub get)...
echo.
call flutter pub get
echo.
echo [3/3] Launching app in Chrome (flutter run -d chrome)...
echo.
echo Chrome will open automatically. Keep this window open.
echo Press 'q' in this window to stop the app.
echo.
call flutter run -d chrome
echo.
echo App stopped. Press any key to close this window.
pause >nul
