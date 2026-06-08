#!/usr/bin/env bash
set -euo pipefail

# Install Flutter SDK on Vercel build container (cache reused across builds).
if [ -d "flutter/bin" ]; then
  echo "Flutter SDK already cached, updating..."
  cd flutter && git pull && cd ..
else
  echo "Cloning Flutter SDK (stable channel, shallow)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PATH:`pwd`/flutter/bin"

flutter --version
flutter doctor -v || true
flutter config --no-analytics
# Vercel doesn't ship secrets — create an empty .env so the asset bundler
# is happy. Real secrets get wired via Vercel project env vars later.
[ ! -f .env ] && cp .env.example .env

flutter clean
flutter pub get
flutter build web --release --pwa-strategy=none --no-tree-shake-icons

echo "Build complete. Output in build/web."
ls -la build/web | head -20
