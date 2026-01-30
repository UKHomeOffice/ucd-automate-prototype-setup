# GOV.UK Prototype Kit - Project Automation

Automated setup scripts for quickly creating new GOV.UK Prototype Kit projects with GitHub and Heroku integration.

## 🎯 What This Does

This automation handles all the repetitive tasks when starting a new prototype:

1. ✅ Creates project directory on your local machine
2. ✅ Installs latest GOV.UK Prototype Kit into it
3. ✅ Installs any preferred plugins
4. ✅ Initializes a Git repository
5. ✅ Creates GitHub repository
6. ✅ Sets up Heroku app

You can them setup automatic GiHub deployments from within the Heroku app. 

## 📋 Prerequisites

Before using these scripts, ensure you have:

- **macOS** (tested on macOS 10.15+)
- **Node.js** (v18 or higher) - [Install](https://nodejs.org/)
- **Git** - Usually pre-installed on macOS
- **GitHub account** with SSH keys or GitHub CLI configured (recommend instalation via Homebrew)
- **Heroku account** and Heroku CLI - [Install](https://devcenter.heroku.com/articles/heroku-cli)

### Verify Prerequisites

```bash
node --version    # Should be v18 or higher
git --version     # Any recent version
heroku --version  # Any recent version
gh --version      # Optional but recommended
```

## 🚀 First Time Setup

You will only have to do these steps once.

### 1. Clone or Download This Repository

```bash
git clone <your-repo-url>
cd <your cloned or downloaded folder>
```

### 2. Make Scripts Executable

```bash
chmod +x setup.sh
chmod +x new-prototype.sh
```

### 3. Run Initial Setup

This stores some preferences for every time you run the script. 

```bash
./setup.sh
```

You'll be prompted for:
- **GitHub username** - Your GitHub username
- **Default directory** - Where to create prototypes (e.g., `~/Projects/prototypes`)
- **Heroku email** - Email associated with your Heroku account
- **Default plugins** - Comma-separated plugin names (or leave blank)

**Important:** Your settings are saved in `.prototype-config` which is gitignored and **never committed** to version control.

### 4. Authenticate with Services in Terminal

```bash
# Login to Heroku
heroku login

# Login to GitHub (if using GitHub CLI)
gh auth login
```

## 📦 Creating a New Prototype

Once set up, creating a new prototype is simple:

```bash
./new-prototype.sh my-project-name
```
Because this works with your saved folder path in setup file, you don't need to specify the full path

Or run without arguments to be prompted:

```bash
./new-prototype.sh
```

### What You'll Be Asked

1. **Project name** - Lowercase with hyphens (e.g., `passport-checker`)
2. **GitHub repo name** - Defaults to project name, press enter to just use default
3. **GitHub account type** - Personal or Organization
4. **GitHub organization** - If using Organization account
5. **Heroku app name** - Defaults to project name
6. **Heroku account type** - Personal or Team/Enterprise
7. **Heroku team name** - If using Team/Enterprise account
8. **Heroku region** - Where your app will be hosted:
   - Europe (eu) - Frankfurt, Germany [default]
   - United States (us) - Virginia, USA
   - Other (tokyo, sydney, oregon, dublin)
9. **Additional plugins** - Add extra plugins for this project only

### GitHub Setup

The script supports both personal and organization GitHub accounts:

**Personal Account:**
- Select option 1 when prompted
- Repo created in your personal GitHub account

**Organization Account:**
- Select option 2 when prompted
- Script lists available organizations (requires GitHub CLI)
- Enter organization name (e.g., `home-office-digital`)
- Repo created under organization account

**Requirements for Organization repos:**
- You must have GitHub CLI (`gh`) installed
- You must be a member of the organization
- You must have permission to create repositories in that org

### Heroku Region Selection

Choose the region closest to your users for best performance:
- **Europe (eu)**: For UK/European users [recommended for Home Office]
- **United States (us)**: For US users
- **Other**: Tokyo, Sydney, Oregon, Dublin

### Heroku Setup

The script supports both personal and enterprise Heroku accounts:

**Personal Account:**
- Select option 1 when prompted
- App created in your personal account

**Team/Enterprise Account:**
- Select option 2 when prompted
- Script lists available teams
- Enter team name (e.g., `home-office-digital`)
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

Your `.prototype-config` contains:

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

## 🔒 Security

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


## 🐛 Troubleshooting

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
5. Check you're in the correct Heroku account/organization

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

## 📚 Additional Resources

- [GOV.UK Prototype Kit Documentation](https://prototype-kit.service.gov.uk/)
- [GitHub CLI Documentation](https://cli.github.com/)
- [Heroku CLI Documentation](https://devcenter.heroku.com/articles/heroku-cli)

## 💡 Tips

1. **Use descriptive project names** - They become your repo and app names
2. **Test locally first** - Run `npm run dev` before relying on Heroku deployment
3. **Keep plugins consistent** - Set common plugins in defaults to save time
4. **Document custom changes** - If you modify the scripts, update this README

## 🤝 Contributing

If you make improvements to these scripts:

1. Test thoroughly on your own projects
2. Update the README with any new features
3. Ensure no personal configuration leaks into commits
4. Share back with the team via pull request
