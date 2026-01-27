#!/bin/bash

# GOV.UK Prototype Kit - New Project Script
# Creates a new prototype with GitHub and Heroku setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "GOV.UK Prototype Kit - New Project"
echo "======================================"
echo ""

# Check if config exists
if [ ! -f ".prototype-config" ]; then
    echo -e "${RED}❌ Configuration not found.${NC}"
    echo "Please run ./setup.sh first to configure your settings."
    exit 1
fi

# Load config
source .prototype-config

# Get project name from argument or prompt
if [ -z "$1" ]; then
    read -p "Enter project name (lowercase, hyphens only): " project_name
else
    project_name="$1"
fi

# Validate project name
if [[ ! "$project_name" =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}❌ Invalid project name. Use lowercase letters, numbers, and hyphens only.${NC}"
    exit 1
fi

# Set project directory
project_dir="$PARENT_DIR/$project_name"

# Check if directory already exists
if [ -d "$project_dir" ]; then
    echo -e "${RED}❌ Directory already exists: $project_dir${NC}"
    exit 1
fi

echo ""
echo "Project configuration:"
echo "  Name: $project_name"
echo "  Location: $project_dir"
echo ""

# Ask for custom settings
read -p "GitHub repo name [default: $project_name]: " github_repo
github_repo="${github_repo:-$project_name}"

read -p "Heroku app name [default: $project_name]: " heroku_app
heroku_app="${heroku_app:-$project_name}"

echo ""
read -p "Use default password? (y/n) [default: y]: " use_default_password
use_default_password="${use_default_password:-y}"

if [ "$use_default_password" != "y" ]; then
    read -s -p "Enter custom password: " custom_password
    echo ""
    prototype_password="$custom_password"
else
    prototype_password="$DEFAULT_PASSWORD"
fi

echo ""
read -p "Additional plugins (comma-separated, blank for defaults only): " additional_plugins

# Combine plugins
if [ -n "$additional_plugins" ]; then
    all_plugins="$DEFAULT_PLUGINS,$additional_plugins"
else
    all_plugins="$DEFAULT_PLUGINS"
fi

echo ""
echo -e "${YELLOW}Review settings:${NC}"
echo "  Project: $project_name"
echo "  Directory: $project_dir"
echo "  GitHub repo: $GITHUB_USERNAME/$github_repo"
echo "  Heroku app: $heroku_app"
echo "  Plugins: ${all_plugins:-none}"
echo ""

read -p "Proceed with creation? (y/n): " proceed
if [ "$proceed" != "y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "======================================"
echo "Creating prototype..."
echo "======================================"
echo ""

# Step 1: Create directory
echo -e "${YELLOW}[1/6]${NC} Creating directory..."
mkdir -p "$project_dir"
cd "$project_dir"
echo -e "${GREEN}✅ Directory created${NC}"

# Step 2: Install GOV.UK Prototype Kit
echo ""
echo -e "${YELLOW}[2/6]${NC} Installing GOV.UK Prototype Kit..."
npx govuk-prototype-kit create --version latest .
echo -e "${GREEN}✅ Prototype Kit installed${NC}"

# Step 3: Install plugins
if [ -n "$all_plugins" ]; then
    echo ""
    echo -e "${YELLOW}[3/6]${NC} Installing plugins..."
    IFS=',' read -ra PLUGINS <<< "$all_plugins"
    for plugin in "${PLUGINS[@]}"; do
        plugin=$(echo "$plugin" | xargs) # Trim whitespace
        if [ -n "$plugin" ]; then
            echo "  Installing $plugin..."
            npm install "$plugin" || echo -e "${RED}  ⚠️  Failed to install $plugin${NC}"
        fi
    done
    echo -e "${GREEN}✅ Plugins installed${NC}"
else
    echo ""
    echo -e "${YELLOW}[3/6]${NC} No plugins to install"
fi

# Step 4: Set password
echo ""
echo -e "${YELLOW}[4/6]${NC} Setting prototype password..."
if [ -f ".env" ]; then
    # Check if password already set
    if grep -q "PASSWORD=" .env; then
        sed -i '' "s/PASSWORD=.*/PASSWORD=$prototype_password/" .env
    else
        echo "PASSWORD=$prototype_password" >> .env
    fi
else
    echo "PASSWORD=$prototype_password" > .env
fi
echo -e "${GREEN}✅ Password set${NC}"

# Step 5: Setup GitHub
echo ""
echo -e "${YELLOW}[5/6]${NC} Setting up GitHub repository..."
git init
git add .
git commit -m "Initial commit - GOV.UK Prototype Kit setup"

# Create GitHub repo (using GitHub CLI if available, otherwise instructions)
if command -v gh >/dev/null 2>&1; then
    echo "  Creating GitHub repository..."
    gh repo create "$github_repo" --private --source=. --remote=origin --push || {
        echo -e "${RED}  ⚠️  Failed to create GitHub repo via CLI${NC}"
        echo "  Please create manually at: https://github.com/new"
        echo "  Then run: git remote add origin git@github.com:$GITHUB_USERNAME/$github_repo.git"
        echo "            git push -u origin main"
    }
else
    git branch -M main
    echo -e "${YELLOW}  GitHub CLI not found.${NC}"
    echo "  Please create a repository manually:"
    echo "  1. Go to: https://github.com/new"
    echo "  2. Repository name: $github_repo"
    echo "  3. Make it private"
    echo "  4. Don't initialize with README"
    echo ""
    echo "  Then run these commands:"
    echo "    git remote add origin git@github.com:$GITHUB_USERNAME/$github_repo.git"
    echo "    git push -u origin main"
fi
echo -e "${GREEN}✅ Git initialized${NC}"

# Step 6: Setup Heroku
echo ""
echo -e "${YELLOW}[6/6]${NC} Setting up Heroku..."
if command -v heroku >/dev/null 2>&1; then
    # Check if logged in
    if heroku auth:whoami >/dev/null 2>&1; then
        echo "  Creating Heroku app..."
        heroku create "$heroku_app" || {
            echo -e "${RED}  ⚠️  App name might be taken. Heroku will generate a random name.${NC}"
            heroku create
        }
        
        # Add Node.js buildpack
        heroku buildpacks:set heroku/nodejs
        
        # Set environment variables
        heroku config:set NODE_ENV=production
        heroku config:set PASSWORD="$prototype_password"
        
        # Connect to GitHub (if repo was created successfully)
        if git remote get-url origin >/dev/null 2>&1; then
            echo "  Deploying to Heroku..."
            git push heroku main || echo -e "${YELLOW}  ⚠️  Push failed. You may need to enable Heroku-GitHub integration manually.${NC}"
        else
            echo -e "${YELLOW}  Skipping Heroku deployment - GitHub remote not configured${NC}"
        fi
        
        echo -e "${GREEN}✅ Heroku app created${NC}"
        echo ""
        echo "  Heroku app URL: https://$heroku_app.herokuapp.com"
    else
        echo -e "${RED}  ⚠️  Not logged into Heroku. Run 'heroku login' first.${NC}"
        echo "  Then manually create app: heroku create $heroku_app"
    fi
else
    echo -e "${RED}  ⚠️  Heroku CLI not installed${NC}"
    echo "  Install from: https://devcenter.heroku.com/articles/heroku-cli"
fi

echo ""
echo "======================================"
echo -e "${GREEN}✅ Project created successfully!${NC}"
echo "======================================"
echo ""
echo "Project details:"
echo "  📁 Location: $project_dir"
echo "  🔗 GitHub: https://github.com/$GITHUB_USERNAME/$github_repo"
echo "  🚀 Heroku: https://$heroku_app.herokuapp.com"
echo ""
echo "Next steps:"
echo "  1. cd $project_dir"
echo "  2. npm run dev"
echo "  3. Open http://localhost:3000"
echo ""
echo "The prototype password is: $prototype_password"
echo ""
