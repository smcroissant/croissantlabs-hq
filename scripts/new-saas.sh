#!/bin/bash
# 🥐 CroissantLabs — Create New SaaS Project
# Usage: ./scripts/new-saas.sh <project-name> [description]

set -e

PROJECT_NAME=${1:?Usage: ./scripts/new-saas.sh <project-name> [description]}
DESCRIPTION=${2:-"🥐 A CroissantLabs SaaS product"}
ORG="smcroissant"
BOILERPLATE="smcroissant/boilerplate-nextjs-expo-trpc-drizzle"

echo "🥐 Creating new SaaS: $PROJECT_NAME"

# Create repo from boilerplate
echo "📦 Creating repo from boilerplate..."
gh repo create "$ORG/$PROJECT_NAME" \
    --public \
    --description "$DESCRIPTION" \
    --clone=false

# Clone the boilerplate and push to new repo
TEMP_DIR=$(mktemp -d)
echo "📁 Cloning boilerplate to $TEMP_DIR..."
gh repo clone "$BOILERPLATE" "$TEMP_DIR" -- --depth=1

cd "$TEMP_DIR"
git remote set-url origin "https://github.com/$ORG/$PROJECT_NAME.git"
git push origin main

cd -
rm -rf "$TEMP_DIR"

# Set up labels
echo "🏷️ Setting up labels..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/setup-github.sh"

# Create initial issues
echo "📋 Creating initial issues..."

# CEO: Strategic kickoff
gh issue create \
    --repo "$ORG/$PROJECT_NAME" \
    --title "[STRATEGIC] Define $PROJECT_NAME MVP" \
    --body "## 🎯 Strategic Objective
Define the MVP scope for $PROJECT_NAME.

## 💡 Context
New SaaS project: $DESCRIPTION

## 🚀 Proposed Actions
- [ ] Define core features
- [ ] Set up database schema
- [ ] Create landing page
- [ ] Deploy to Vercel

## 📅 Timeline
MVP in 2 weeks" \
    --label "strategic,priority:high,agent:ceo"

# Setup Vercel
echo "🚀 Setting up Vercel..."
echo "Run: vercel --yes (in the $PROJECT_NAME repo)"

echo ""
echo "✅ $PROJECT_NAME is ready!"
echo ""
echo "📋 Next steps:"
echo "1. gh repo clone $ORG/$PROJECT_NAME"
echo "2. cd $PROJECT_NAME && npm install"
echo "3. Set up Neon database"
echo "4. Configure environment variables"
echo "5. Deploy: vercel --prod"
