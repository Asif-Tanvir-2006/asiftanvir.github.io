#!/usr/bin/env bash

set -e

echo "▶ Hugo + Tailwind setup starting..."

# 1. Check Hugo
if ! command -v hugo >/dev/null; then
  echo "❌ Hugo not found. Install Hugo Extended first."
  exit 1
fi

if ! hugo version | grep -qi extended; then
  echo "❌ Hugo Extended is required."
  echo "Install with: sudo apt install hugo-extended"
  exit 1
fi

echo "✔ Hugo Extended detected"

# 2. Create assets/css/style.css
mkdir -p assets/css
cat > assets/css/style.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

echo "✔ assets/css/style.css created"

# 3. Create postcss.config.js
cat > postcss.config.js <<'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

echo "✔ postcss.config.js created"

# 4. Create tailwind.config.js
cat > tailwind.config.js <<'EOF'
module.exports = {
  content: [
    "./layouts/**/*.html",
    "./themes/Blonde/layouts/**/*.html",
    "./content/**/*.md"
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

echo "✔ tailwind.config.js created"

# 5. Fix package.json build script
if [ ! -f package.json ]; then
  echo "❌ package.json not found"
  exit 1
fi

node <<'EOF'
const fs = require("fs");

const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
pkg.scripts = pkg.scripts || {};
pkg.scripts.build = "hugo --minify";

fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
EOF

echo "✔ package.json build script fixed"

# 6. Install npm dependencies
npm install tailwindcss postcss autoprefixer --save-dev

echo "✔ npm dependencies installed"

# 7. Clean Hugo cache
rm -rf resources public

echo "✔ Hugo cache cleaned"

echo
echo "🎉 Setup complete!"
echo
echo "Next steps:"
echo "  hugo server"
echo "  open http://localhost:1313"

