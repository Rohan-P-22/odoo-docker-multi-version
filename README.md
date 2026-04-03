# 🐳 Odoo Docker Multi-Version

A production-ready infrastructure for running **Odoo 18** and **Odoo 19** simultaneously on a single server using Docker, with automated CI/CD, HTTPS, monitoring, and auto-rollback deployment.

---

## 📋 Table of Contents

1. [Project Overview](#-project-overview)
2. [Architecture](#-architecture)
3. [Project Structure](#-project-structure)
4. [Access URLs](#-access-urls)
5. [Getting Started — New Developer](#-getting-started--new-developer-first-day)
6. [Branching Strategy](#-branching-strategy)
7. [How to Create a Custom Module](#-how-to-create-a-custom-module)
8. [CI/CD Pipeline](#-cicd-pipeline)
9. [How Modules Reach the Server](#-how-modules-reach-the-server)
10. [Local Development Setup](#-local-development-setup)
11. [Security](#-security)
12. [Monitoring](#-monitoring)
13. [Troubleshooting](#-troubleshooting)
14. [Common Errors & Fixes](#-common-errors--fixes)
15. [Important Rules](#-important-rules)

---

## 🏗️ Project Overview

This project runs two versions of Odoo on a single DigitalOcean server:

| Version | Port (HTTP) | Port (HTTPS) | Purpose |
|---------|-------------|--------------|---------|
| Odoo 18 | 8069 | 8443 | Clients using Odoo 18 |
| Odoo 19 | 8070 | 8444 | Clients using Odoo 19 |

Both versions share one PostgreSQL database server but have completely isolated databases, networks, and custom modules.

**Tech Stack:**
- 🐳 Docker + Docker Compose — containerization
- 🔀 Nginx — reverse proxy + SSL termination
- 🐘 PostgreSQL 15 — shared database server
- 🔄 GitHub Actions — CI/CD pipeline
- 📊 Prometheus + Grafana — monitoring
- 🔔 Telegram Bot — instant alerts

---

## 🏛️ Architecture

```
                        🌐 INTERNET
                              |
                   🔒 UFW FIREWALL
                    (ports: 22, 8069, 8070, 8443, 8444, 3000)
                              |
                    🖥️ DIGITALOCEAN SERVER
                      (161.35.236.221)
                     /                  \
              Port 8443               Port 8444
                 🏢                      🏢
           Odoo 18 Stack            Odoo 19 Stack
           ┌─────────┐              ┌─────────┐
           │ nginx18 │              │ nginx19 │
           │ odoo18  │              │ odoo19  │
           └────┬────┘              └────┬────┘
                │                        │
                └──────────┬─────────────┘
                           │
                    🗄️ PostgreSQL 15
                    (shared database)
```

**Docker Networks:**
```
odoo18-network    → nginx18 ↔ odoo18 (private)
odoo19-network    → nginx19 ↔ odoo19 (private)
shared-db-network → odoo18 ↔ postgres ↔ odoo19 (shared)
```

---

## 📁 Project Structure

```
odoo-docker-multi-version/
│
├── 📄 Dockerfile.18              # Build recipe for Odoo 18 image
├── 📄 Dockerfile.19              # Build recipe for Odoo 19 image
├── 📄 deploy.sh                  # Auto-deployment script with rollback
├── 📄 docker-compose.ci.yml      # Docker Compose for CI/CD testing only
├── 📄 odoo-ci.conf               # Odoo config for CI/CD testing
├── 📄 .gitignore                 # Files never pushed to GitHub
├── 📄 .dockerignore              # Files excluded from Docker build
├── 📄 .pre-commit-config.yaml    # Code quality hooks
│
├── 📁 .github/
│   └── 📁 workflows/
│       └── 📄 docker-ci.yml      # GitHub Actions CI/CD pipeline
│
├── 📁 odoo18/                    # Everything for Odoo 18
│   ├── 📄 docker-compose.yml     # Runs odoo18 + nginx18 containers
│   ├── 📄 nginx.conf             # Nginx config with HTTPS
│   ├── 📄 odoo.conf              # Odoo 18 configuration
│   ├── 📄 .env                   # ⚠️ Passwords — NEVER in Git
│   ├── 📁 ssl/                   # ⚠️ SSL certificates — NEVER in Git
│   │   ├── odoo.crt
│   │   └── odoo.key
│   └── 📁 addons/                # ← PUT ODOO 18 MODULES HERE
│       └── your_module/
│
├── 📁 odoo19/                    # Everything for Odoo 19
│   ├── 📄 docker-compose.yml     # Runs odoo19 + nginx19 containers
│   ├── 📄 nginx.conf             # Nginx config with HTTPS
│   ├── 📄 odoo.conf              # Odoo 19 configuration
│   ├── 📄 .env                   # ⚠️ Passwords — NEVER in Git
│   ├── 📁 ssl/                   # ⚠️ SSL certificates — NEVER in Git
│   └── 📁 addons/                # ← PUT ODOO 19 MODULES HERE
│       └── your_module/
│
└── 📁 postgres/                  # Database configuration
    ├── 📄 docker-compose.yml     # Runs PostgreSQL container
    └── 📄 .env                   # ⚠️ DB passwords — NEVER in Git
```

---

## 🌐 Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| Odoo 18 | https://161.35.236.221:8443 | Ask your manager |
| Odoo 19 | https://161.35.236.221:8444 | Ask your manager |
| Grafana | http://161.35.236.221:3000 | Ask your manager |

> ⚠️ Browser will show "Not Secure" warning — this is normal for self-signed SSL. Click **Advanced → Proceed** to continue.

---

## 🚀 Getting Started — New Developer (First Day)

### Step 1 — Prerequisites

Make sure you have these installed on your computer:

```bash
# Check Git
git --version           # Need 2.x or higher

# Check Python
python3 --version       # Need 3.10 or higher

# Check Docker (optional for local development)
docker --version        # Need 20.x or higher
docker compose version  # Need 2.x or higher
```

If any are missing, install them from their official websites.

### Step 2 — Clone the Repository

```bash
git clone https://github.com/Rohan-P-22/odoo-docker-multi-version.git
cd odoo-docker-multi-version
```

### Step 3 — Set Up Pre-commit Hooks

Pre-commit hooks automatically check your code quality before every commit. This prevents bad code from entering the pipeline.

```bash
pip install pre-commit
pre-commit install
```

After this, every time you run `git commit`, your code is automatically checked for quality.

### Step 4 — Understand the Folder Structure

The most important thing to understand as a developer:

```
❓ Where do I put my Odoo module?

If your module is for Odoo 18 only:
→ odoo18/addons/your_module_name/

If your module is for Odoo 19 only:
→ odoo19/addons/your_module_name/

If your module works on BOTH Odoo 18 and 19:
→ odoo18/addons/your_module_name/   (copy here)
→ odoo19/addons/your_module_name/   (copy here too)
```

### Step 5 — Create Your Feature Branch

```bash
# Always create a branch for your work
# NEVER push directly to main or develop

git checkout -b feature/your-module-name

# Example:
git checkout -b feature/payment-gateway
git checkout -b feature/add-to-cart
git checkout -b feature/view-product
```

---

## 🌿 Branching Strategy

We follow a structured branching strategy to protect the live server:

```
main ──────────────────────────────── Production Server (LIVE)
  │
develop ───────────────────────────── Testing/Staging
  │
  ├── feature/payment-gateway ──────── Developer 1 working here
  ├── feature/add-to-cart ──────────── Developer 2 working here
  └── feature/view-product ─────────── Developer 3 working here
```

### Rules:

| Branch | Who pushes here | What happens |
|--------|----------------|--------------|
| `main` | Nobody directly — only via Pull Request | Deploys to production server |
| `develop` | Nobody directly — only via Pull Request | Testing environment |
| `feature/*` | Developers push their daily work here | Nothing automatic |
| `bugfix/*` | For fixing bugs | Nothing automatic |
| `hotfix/*` | For urgent production fixes | Review immediately |

### Daily Developer Workflow:

```bash
# 1. Start your day — get latest code
git checkout develop
git pull origin develop

# 2. Create your feature branch
git checkout -b feature/your-module-name

# 3. Write your code and commit regularly
git add .
git commit -m "feat: add payment gateway base structure"
git commit -m "feat: add payment gateway API integration"
git commit -m "fix: handle payment failure edge case"

# 4. Push your branch to GitHub
git push origin feature/your-module-name

# 5. Create Pull Request on GitHub
# Go to GitHub → Pull Requests → New Pull Request
# From: feature/your-module-name
# To: develop

# 6. Wait for review and CI/CD to pass
# 7. After approval, your code is merged
```

### Commit Message Format:

Always write clear commit messages so others understand your changes:

```
feat: add new feature
fix: fix a bug
docs: update documentation
refactor: restructure code without changing behavior
test: add tests
chore: update dependencies or configuration
```

---

## 📦 How to Create a Custom Module

### Odoo Module Structure

Every Odoo module must follow this structure:

```
your_module_name/
├── 📄 __init__.py           # Required — makes it a Python package
├── 📄 __manifest__.py       # Required — module information
├── 📁 models/               # Database models (tables)
│   ├── 📄 __init__.py
│   └── 📄 your_model.py
├── 📁 views/                # XML files for UI
│   └── 📄 your_view.xml
├── 📁 security/             # Access control
│   └── 📄 ir.model.access.csv
└── 📁 static/               # CSS, JS, images
    └── 📁 description/
        └── 📄 icon.png
```

### Minimal `__manifest__.py` Example:

```python
{
    'name': 'Payment Gateway',
    'version': '18.0.1.0.0',      # Format: odoo_version.module_version
    'category': 'Payment',
    'summary': 'Custom payment gateway integration',
    'description': 'Integrates custom payment gateway with Odoo',
    'author': 'Your Name',
    'depends': ['base', 'account'],  # Modules this depends on
    'data': [
        'security/ir.model.access.csv',
        'views/payment_view.xml',
    ],
    'installable': True,
    'auto_install': False,
}
```

### Minimal `__init__.py` Example:

```python
from . import models
```

### Where to Put Your Module:

```bash
# For Odoo 18 module
cp -r your_module_name/ odoo18/addons/

# For Odoo 19 module
cp -r your_module_name/ odoo19/addons/

# For both versions
cp -r your_module_name/ odoo18/addons/
cp -r your_module_name/ odoo19/addons/
```

### Verify Module is Correctly Placed:

```bash
# Your module should appear in this list
ls odoo18/addons/
ls odoo19/addons/
```

---

## 🔄 CI/CD Pipeline

Every time code is merged to `main` branch, the pipeline runs automatically in 4 stages:

```
Push to main
     │
     ▼
┌─────────────────────────────────────────────────────┐
│  STAGE 1: Lint & Code Quality (~32 seconds)         │
│                                                     │
│  Checks: flake8, black, isort, pylint-odoo          │
│  If FAILS → Pipeline stops, no deployment           │
│  If PASSES → Continue to Stage 2                    │
└─────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────┐
│  STAGE 2: Run Odoo (Docker Compose) (~1 minute)     │
│                                                     │
│  Starts temporary Odoo with test database           │
│  Verifies Odoo starts without errors                │
│  If FAILS → Pipeline stops, no deployment           │
│  If PASSES → Continue to Stage 3                    │
└─────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────┐
│  STAGE 3: Build & Push Docker Images (~1 minute)    │
│                                                     │
│  Builds: rohanp1722/odoo-multi-version:18-latest    │
│  Builds: rohanp1722/odoo-multi-version:18-1.0.XX    │
│  Builds: rohanp1722/odoo-multi-version:19-latest    │
│  Builds: rohanp1722/odoo-multi-version:19-1.0.XX    │
│  Pushes all to Docker Hub                           │
└─────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────┐
│  STAGE 4: Deploy to Server (~2 minutes)             │
│                                                     │
│  SSH into production server                         │
│  git pull → modules arrive on server                │
│  deploy.sh runs                                     │
│  Health checks verify deployment                    │
│  Auto-rollback if something fails                   │
└─────────────────────────────────────────────────────┘
```

### What Developers Need to Know About CI/CD:

**Pipeline runs on:** Every push to `main` or `develop` branch

**Pipeline does NOT run on:** Your `feature/*` branches

**If pipeline fails at Stage 1 (Lint):**
```bash
# Fix code quality issues locally
pip install flake8 black isort
flake8 your_file.py          # Check for errors
black your_file.py           # Auto-fix formatting
isort your_file.py           # Auto-fix import order
```

**If pipeline fails at Stage 2 (Odoo Test):**
- Your module has a Python error
- Check your `__manifest__.py` and `__init__.py`
- Make sure all dependencies listed in `depends` actually exist

**How to see pipeline status:**
Go to GitHub → Actions tab → Click on latest run

---

## 🚚 How Modules Reach the Server

This is the most important concept to understand:

```
Step 1: You push code to GitHub
        Your module is now in GitHub repository

Step 2: CI/CD pipeline triggers (Stage 4)
        Pipeline SSHs into server
        Runs: git pull origin main
        ↓
        Your module files physically arrive on server:
        /opt/odoo-docker/odoo18/addons/your_module/
        /opt/odoo-docker/odoo19/addons/your_module/

Step 3: deploy.sh restarts containers
        New Odoo container starts
        Docker mounts the addons folder:
        odoo18/addons/ → /mnt/extra-addons inside container
        ↓
        Odoo can now see your module!

Step 4: Admin installs module in Odoo
        Go to Apps → Search your module → Install
        Module is now active for clients!
```

### Why Modules Are NOT Inside Docker Image:

```
Docker Image = Odoo application (changes rarely)
Modules = Business logic (changes often)

If modules were inside image:
Every small module change → rebuild entire image → 10+ minutes

Keeping separate:
Module change → just git pull → 10 seconds!
Much faster and more efficient.
```

---

## 💻 Local Development Setup

To test your module locally before pushing to GitHub:

### Option 1 — Quick Local Test with Docker

```bash
# Clone the repo
git clone https://github.com/Rohan-P-22/odoo-docker-multi-version.git
cd odoo-docker-multi-version

# Create local .env file for testing
cat > odoo18/.env << 'EOF'
ODOO_ADMIN_PASSWD=admin
DB_HOST=postgres
DB_PORT=5432
DB_USER=odoo
DB_PASSWORD=odoo
EOF

# Create local postgres .env
cat > postgres/.env << 'EOF'
POSTGRES_USER=odoo
POSTGRES_PASSWORD=odoo
EOF

# Start postgres first
cd postgres
docker compose up -d
cd ..

# Start odoo18 locally (uses official image for local dev)
cd odoo18
docker compose up
# Odoo will be available at http://localhost:8069
```

### Option 2 — Odoo Community Local Install

For faster development, install Odoo directly on your machine:

```bash
# Install Odoo 18 community edition
# Follow: https://www.odoo.com/documentation/18.0/administration/install/install.html

# Put your module in Odoo addons path
# Then update module list and install from Apps menu
```

### Testing Your Module Locally:

```bash
# After making changes to your module
# Restart Odoo with module update flag
docker compose restart odoo18

# Or update specific module
docker exec odoo18 odoo -u your_module_name -d your_database --stop-after-init
```

---

## 🔒 Security

### What Developers MUST Know:

**Never commit these files to GitHub:**
```
.env files          → Contains passwords
ssl/ folders        → Contains private keys
*.key files         → Private keys
*.pem files         → Certificates
```

These are already in `.gitignore` — but always double-check before pushing!

**Never hardcode passwords in code:**
```python
# ❌ WRONG
password = "mypassword123"
api_key = "sk-abc123xyz"

# ✅ CORRECT
import os
password = os.environ.get('MY_PASSWORD')
api_key = os.environ.get('API_KEY')
```

**Never push directly to main:**
```bash
# ❌ WRONG
git push origin main

# ✅ CORRECT
git push origin feature/your-branch-name
# Then create Pull Request on GitHub
```

### Password Management:

All passwords are stored in `.env` files on the server only. To get database or admin passwords, ask the DevOps engineer (Rohan). Never share passwords over chat or email — use a password manager.

---

## 📊 Monitoring

The system is fully monitored. As a developer, here's what you need to know:

| Tool | URL | Purpose |
|------|-----|---------|
| Grafana | http://161.35.236.221:3000 | Visual dashboards — CPU, memory, requests |
| Prometheus | Internal only | Metrics collection |
| Telegram | Ask Rohan to add you | Instant alerts on your phone |

### What Alerts You Might Receive:

```
🔴 Odoo18 container is unhealthy
   → Your recent deployment may have broken something
   → Check: docker logs odoo18 --tail 50

⚠️ High memory usage on server
   → Too many containers or memory leak
   → Check: docker stats

✅ Deployment #46 successful
   → Your code is live!
```

---

## 🔧 Troubleshooting

### Check System Status

```bash
# SSH into server
ssh root@161.35.236.221

# Check all containers
docker ps

# Check specific container logs
docker logs odoo18 --tail 50
docker logs odoo19 --tail 50
docker logs nginx18 --tail 50
docker logs postgres --tail 50

# Check container health
docker inspect --format='{{.State.Health.Status}}' odoo18
docker inspect --format='{{.State.Health.Status}}' odoo19

# Check firewall
ufw status

# Check disk space
df -h

# Check memory
free -h
```

### Restart Services

```bash
# Restart specific container
cd /opt/odoo-docker/odoo18
docker compose restart odoo18

# Restart entire odoo18 stack
docker compose down && docker compose up -d

# Restart entire odoo19 stack
cd /opt/odoo-docker/odoo19
docker compose down && docker compose up -d
```

---

## ❌ Common Errors & Fixes

### Error 1 — Module Not Appearing in Odoo Apps

```
Problem: I pushed my module but it doesn't show in Odoo Apps menu

Cause 1: Module in wrong folder
Fix: Make sure module is in odoo18/addons/ or odoo19/addons/
     NOT in odoo18/ directly

Cause 2: Missing __manifest__.py
Fix: Create __manifest__.py in your module root folder

Cause 3: installable = False in manifest
Fix: Set 'installable': True in __manifest__.py

Cause 4: Odoo module list not updated
Fix: Go to Apps → click "Update Apps List" button
```

### Error 2 — CI/CD Pipeline Fails at Lint Stage

```
Problem: Pipeline shows red X at "Lint & Code Quality"

Fix: Run these locally to check and fix:
pip install flake8 black isort
flake8 odoo18/addons/your_module/
black odoo18/addons/your_module/
isort odoo18/addons/your_module/

Common issues:
- Line too long (max 88 characters)
- Unused imports
- Wrong import order
- Missing spaces around operators
```

### Error 3 — Odoo Can't Connect to Database

```
Problem: Odoo logs show "password authentication failed"

This means the database password changed
Contact DevOps engineer (Rohan)
DO NOT try to fix this yourself
```

### Error 4 — 500 Internal Server Error in Browser

```
Problem: Browser shows "500 Internal Server Error"

Step 1: Check logs
docker logs odoo18 --tail 100 | grep ERROR

Step 2: Common causes:
- Python syntax error in your module
- Missing dependency in __manifest__.py depends list
- Database column missing (need module update)

Step 3: Update module
docker exec odoo18 odoo -u your_module_name -d database_name --stop-after-init
```

### Error 5 — Git Push Rejected

```
Problem: git push origin main rejected

Cause: main branch is protected — direct push not allowed
Fix: Push to your feature branch instead
     git push origin feature/your-branch-name
     Then create Pull Request on GitHub
```

### Error 6 — Pre-commit Hook Fails

```
Problem: git commit shows errors from pre-commit

This is GOOD — it caught problems before they enter the pipeline

Fix: Read the error message carefully
     It tells you exactly what file and line has the problem
     Fix the issue, then commit again
```

### Error 7 — Module Works on Odoo18 but Not Odoo19

```
Problem: Module installs fine on Odoo18 but fails on Odoo19

Cause: API differences between Odoo 18 and 19
       Some functions work differently between versions

Fix: Check Odoo 19 migration guide
     https://www.odoo.com/documentation/19.0/developer/howtos/upgrade_modules.html

     Or maintain separate module versions:
     odoo18/addons/your_module/ → Odoo 18 compatible code
     odoo19/addons/your_module/ → Odoo 19 compatible code
```

---

## 📏 Important Rules

### For All Developers:

```
1. ✅ ALWAYS create a feature branch before working
2. ✅ ALWAYS write clear commit messages
3. ✅ ALWAYS test your module locally before pushing
4. ✅ ALWAYS put modules in correct addons folder
5. ✅ ALWAYS include __manifest__.py and __init__.py
6. ✅ ALWAYS wait for CI/CD to pass before asking for review

7. ❌ NEVER push directly to main branch
8. ❌ NEVER commit .env files or passwords
9. ❌ NEVER hardcode passwords in code
10. ❌ NEVER modify server files directly without DevOps approval
11. ❌ NEVER share server passwords over chat or email
12. ❌ NEVER delete Docker volumes (all data will be lost!)
```

### Module Naming Convention:

```
✅ Good module names:
payment_gateway
add_to_cart
view_product
custom_invoice_report

❌ Bad module names:
PaymentGateway          (no capital letters)
payment-gateway         (no hyphens)
my module               (no spaces)
test                    (too generic)
```

### Database Naming Convention:

```
Odoo 18 databases must start with: odoo18_
odoo18_company
odoo18_dev
odoo18_test
odoo18_training

Odoo 19 databases must start with: odoo19_
odoo19_company
odoo19_dev
odoo19_test
odoo19_training
```

---

## 📞 Contact & Support

| Role | Name | Responsibility |
|------|------|----------------|
| DevOps Engineer | Rohan | Server, CI/CD, infrastructure |
| Manager | Your Manager | Code review, approvals |

**For server issues:** Contact Rohan immediately

**For code review:** Create Pull Request on GitHub

**For urgent production issues:** Contact Rohan on Telegram

---

## 📚 Useful Resources

- [Odoo 18 Developer Documentation](https://www.odoo.com/documentation/18.0/developer.html)
- [Odoo 19 Developer Documentation](https://www.odoo.com/documentation/19.0/developer.html)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Odoo Module Development Tutorial](https://www.odoo.com/documentation/18.0/developer/tutorials/server_framework_101.html)

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | March 2026 | Initial setup — Odoo 18 + 19 with Docker |
| 1.1.0 | March 2026 | Added HTTPS, .env files, firewall |
| 1.2.0 | March 2026 | Fixed Dockerfile, deploy.sh rollback |
| 1.3.0 | March 2026 | Added version tags, CI/CD improvements |

---

*Built with ❤️ by Rohan | DevOps Engineer*
*Last Updated: March 2026*
# koderxpert-docker
