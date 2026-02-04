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

# Expand tilde and any variables in PARENT_DIR
PARENT_DIR=$(eval echo "$PARENT_DIR")
# Remove trailing slash if present
PARENT_DIR="${PARENT_DIR%/}"

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
echo -e "${YELLOW}Review settings:${NC}"
echo "  Project: $project_name"
echo "  Directory: $project_dir"
echo "  GitHub repo: $GITHUB_USERNAME/$github_repo"
echo "  Heroku app: $heroku_app"
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

# Step 1: Prepare for prototype creation
echo -e "${YELLOW}[1/4]${NC} Preparing prototype directory..."
# Don't create the directory yet - let the kit create it
parent_dir=$(dirname "$project_dir")
project_name=$(basename "$project_dir")
echo -e "${GREEN}✅ Ready to create: $project_dir${NC}"

# Step 2: Install GOV.UK Prototype Kit
echo ""
echo -e "${YELLOW}[2/4]${NC} Installing GOV.UK Prototype Kit..."

# Change to parent directory
cd "$parent_dir"

# Try the official create command - it will create the directory
echo "  Running govuk-prototype-kit create..."
if npx --yes govuk-prototype-kit@latest create "$project_name" 2>&1 | grep -v "npm WARN"; then
    cd "$project_dir"
    echo -e "${GREEN}✅ Prototype Kit installed with all defaults${NC}"
else
    echo -e "${YELLOW}⚠️  Standard installation had warnings, checking result...${NC}"
    
    # Check if directory was created
    if [ -d "$project_dir" ]; then
        cd "$project_dir"
        
        # Check if it has the necessary files
        if [ -f "package.json" ] && [ -d "app" ]; then
            echo -e "${GREEN}✅ Prototype Kit installed successfully${NC}"
        else
            echo -e "${RED}❌ Prototype Kit installation incomplete${NC}"
            echo "Please try manual installation:"
            echo "  cd $parent_dir"
            echo "  npx govuk-prototype-kit create $project_name"
            exit 1
        fi
    else
        echo -e "${RED}❌ Failed to create prototype directory${NC}"
        echo "Please try manual installation:"
        echo "  cd $parent_dir"
        echo "  npx govuk-prototype-kit create $project_name"
        exit 1
    fi
fi

# Step 3: Setup GitHub
echo ""
echo -e "${YELLOW}[3/4]${NC} Setting up GitHub repository..."

# Temporarily disable exit on error
set +e

# Check if git is already initialized
if [ -d ".git" ]; then
    echo "  Git already initialized by prototype kit"
else
    git init
    echo "  Git repository initialized"
fi

# Ensure we're on main branch
git branch -M main 2>/dev/null

# Check if there are uncommitted changes
if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "  No uncommitted changes"
else
    # There are changes, commit them
    git add .
    git commit -m "Initial commit - GOV.UK Prototype Kit setup"
    echo "  Changes committed"
fi

# Re-enable exit on error
set -e

# Create GitHub repo (using GitHub CLI if available, otherwise instructions)
if command -v gh >/dev/null 2>&1; then
    echo ""
    echo "GitHub Account Setup:"
    echo "  1. Personal account ($GITHUB_USERNAME)"
    echo "  2. Organization account"
    read -p "Select account type (1 or 2): " github_account_type
    
    github_org=""
    github_owner="$GITHUB_USERNAME"
    
    if [ "$github_account_type" = "2" ]; then
        echo ""
        echo "Available GitHub organizations:"
        gh org list 2>/dev/null || echo "  No organizations found or unable to list"
        echo ""
        read -p "Enter organization name: " github_org
        github_owner="$github_org"
    fi
    
    echo ""
    echo "  Creating GitHub repository..."
    
    # Create repo with appropriate owner
    if [ -n "$github_org" ]; then
        # Create in organization
        if gh repo create "$github_org/$github_repo" --private --source=. --remote=origin --push 2>&1; then
            echo -e "${GREEN}✅ GitHub repository created: https://github.com/$github_org/$github_repo${NC}"
            github_full_repo="$github_org/$github_repo"
        else
            echo -e "${RED}  ❌ Failed to create GitHub repo in organization${NC}"
            echo "  Please create manually at: https://github.com/organizations/$github_org/repositories/new"
            echo "  Then run: git remote add origin git@github.com:$github_org/$github_repo.git"
            echo "            git push -u origin main"
            github_full_repo="$github_org/$github_repo"
        fi
    else
        # Create in personal account
        if gh repo create "$github_repo" --private --source=. --remote=origin --push 2>&1; then
            echo -e "${GREEN}✅ GitHub repository created: https://github.com/$GITHUB_USERNAME/$github_repo${NC}"
            github_full_repo="$GITHUB_USERNAME/$github_repo"
        else
            echo -e "${RED}  ❌ Failed to create GitHub repo via CLI${NC}"
            echo "  Please create manually at: https://github.com/new"
            echo "  Then run: git remote add origin git@github.com:$GITHUB_USERNAME/$github_repo.git"
            echo "            git push -u origin main"
            github_full_repo="$GITHUB_USERNAME/$github_repo"
        fi
    fi
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
    echo -e "${GREEN}✅ Git initialized locally${NC}"
    github_full_repo="$GITHUB_USERNAME/$github_repo"
fi

# Step 4: Setup Heroku
echo ""
echo -e "${YELLOW}[4/4]${NC} Setting up Heroku..."
if command -v heroku >/dev/null 2>&1; then
    # Check if logged in
    if heroku auth:whoami >/dev/null 2>&1; then

        # Ask about account type
        echo ""
        echo "Heroku Account Setup:"
        echo "  1. Personal account"
        echo "  2. Team/Enterprise account"
        read -p "Select account type (1 or 2): " account_type

        heroku_team=""
        heroku_region="eu"

        if [ "$account_type" = "2" ]; then
            echo ""
            echo "Available Heroku teams:"
            heroku teams 2>/dev/null || echo "  No teams found or unable to list teams"
            echo ""
            read -p "Enter team name: " heroku_team

            # Ask about region (only for team/enterprise accounts)
            echo ""
            echo "Heroku Region:"
            echo "  1. Europe (eu) - Frankfurt, Germany [default]"
            echo "  2. United States (us) - Virginia, USA"
            read -p "Select region (1 or 2) [default: 1 - EU]: " region_choice
            region_choice="${region_choice:-1}"

            case "$region_choice" in
                2)
                    heroku_region="us"
                    ;;
                *)
                    heroku_region="eu"
                    ;;
            esac
        fi

        echo ""
        echo "  Creating Heroku app in $heroku_region region..."

        # Build heroku create command
        create_cmd="heroku create $heroku_app --region $heroku_region"
        if [ -n "$heroku_team" ]; then
            create_cmd="$create_cmd --team $heroku_team"
        fi

        # Create app
        create_output=$($create_cmd 2>&1)

        # Check if creation was successful
        if echo "$create_output" | grep -q "https://"; then
            # Extract the actual app name from output
            actual_app_name=$(echo "$create_output" | grep -oE 'https://[^.]+\.herokuapp\.com' | sed 's/https:\/\///' | sed 's/\.herokuapp\.com//')
            if [ -z "$actual_app_name" ]; then
                actual_app_name="$heroku_app"
            fi

            echo -e "${GREEN}✅ Heroku app created: https://$actual_app_name.herokuapp.com${NC}"
            echo -e "   Region: $heroku_region"
            if [ -n "$heroku_team" ]; then
                echo -e "   Team: $heroku_team"
            fi

            # Save for summary section
            HEROKU_APP_NAME="$actual_app_name"

            # Temporarily disable exit on error for non-critical config
            set +e

            # Add Node.js buildpack
            echo "  Configuring buildpack..."
            if heroku buildpacks:set heroku/nodejs --app "$actual_app_name" 2>&1 | grep -q "Buildpack set\|buildpack is set"; then
                echo -e "  ${GREEN}✓${NC} Buildpack configured"
            else
                echo -e "  ${YELLOW}⚠️  Buildpack may already be set${NC}"
            fi

            set -e  # Re-enable exit on error

            echo -e "${GREEN}✅ Heroku app created${NC}"
            echo ""
            echo -e "  ${YELLOW}Note:${NC} Set a password for your prototype with:"
            echo "  heroku config:set NODE_ENV=production PASSWORD='your-password' --app $actual_app_name"
            
            # Deploy to Heroku
            echo ""
            echo "  Deploying to Heroku..."
            
            # Disable exit on error for git operations
            set +e
            
            if git push heroku main 2>&1 | grep -E "deployed to Heroku|Verifying deploy|remote:|https://" | tail -5; then
                echo ""
                echo -e "${GREEN}✅ Successfully deployed to Heroku${NC}"
                echo -e "   Your prototype is live at: https://$actual_app_name.herokuapp.com"
            else
                echo ""
                echo -e "${YELLOW}⚠️  Deployment may have failed${NC}"
                echo "   Try manually: cd $project_dir && git push heroku main"
            fi
            
            set -e  # Re-enable exit on error
            
            # Save app details for summary
            heroku_app_url="https://$actual_app_name.herokuapp.com"
            heroku_dashboard_url="https://dashboard.heroku.com/apps/$actual_app_name"
            heroku_github_integration_url="https://dashboard.heroku.com/apps/$actual_app_name/deploy"
            
        else
            echo -e "${RED}  ❌ Failed to create Heroku app${NC}"
            echo "  Error: $create_output"
            if echo "$create_output" | grep -q "Name is already taken"; then
                echo "  The app name '$heroku_app' is already taken."
                echo "  Try a different name or let Heroku generate one."
            fi
        fi
    else
        echo -e "${RED}  ❌ Not logged into Heroku${NC}"
        echo "  Run 'heroku login' first"
        echo ""
        echo "  For enterprise accounts, you may need:"
        echo "    heroku login --sso"
    fi
else
    echo -e "${RED}  ❌ Heroku CLI not installed${NC}"
    echo "  Install from: https://devcenter.heroku.com/articles/heroku-cli"
fi

echo ""
echo "======================================"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo "======================================"
echo ""
echo "Summary:"
echo -e "  📁 Directory: ${GREEN}$project_dir${NC}"

# Check if GitHub remote exists
if git remote get-url origin >/dev/null 2>&1; then
    github_url=$(git remote get-url origin | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
    echo -e "  🔗 GitHub: ${GREEN}$github_url${NC}"
else
    echo -e "  🔗 GitHub: ${YELLOW}Not yet configured${NC}"
fi

# Check if Heroku app was created
if [ -n "$HEROKU_APP_NAME" ]; then
    echo -e "  🚀 Heroku: ${GREEN}https://$HEROKU_APP_NAME.herokuapp.com${NC}"
else
    echo -e "  🚀 Heroku: ${YELLOW}Not configured${NC}"
fi

echo ""

echo "Next steps:"
echo "  1. cd $project_dir"
echo "  2. npm run dev"
echo "  3. Open http://localhost:3000"
echo "  4. Set up automatic deploys from Github in the Heroku app"

if [ -n "$HEROKU_APP_NAME" ]; then
    echo -e "Your prototype is live at: ${GREEN}https://$HEROKU_APP_NAME.herokuapp.com${NC}"
    echo ""

fi
