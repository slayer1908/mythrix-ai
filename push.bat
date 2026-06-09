@echo off
title MYTHRIX.AI - Switch Stripe to Razorpay
cd /d C:\FlutterProjects\Mythrix_AI
git add -A
git commit -m "Switch billing: Stripe -> Razorpay (UPI/cards/netbanking, India-friendly). Add razorpay_service.dart with paymentLinks config + RAZORPAY_SETUP.md (full guide to taking real money)"
git push origin main
echo Pushed.
pause >nul
