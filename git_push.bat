@echo off
title MYTHRIX.AI - Push to GitHub
cd /d C:\FlutterProjects\Mythrix_AI
echo ===========================================
echo   MYTHRIX.AI - Push to GitHub
echo ===========================================
echo.

REM Check that git is installed
where git >nul 2>&1
if errorlevel 1 (
  echo ERROR: git is not installed or not on PATH.
  echo Install Git for Windows from https://git-scm.com/download/win
  echo then re-run this script.
  pause
  exit /b 1
)

REM Check if repo is already initialized
if exist ".git\HEAD" (
  echo Existing git repo found. Will commit + push.
  goto :STAGE
)

echo [1/4] Initializing git repository...
call git init -b main
if errorlevel 1 (
  echo Git init failed. Make sure you have Git 2.28+ installed.
  pause
  exit /b 1
)

echo.
echo Setting up identity defaults if missing...
git config user.name >nul 2>&1 || git config user.name "Mythrix Dev"
git config user.email >nul 2>&1 || git config user.email "dev@mythrix.ai"

:STAGE
echo.
echo [2/4] Staging files...
call git add -A
if errorlevel 1 (
  echo Stage failed.
  pause
  exit /b 1
)

echo.
echo [3/4] Committing...
REM Only commit if there's something to commit
git diff --cached --quiet
if errorlevel 1 (
  call git commit -m "Mythrix.AI: full launch-ready build (multi-brand, 11 ad networks, automation rules, audiences, conversions, landing page, deployed to Vercel)"
) else (
  echo Nothing to commit. Working tree clean.
)

echo.
echo [4/4] Pushing to GitHub...
echo.

REM Try GitHub CLI first (cleanest path)
where gh >nul 2>&1
if errorlevel 1 (
  echo GitHub CLI (gh) not found.
  echo.
  goto :FALLBACK
)

REM Check if gh is authenticated
call gh auth status >nul 2>&1
if errorlevel 1 (
  echo GitHub CLI found but not authenticated.
  echo Running gh auth login - your browser will open.
  echo Approve in the browser, then this script will continue automatically.
  echo.
  call gh auth login --web -h github.com -p https
  if errorlevel 1 (
    echo gh auth login failed.
    goto :FALLBACK
  )
)

REM Check if remote already exists
git remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo Creating new GitHub repo "mythrix-ai" (public) and pushing...
  call gh repo create mythrix-ai --public --source=. --push --description "MYTHRIX.AI - The autonomous marketing OS. 11 ad networks, 40+ integrations, automation rules, audiences, conversions, multi-brand workspace."
  if errorlevel 1 (
    echo Repo create failed - probably already exists. Trying to push to existing remote...
    goto :PUSH
  )
  goto :DONE
)

:PUSH
echo Pushing to existing remote...
call git push -u origin main
if errorlevel 1 (
  echo Push failed. You may need to set the remote manually:
  echo   git remote add origin https://github.com/YOUR-USERNAME/mythrix-ai.git
  echo   git push -u origin main
  pause
  exit /b 1
)
goto :DONE

:FALLBACK
echo.
echo ===========================================
echo  Manual fallback - open GitHub Desktop
echo ===========================================
echo.
echo Since GitHub CLI isn't set up, the cleanest path is:
echo.
echo   1. Open GitHub Desktop (it's installed on your machine)
echo   2. File - Add Local Repository - browse to C:\FlutterProjects\Mythrix_AI
echo   3. It will detect the new commits made by this script
echo   4. Click "Publish repository" - it auto-creates the GitHub repo
echo   5. Name: mythrix-ai - Description: as you like - Public/Private toggle
echo   6. Click Publish Repository - done in 10 seconds
echo.
echo Your local commits are ready to push. Press any key to open GitHub Desktop now...
pause >nul
start "" "github-desktop://"
exit /b 0

:DONE
echo.
echo ===========================================
echo   Push complete!
echo ===========================================
echo.
echo Your code is now on GitHub.
echo Vercel can be linked to it for auto-deploy on every commit.
echo.
echo Press any key to close...
pause >nul
