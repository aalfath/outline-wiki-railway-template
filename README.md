# Outline on Railway

A one-click Railway template for [Outline](https://github.com/outline/outline), the open-source team wiki and knowledge base.

**Version:** Outline 1.13.0 (`outlinewiki/outline:1.13.0@sha256:4583bb244dbb4464d8a632c75044d3b2f9fe44382b6a4b84d97995f473b823e4`)

## What it deploys

| Service | Source | Notes |
|---|---|---|
| Outline | this repo (`Dockerfile`, `start.sh`) | Public HTTPS domain, health check `/_health`, volume at `/var/lib/outline/data` for uploads |
| Postgres | Railway Postgres | Documents, users and settings |
| Redis | Railway Redis | Cache, queues and real-time collaboration |

The wrapper pins the official image, fixes the volume's ownership at start and then runs Outline as the image's unprivileged `nodejs` user. Database migrations run automatically on every start.

## Variables

| Variable | Value in the template | Purpose |
|---|---|---|
| `URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public address of the wiki |
| `SECRET_KEY` | `${{secret(64,"abcdef0123456789")}}` | Session and encryption key, generated per deploy |
| `UTILS_SECRET` | `${{secret(64,"abcdef0123456789")}}` | Key for internal utility endpoints, generated per deploy |
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Private-network Postgres connection |
| `REDIS_URL` | `${{Redis.REDIS_URL}}?family=6` | Private-network Redis connection (IPv6) |
| `PORT` | `3000` | Port Outline listens on |

Set in `start.sh` (override them with a variable if you need to): `FILE_STORAGE=local`, `FILE_STORAGE_LOCAL_ROOT_DIR=/var/lib/outline/data`, `PGSSLMODE=disable`, `FORCE_HTTPS=false` (Railway already serves HTTPS), `WEB_CONCURRENCY=1`.

## First sign-in

Open the public URL right after the deploy finishes. Outline shows a setup screen that creates your workspace and its first admin account and signs you in. No identity provider or mail server is needed for this step. Do it straight away: until the first workspace exists, anyone who opens the URL could create it.

Then add a passkey under **Settings → Account → Passkeys**, so you can sign in again later. To invite teammates, add an email server (`SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_FROM_EMAIL`) for magic-link sign-in, or a single sign-on provider (`OIDC_*`, `GOOGLE_*`, `SLACK_*`, `AZURE_*`, `DISCORD_*`, `GITHUB_*`). See [Outline's authentication docs](https://docs.getoutline.com/s/hosting/doc/authentication-7ViKRmRY5o).

## Updates

The Outline service builds from this repo's `main` branch. When a new Outline version is pinned here and merged to `main`, Railway shows "update available" to everyone who deployed the template, and each deployer chooses when to apply it. Read [CHANGELOG.md](CHANGELOG.md) before you apply an update.

## License

The wrapper files in this repo are MIT. Outline itself is licensed under the [Business Source License 1.1](https://github.com/outline/outline/blob/main/LICENSE), which allows self-hosting for your own use but not offering Outline as a commercial document service.
