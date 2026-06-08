@echo off
title MYTHRIX.AI - Push NOW
cd /d C:\FlutterProjects\Mythrix_AI
echo Pushing to github.com/slayer1908/mythrix-ai...
echo.

REM Stage any new files
git add -A
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "MYTHRIX.AI: full launch-ready build"
)

REM Force-fix branch + remote
git branch -M main
git remote remove origin >nul 2>&1
git remote add origin https://github.com/slayer1908/mythrix-ai.git

REM Push - a "Sign in to GitHub" window may pop up the FIRST time
echo If a "Sign in to GitHub" window opens, click "Sign in with browser"
echo and approve in Chrome - takes 5 seconds, then never asked again.
echo.
git push -u origin main

if errorlevel 1 (
  echo.
  echo Push FAILED. Most likely:
  echo   - You didn't create the empty repo at github.com/slayer1908/mythrix-ai
  echo   - OR you cancelled the GitHub sign-in popup
  echo.
  echo Fix and re-run this file.
  pause
  exit /b 1
)

echo.
echo ===========================================
echo   PUSH COMPLETE!
echo ===========================================
echo.
echo Code is live at: https://github.com/slayer1908/mythrix-ai
echo.
echo Now connect to Vercel for auto-deploy:
echo   https://vercel.com/slayer1908s-projects/mythrix/settings/git
echo   Click "Connect" next to mythrix-ai
echo.
echo Press any key to close...
pause >nul
