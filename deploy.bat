@echo off
title MYTHRIX.AI - Deploy to Vercel
cd /d C:\FlutterProjects\Mythrix_AI
echo ===========================================
echo   MYTHRIX.AI - Production deploy
echo ===========================================
echo.
echo [1/3] Killing any old dart/flutter processes...
taskkill /F /IM dart.exe >nul 2>&1
taskkill /F /IM flutter.exe >nul 2>&1

echo.
echo [2/3] Building production bundle (flutter build web --release)...
echo This takes 60-90 seconds. Grab water.
echo.
call flutter build web --release --pwa-strategy=none --no-tree-shake-icons
if errorlevel 1 (
  echo.
  echo Build failed. Fix the errors above and try again.
  echo Press any key to close...
  pause >nul
  exit /b 1
)

echo.
echo Build complete. Output is in build\web\
echo.
echo [3/3] Deploying to Vercel...
echo If you haven't logged in to Vercel yet, a browser will open.
echo Approve the login in the browser, then come back here.
echo.
cd build\web

REM Write a Netlify _redirects file so deep links (/login, /app/dashboard) work.
echo /* /index.html 200 > _redirects

REM Write a netlify.toml with correct MIME types and cache headers.
(
  echo [build]
  echo   publish = "."
  echo.
  echo [[headers]]
  echo   for = "/*"
  echo   [headers.values]
  echo     Cache-Control = "public, max-age=0, must-revalidate"
  echo.
  echo [[headers]]
  echo   for = "/*.wasm"
  echo   [headers.values]
  echo     Content-Type = "application/wasm"
  echo.
  echo [[headers]]
  echo   for = "/*.js"
  echo   [headers.values]
  echo     Content-Type = "application/javascript"
) > netlify.toml

REM Write a vercel.json so SPA routing works correctly.
(
  echo {
  echo   "rewrites": [
  echo     { "source": "/(.*)", "destination": "/index.html" }
  echo   ],
  echo   "headers": [
  echo     {
  echo       "source": "/(.*)",
  echo       "headers": [
  echo         { "key": "Cache-Control", "value": "public, max-age=0, must-revalidate" }
  echo       ]
  echo     }
  echo   ]
  echo }
) > vercel.json

call npx vercel --prod --yes --name mythrix
if errorlevel 1 (
  echo.
  echo Vercel deploy failed. Most likely cause: not logged in.
  echo Run "npx vercel login" once, then double-click deploy.bat again.
  echo Press any key to close...
  pause >nul
  exit /b 1
)

echo.
echo ===========================================
echo   Deploy complete!
echo ===========================================
echo.
echo Your public URL is shown above.
echo Share it with 10 marketers tonight.
echo.
echo Press any key to close...
pause >nul
