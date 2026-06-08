@echo off
title MYTHRIX.AI - Push: Firestore sync + agency UI
cd /d C:\FlutterProjects\Mythrix_AI
git add -A
git commit -m "Firestore cloud sync for brand profiles + agency-aware UI (dashboard greeting + brand-switcher badge)"
git push origin main
echo.
echo Pushed. Vercel auto-deploys in ~2 min.
echo.
pause >nul
