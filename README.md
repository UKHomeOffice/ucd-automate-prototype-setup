# GOV.UK Prototype Kit - Project Automation

This is a set of scripts for automating the setup of a new GOV.UK Prototype Kit with GitHub and Heroku integration.

Created with AI assistance.

## 🎯 What This Does

This handles repetitive tasks when starting a new prototype so you can get up an running quickly. After a 1-time setup, it will:

1. ✅ Create a project directory on your local machine
2. ✅ Install a fresh version of the GOV.UK Prototype Kit into it
4. ✅ Initialise a Git repo
5. ✅ Creates GitHub repository
6. ✅ Sets up a Heroku app

You then just need to manually:
1. Set up a password for your prototype
2. Optionally connect Github to Heroku for automatic deployments 

## 📋 BEFORE YOU START

Before using this tool, ensure you have:

- **macOS** (tested on macOS 10.15+)
- **Node.js** (v18 or higher) - [Install](https://nodejs.org/)
- **Git** - Usually pre-installed on macOS
- **A GitHub account** with GitHub command line tool installed locally 
    - Recommend [installation via Homebrew](https://brew.sh/)
    - After homebrew is installed, install Github CLI via `brew install gh`
    - Then login on the command line `gh auth login`
- **A Heroku account** and Heroku CLI
    - Recommend installation via via Homebrew `brew install heroku/brew/heroku`
    - Then login on the command line `heroku login`

### Verify everything is installaed

```bash
node --version    # Should be v18 or higher
git --version     # Any recent version
heroku --version  # Any recent version
gh --version      # Any recent version
```

## First time setup

You will only have to do these steps once on your computer.

### 1. Clone or download a copy of this repository

```bash
git clone <your-repo-url>
cd <your cloned or downloaded folder>
```

### 2. Make scripts executable

```bash
chmod +x setup.sh
chmod +x new-prototype.sh
```

### 3. Run initial setup

This stores some preferences for every subsequent time you run the script. 

```bash
./setup.sh
```

You'll be prompted for:
- **GitHub username** - Your GitHub username
- **Default directory** - Where to create prototypes (e.g., `~/Projects/prototypes`)
- **Heroku email** - Email associated with your Heroku account
- **Default plugins** - Comma-separated plugin names (or leave blank)

**Important:** These settings are saved in `.prototype-config` which is gitignored and **never committed** to version control.

## How to set up a new project

Follow these instructions everytime you start a new project.

In terminal run the `./new-prototype.sh` script and give your project a lower case name - this will be used for the project folder name

```bash
./new-prototype.sh my-project-name
```
This works with your saved folder path in setup file, you don't need to specify the full path

Or run without arguments to be prompted:

```bash
./new-prototype.sh
```

### What you'll be asked

1. **Project name** - Lowercase with hyphens (e.g., `passport-checker`)
2. **GitHub repo name** - Defaults to project name, press enter to just use default
3. **GitHub account type** - Personal or organisation
4. **GitHub organisation** - If using organisation account
5. **Heroku app name** - Defaults to project name
6. **Heroku account type** - Personal or Team/Enterprise
7. **Heroku team name** - If using Team/Enterprise account
8. **Heroku region** - If using Heroku Enterprise, shere your app will be hosted:
   - Europe (eu) - Frankfurt, Germany [default]
   - United States (us) - Virginia, USA
   - Other (tokyo, sydney, oregon, dublin)
9. **Additional plugins** - Add extra plugins for this project only

### GitHub Setup

The script supports both personal and organisation GitHub accounts:

**Personal Account:**
- Select option 1 when prompted
- Repo created in your personal GitHub account

**Organisation Account:**
- Select option 2 when prompted
- Script lists available organisations 
- Enter organisation name 
- Repo created under organisation account

**Requirements for organisation repos:**
- You must have GitHub CLI (`gh`) installed
- You must be a member of the organisation
- You must have permission to create repositories in that org

### Heroku Region Selection

Usually you should choose Europe, but it will prompt you for whatever region is available

- **Europe (eu)**: For UK/European users [recommended for Home Office]
- **United States (us)**: For US users

### Heroku Setup

The script supports both personal and enterprise Heroku accounts:

**Personal Account:**
- Select option 1 when prompted
- App created in your personal account

**Team/Enterprise Account:**
- Select option 2 when prompted
- Script lists available teams
- Enter team name (e.g., `my-teams-apps`)
- App created under team account

## 🔧 Configuration

### View Your Configuration

```bash
cat .prototype-config
```

### Update Configuration

Simply run setup again:

```bash
./setup.sh
```

### Configuration File Structure

Your `.prototype-config` contains, you can edit it whenever you need:

```bash
GITHUB_USERNAME="your-username"
PARENT_DIR="/Users/you/Projects/prototypes"
HEROKU_EMAIL="you@example.com"
DEFAULT_PLUGINS="plugin1,plugin2"
```

**Security Note:** This file is automatically gitignored and should never be committed.

## 📝 Common Plugins

Here are some commonly used GOV.UK Prototype Kit plugins:

- `govuk-prototype-kit-step-by-step` - Step-by-step navigation
- `govuk-prototype-kit-common-templates` - Common page templates
- `@x-govuk/govuk-prototype-components` - Extended components

Add these during setup or per-project as needed.

## Security

### What's Safe to Commit

✅ Safe to commit:
- `setup.sh`
- `new-prototype.sh`
- `.gitignore`
- `.prototype-config.template`
- `README.md`

### What's Never Committed

❌ Never committed (automatically gitignored):
- `.prototype-config` - Contains your personal settings
- `.DS_Store` - macOS system files
- `node_modules/` - If you add any


## Troubleshooting

### "Permission denied" when running scripts

```bash
chmod +x setup.sh new-prototype.sh
```

### "Configuration not found"

Run setup first:
```bash
./setup.sh
```

### GitHub repo creation fails

Make sure you're authenticated:
```bash
# Using GitHub CLI
gh auth login

# Or verify SSH keys
ssh -T git@github.com
```

### Heroku app creation fails

1. Check you're logged in: `heroku auth:whoami`
2. **For enterprise accounts:** Use SSO login: `heroku login --sso`
3. App name might be taken - Heroku will suggest an alternative
4. Verify you have access to the team: `heroku teams`
5. Check you're in the correct Heroku account/organisation

### Cannot see Heroku teams

If `heroku teams` shows no teams:
1. Verify your enterprise SSO login: `heroku login --sso`
2. Check with your admin that you've been added to the team
3. You may need to accept a team invitation in your email

### Prototype Kit installation fails

Ensure Node.js v18+ is installed:
```bash
node --version
npm --version
```

## 🔄 Updating the Scripts

To get updates from the shared repository:

```bash
git pull origin main
```

Your personal `.prototype-config` won't be affected.

## Contributing

If you make improvements to these scripts:

1. Test thoroughly on your own projects
2. Update the README with any new features
3. Ensure no personal configuration leaks into commits
4. Share back via a pull request
