@echo off
title MYTHRIX.AI - REAL BILLING SYSTEM
cd /d C:\FlutterProjects\Mythrix_AI
git add -A
git commit -m "REAL BILLING: PlanTier model + Firestore-backed plan provider + real Billing screen (usage vs limits + upgrade flow + cancel) + topbar trial countdown / Upgrade pill + Pricing CTAs that actually start trial"
git push origin main
echo Pushed. Vercel rebuilding.
pause >nul
