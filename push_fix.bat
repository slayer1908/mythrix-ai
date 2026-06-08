@echo off
title MYTHRIX.AI - Push build script fix
cd /d C:\FlutterProjects\Mythrix_AI
git add vercel.json vercel-build.sh
git commit -m "Vercel build: move flutter install + build into vercel-build.sh (under 256 char limit)"
git push origin main
echo.
echo Pushed. Vercel rebuild triggered automatically.
echo Watch: https://vercel.com/slayer1908s-projects/mythrix/deployments
echo.
pause >nul
