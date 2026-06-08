@echo off
title MYTHRIX.AI - Push assets fix
cd /d C:\FlutterProjects\Mythrix_AI

REM Force-add the .gitkeep placeholders inside otherwise-empty asset dirs
git add -f assets/images/.gitkeep assets/icons/.gitkeep assets/lottie/.gitkeep
git add vercel-build.sh
git commit -m "Vercel fix: placeholder asset dirs + auto-create .env from .env.example so flutter build web doesn't choke"
git push origin main

echo.
echo Pushed. Vercel rebuilding now.
echo Watch: https://vercel.com/slayer1908s-projects/mythrix/deployments
echo.
pause >nul
