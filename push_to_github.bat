@echo off
title MYTHRIX.AI - Push to slayer1908/mythrix-ai
cd /d C:\FlutterProjects\Mythrix_AI
echo ===========================================
echo   Push to github.com/slayer1908/mythrix-ai
echo ===========================================
echo.

REM Make sure we have a commit on main
git branch -M main 2>nul
git add -A
git diff --cached --quiet
if errorlevel 1 (
  echo Committing latest changes...
  git commit -m "MYTHRIX.AI: production deploy + latest fixes"
)

REM ===== TRY GITHUB CLI (best case: one-shot) =====
where gh >nul 2>&1
if errorlevel 1 (
  echo GitHub CLI not installed - falling back to manual remote + push.
  goto :MANUAL
)

call gh auth status >nul 2>&1
if errorlevel 1 (
  echo GitHub CLI not signed in - falling back to manual remote + push.
  goto :MANUAL
)

echo Using GitHub CLI to create repo + push in one shot...
call gh repo create slayer1908/mythrix-ai --public --source=. --push --remote=origin --description "MYTHRIX.AI - The autonomous marketing OS. 11 ad networks, 40+ integrations, automation rules, audiences, conversions, multi-brand workspace."
if not errorlevel 1 goto :SUCCESS

echo gh repo create failed - probably repo already exists. Trying push to existing remote...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/slayer1908/mythrix-ai.git
git push -u origin main
if not errorlevel 1 goto :SUCCESS

:MANUAL
echo.
echo ===========================================
echo   Manual fallback
echo ===========================================
echo.
echo Step 1 - Open https://github.com/new (opening it now)
echo   Name:   mythrix-ai
echo   Public, NOTHING else checked
echo   Click "Create repository"
echo.
echo Step 2 - After creating the empty repo, this script will push.
echo Opening browser now. Come back and press any key once the repo is created.
echo.
start "" "https://github.com/new"
pause >nul

echo Configuring remote + pushing...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/slayer1908/mythrix-ai.git
git branch -M main
git push -u origin main

if errorlevel 1 (
  echo.
  echo Push still failed. Most likely:
  echo   - Repo wasn't created at github.com/slayer1908/mythrix-ai
  echo   - OR you cancelled the sign-in popup
  echo Re-run this script after fixing.
  pause
  exit /b 1
)

:SUCCESS
echo.
echo ===========================================
echo   Push complete!
echo ===========================================
echo.
echo Repo: https://github.com/slayer1908/mythrix-ai
echo.
echo Now connect it to Vercel for auto-deploy:
echo   1. Open https://vercel.com/slayer1908s-projects/mythrix/settings/git
echo   2. Click "Connect" next to mythrix-ai
echo   3. Every git push will now auto-deploy to mythrix-phi.vercel.app
echo.
echo Press any key to close...
pause >nul
