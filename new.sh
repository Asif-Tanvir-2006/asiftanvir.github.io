#!/usr/bin/env bash

set -e

echo "▶ Fixing Hugo + Blonde setup (safe mode)"

# 1. Ensure Hugo exists
if ! command -v hugo >/dev/null; then
  echo "❌ Hugo not found"
  exit 1
fi

if ! hugo version | grep -qi extended; then
  echo "❌ Hugo Extended required"
  echo "Install with: sudo apt install hugo-extended"
  exit 1
fi

echo "✔ Hugo Extended detected"

# 2. Remove Tailwind / PostCSS remnants
rm -rf assets/css || true
rm -f postcss.config.js tailwind.config.js || true

echo "✔ Removed Tailwind / PostCSS setup"

# 3. Ensure static CSS exists
mkdir -p static/css

if [ ! -f static/css/custom.css ]; then
  cat > static/css/custom.css <<'EOF'
/* Your custom overrides go here */
EOF
  echo "✔ Created static/css/custom.css"
fi

# 4. Fix package.json
if [ -f package.json ]; then
  node <<'EOF'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
pkg.scripts = pkg.scripts || {};
pkg.scripts.build = "hugo --minify";
fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
EOF
  echo "✔ Fixed package.json build script"
fi

# 5. Fix .gitignore
cat > .gitignore <<'EOF'
node_modules/
public/
resources/_gen/
.hugo_build.lock
EOF

echo "✔ .gitignore fixed"

# 6. Clean Hugo cache
rm -rf public resources

echo "✔ Hugo cache cleaned"

# 7. Final check
if [ ! -f themes/Blonde/static/css/blonde.min.css ]; then
  echo "⚠ Warning: Blonde CSS not found at expected path"
  echo "Check: themes/Blonde/static/css/blonde.min.css"
else
  echo "✔ Blonde CSS detected"
fi

echo
echo "🎉 Done!"
echo
echo "Run locally with:"
echo "  hugo server"
echo
echo "Deploy safely to Vercel."

