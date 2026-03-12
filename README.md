# pidupall-prod-infra

Production infrastructure for the pidupall project. Next.js app running in Docker, served over HTTPS via Caddy, deployed automatically to a VPS on every push to `main` using GitHub Actions.

## How it works

```
Push to main
     │
     ▼
GitHub Actions
  ├── Build multi-stage Docker image
  ├── Push to GHCR (tagged: latest, git SHA, timestamp)
  └── SSH into server → pull new image → docker compose up
           │
           ▼
        [ Caddy ] — TLS (auto Let's Encrypt), www redirect, security headers
           │
           ▼
        [ Next.js app ] — standalone build, non-root user, port 3000
```

## Files

- `Dockerfile` — multi-stage build: Node 24 Alpine builder → minimal runner, non-root `nextjs` user
- `docker-compose.yml` — app service, image tag injected via env vars, connected to external `monitoring` network
- `Caddyfile` — HTTPS termination, www → apex redirect, HSTS + security headers, `/healthz` endpoint
- `deploy.yml` — GitHub Actions workflow: build → push to GHCR → SSH deploy

## CI/CD setup

You'll need these **secrets** in your GitHub repo:

| Secret | What it is |
|---|---|
| `DEPLOY_HOST` | Server IP |
| `DEPLOY_KEY` | SSH private key |
| `DEPLOY_PORT` | SSH port (22 if standard) |
| `DEPLOY_USER` | Deploy user on the server |
| `GHCR_USER` | Your GitHub username |
| `GHCR_TOKEN` | Personal access token for GHCR |

And these **variables**:

| Variable | Example |
|---|---|
| `DEPLOY_PATH` | `/home/deploy/pidupall` |
| `IMAGE_NAME` | `ghcr.io/yourusername/pidupall` |

## Server setup

```bash
# Create a dedicated deploy user
sudo adduser deploy
sudo usermod -aG docker deploy

# Add your public SSH key
echo "your-public-key" >> /home/deploy/.ssh/authorized_keys

# Disable password auth
# /etc/ssh/sshd_config → PubkeyAuthentication yes, PasswordAuthentication no
```

Caddy runs separately and proxies to the app container. If you're already running Caddy, just append the config from `Caddyfile` to your existing one.

## Running locally (no CI/CD)

```bash
docker build -t pidupall .
docker run -d -p 3000:3000 pidupall
# open localhost:3000
```

## Stack

Next.js · Docker · GitHub Actions · GHCR · Caddy · Let's Encrypt
