#!/bin/bash

# GOV.UK Prototype Kit - One-Time Setup Script
# This script configures your personal settings for creating new prototypes

set -e

echo "======================================"
echo "GOV.UK Prototype Kit - Initial Setup"
echo "======================================"
echo ""
echo "This will configure your personal settings for creating new prototypes."
echo "Your settings will be stored locally in .prototype-config (not committed to git)."
echo ""

# Check if config already exists
if [ -f ".prototype-config" ]; then
    echo "⚠️  Configuration file already exists."
    read -p "Do you want to reconfigure? (y/n): " reconfigure
    if [ "$reconfigure" != "y" ]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

# Check for required tools
echo "Checking for required tools..."
echo ""

command -v git >/dev/null 2>&1 || { echo "❌ git is not installed. Please install git first."; exit 1; }
echo "✅ git found"

command -v npm >/dev/null 2>&1 || { echo "❌ npm is not installed. Please install Node.js first."; exit 1; }
echo "✅ npm found"

command -v heroku >/dev/null 2>&1 || { echo "⚠️  heroku CLI not found. Install from: https://devcenter.heroku.com/articles/heroku-cli"; }

echo ""
echo "Collecting your configuration..."
echo ""

# GitHub username
read -p "Enter your GitHub username: " github_username

# Default parent directory for prototypes
read -p "Enter the default directory for prototypes (e.g., ~/Projects/prototypes): " parent_dir
parent_dir=$(eval echo "$parent_dir")  # Expand tilde and variables
parent_dir="${parent_dir%/}"  # Remove trailing slash if present

# Create parent directory if it doesn't exist
if [ ! -d "$parent_dir" ]; then
    read -p "Directory doesn't exist. Create it? (y/n): " create_dir
    if [ "$create_dir" = "y" ]; then
        mkdir -p "$parent_dir"
        echo "✅ Created directory: $parent_dir"
    fi
fi

# Heroku account email
read -p "Enter your Heroku account email: " heroku_email

# Default plugins (comma-separated)
echo ""
echo "Enter any default plugins to install (comma-separated)."
echo "Example: govuk-prototype-kit-step-by-step,govuk-prototype-kit-common-templates"
echo "Leave blank if none:"
read -p "Default plugins: " default_plugins

# Default prototype password
echo ""
echo "Enter a default password for prototypes (you can override per-project)."
echo "This will be stored locally only - never committed to git."
read -s -p "Default prototype password: " default_password
echo ""

# Write config file
cat > .prototype-config << EOF
# GOV.UK Prototype Kit Configuration
# This file is ignored by git and contains your personal settings
# DO NOT commit this file to version control

GITHUB_USERNAME="$github_username"
PARENT_DIR="$parent_dir"
HEROKU_EMAIL="$heroku_email"
DEFAULT_PLUGINS="$default_plugins"
DEFAULT_PASSWORD="$default_password"
EOF

echo ""
echo "======================================"
echo "✅ Setup complete!"
echo "======================================"
echo ""
echo "Your configuration has been saved to .prototype-config"
echo "This file is gitignored and will not be committed."
echo ""
echo "Next steps:"
echo "1. Make sure you're logged into GitHub CLI or have SSH keys set up"
echo "2. Run 'heroku login' to authenticate with Heroku"
echo "3. Run './new-prototype.sh <project-name>' to create your first prototype"
echo ""
