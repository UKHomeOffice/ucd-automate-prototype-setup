# GOV.UK Prototype Kit - Project Automation

Scripts to quickly create new GOV.UK Prototype Kit projects with GitHub and Heroku integration.

## Prerequisites (required)

You **must** have all of the following installed before using these scripts:

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
cd <your-cloned-folder>
```

### 2. Make the scripts executable

```bash
chmod +x setup.sh new-prototype.sh
```

### 3. Log in to GitHub and Heroku

```bash
gh auth login
heroku login
```

For enterprise Heroku accounts, use `heroku login --sso` instead.

### 4. Run the setup script

```bash
./setup.sh
```

> **Have your details ready.** You will be prompted for your GitHub username, Heroku email, and a default prototype password. Your settings are saved locally in `.prototype-config` and never committed to git.

## Creating a new prototype

Run this each time you want to set up a new project:

```bash
./new-prototype.sh my-project-name
```

Or run without arguments to be prompted:

```bash
./new-prototype.sh
```

> **Have your account details and passwords ready.** You will be prompted for GitHub and Heroku account choices during the process.

### What the script does

1. Creates the project directory and installs the GOV.UK Prototype Kit
2. Initialises a Git repository
3. Creates a GitHub repository (personal or organisation)
4. Creates a Heroku app and deploys the prototype

### What you will be asked

- **Project name** — lowercase with hyphens (e.g. `passport-checker`)
- **GitHub repo name** — defaults to the project name
- **GitHub account type** — personal or organisation
- **Heroku app name** — defaults to the project name
- **Heroku account type** — personal or team/enterprise
- **Heroku region** — only asked for team/enterprise accounts (defaults to EU)

## Troubleshooting

**"Permission denied" when running scripts:**
```bash
chmod +x setup.sh new-prototype.sh
```

**"Configuration not found":**
```bash
./setup.sh
```

**GitHub repo creation fails:**
```bash
gh auth login
```

**Heroku app creation fails:**
1. Check you are logged in: `heroku auth:whoami`
2. For enterprise accounts use: `heroku login --sso`
3. Check team access: `heroku teams`

## Useful links

- [GOV.UK Prototype Kit](https://prototype-kit.service.gov.uk/)
- [GitHub CLI](https://cli.github.com/)
- [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)
