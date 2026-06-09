@echo off
title MYTHRIX.AI - Push: bulk polish
cd /d C:\FlutterProjects\Mythrix_AI
git add -A
git commit -m "Bulk polish: real Brand Assets edit flow + Pricing page (Starter/Pro/Agency tiers + FAQ) + landing-page agency callout with mock brand list"
git push origin main
echo.
echo Pushed. Vercel auto-deploys in ~2 min.
echo.
pause >nul
