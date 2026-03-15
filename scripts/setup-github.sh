#!/bin/bash
# 🥐 CroissantLabs — GitHub Labels Setup Script
# Run this once to set up all labels on your repos

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🥐 Setting up CroissantLabs GitHub labels...${NC}"

# Function to create label (skip if exists)
create_label() {
    local name=$1
    local color=$2
    local desc=$3
    
    if gh label create "$name" --color "$color" --description "$desc" --force 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $name"
    else
        echo -e "  ${RED}✗${NC} $name"
    fi
}

# Function to set up labels for a repo
setup_repo() {
    local repo=$1
    echo -e "\n${YELLOW}📦 Setting up $repo...${NC}"
    
    gh repo view "$repo" &>/dev/null || {
        echo -e "  ${RED}✗ Repo not found, skipping${NC}"
        return
    }
    
    # Agent labels
    create_label "agent:ceo" "FF0000" "CEO Agent" 
    create_label "agent:pm" "FF6B00" "Product Manager Agent"
    create_label "agent:dev" "0075CA" "Developer Agent"
    create_label "agent:devops" "0E8A16" "DevOps Agent"
    create_label "agent:marketing" "D93F0B" "Marketing Agent"
    create_label "agent:support" "7057FF" "Support Agent"
    
    # Type labels
    create_label "strategic" "B60205" "Strategic decision"
    create_label "spec" "D93F0B" "Product specification"
    create_label "feature" "0075CA" "Feature implementation"
    create_label "bug" "D73A4A" "Bug fix"
    create_label "infra" "0E8A16" "Infrastructure"
    create_label "content" "FBCA04" "Marketing content"
    create_label "support" "7057FF" "User support"
    
    # Priority labels
    create_label "priority:critical" "B60205" "Critical priority"
    create_label "priority:high" "D93F0B" "High priority"
    create_label "priority:medium" "FBCA04" "Medium priority"
    create_label "priority:low" "0E8A16" "Low priority"
    
    # Status labels
    create_label "status:todo" "EDEDED" "To do"
    create_label "status:in-progress" "0075CA" "In progress"
    create_label "status:review" "FBCA04" "In review"
    create_label "status:done" "0E8A16" "Done"
    create_label "status:blocked" "B60205" "Blocked"
    
    echo -e "  ${GREEN}✓ $repo done!${NC}"
}

# === SETUP ===

# Company HQ repo
echo -e "\n${YELLOW}🏢 Creating company HQ repo...${NC}"
gh repo create croissantlabs-hq --public --description "🥐 CroissantLabs HQ — Autonomous SaaS Factory" --clone=false 2>/dev/null || echo -e "  ${YELLOW}Repo already exists${NC}"

# Set up labels for all repos
REPOS=(
    "croissantlabs-hq"
    "llmtrust"
    "uptimefunky"
    "croissantpay"
    "quote-forge"
)

for repo in "${REPOS[@]}"; do
    setup_repo "smcroissant/$repo"
done

echo -e "\n${GREEN}🎉 All done! Labels are set up.${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Push croissantlabs-hq content to GitHub"
echo "2. Set up Vercel integrations for each repo"
echo "3. Start the agent cron jobs"
