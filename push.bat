@echo off
title MYTHRIX.AI - Push: seeder + playbook
cd /d C:\FlutterProjects\Mythrix_AI
git add -A
git commit -m "Sample data seeder (/seed chat command) + LAUNCH_PLAYBOOK.md (LinkedIn posts, DM templates, demo script, FAQ)"
git push origin main
echo Pushed. Vercel deploying.
pause >nul
