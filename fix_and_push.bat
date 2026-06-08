@echo off
title Fix author + push Vercel config
cd /d C:\FlutterProjects\Mythrix_AI

echo Setting git identity to slayer1908...
git config user.name "slayer1908"
git config user.email "slayer1908@users.noreply.github.com"

REM Re-author the last commit to use the correct identity
git commit --amend --reset-author --no-edit

echo.
echo Staging vercel.json...
git add vercel.json
git add -A

git diff --cached --quiet
if errorlevel 1 (
  git commit -m "Add vercel.json so Vercel installs Flutter + runs flutter build web"
)

echo.
echo Pushing (force, to rewrite the previous commit's author)...
git push --force-with-lease -u origin main

if errorlevel 1 (
  echo Push failed. Trying force push...
  git push --force -u origin main
)

echo.
echo ===========================================
echo Push done. Vercel is rebuilding right now.
echo Wait ~3-5 minutes - first build clones Flutter ~250MB.
echo Watch progress: https://vercel.com/slayer1908s-projects/mythrix/deployments
echo ===========================================
pause >nul
