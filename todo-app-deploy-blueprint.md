# To-do / Calendar App — Deployment + Hermes MCP Integration Blueprint

Target machine: **blackhawk** (NixOS, user `sam`, org **xl / lauzon**). The flagship
reference is the **solutions** app under `/home/sam/src/lumae/solutions` (lumae org).
This blueprint mirrors that app's exact containerization + OIDC + Hermes-MCP patterns.

Two orgs are in play (do not mix): `*.lauzon.xyz` (Xavier's xl org — modpack-hub,
komodo, auth) and `*.lumae.net` (the solutions org). Pick ONE domain namespace for
the new app and keep every URL in it. The examples below use the **lauzon** namespace
(blackhawk + sam are xl org) with `TODODOMAIN` as a placeholder; swap to `lumae.net`
if the app is a lumae app.

---

## 1. Repo layout

Follow the solutions repo layout exactly (`/home/sam/src/lumae/solutions`):

```
/home/sam/src/<org>/<app>/          # e.g. /home/sam/src/lauzon/todo
├── compose.yaml                    # local compose mirror of the Komodo stack
├── Dockerfile                      # multi-stage node:22-slim build+runtime
├── package.json                    # svelte-kit + drizzle + pg + jose
├── drizzle.config.ts
├── drizzle/                        # committed migrations (git-tracked)
│   ├── 0000_*.sql
│   └── meta/_journal.json
├── scripts/seed.ts                 # `npm run db:seed` (--experimental-strip-types)
├── .env                            # local dev env (gitignored)
├── .env.example
├── komodo/<app>.yaml               # the Komodo stack definition (git-tracked)
└── src/lib/server/
    ├── config.ts                   # .env loader + central config (OIDC/DATABASE_URL)
    ├── oidc.ts                     # auth-code + PKCE flow, jose id_token verify
    ├── session-cookie.ts           # HMAC-signed session cookie
    └── db/{index.ts, schema.ts, seed.ts}
```

The only new addition vs solutions is a **host-path bind mount** so the container can
write a todo file (see §2). solutions/modpack-hub both demonstrate the mount pattern.

---

## 2. Containerization — `compose.yaml` (local mirror)

Copy the structure of `/home/sam/src/lumae/solutions/compose.yaml`. Key points:
- App service built from the repo Dockerfile (`build: .`), published to the host.
- Postgres sibling `docker.io/nfrastack/postgres:18`, `DATABASE_URL` wired.
- `depends_on: <app>-db: condition: service_healthy`.
- Healthchecks on both (app: `fetch('http://127.0.0.1:3000/api/health')`).

The **bind-mount** for the todo file (add to the app service). modpack-hub's
Komodo stack uses `${DATADIR}/data:/app/data` (`/home/sam/src/modpack-hub/komodo/modpacks-lauzon-xyz.yaml`
line 23) as its precedent. Mirror that with a host directory:

```yaml
services:
  <app>:
    build:
      context: .
    container_name: <app>
    environment:
      PUBLIC_URL: ${PUBLIC_URL:-http://localhost:5173}
      OIDC_ISSUER: ${OIDC_ISSUER:-https://auth.lauzon.xyz/}
      OIDC_CLIENT_ID: ${OIDC_CLIENT_ID:-}
      OIDC_CLIENT_SECRET: ${OIDC_CLIENT_SECRET:-}
      OIDC_REDIRECT_URI: ${OIDC_REDIRECT_URI:-http://localhost:5173/api/auth/callback}
      SESSION_SECRET: ${SESSION_SECRET:-}
      ADMIN_GROUPS: ${ADMIN_GROUPS:-app-<app>-admin}
      ADMIN_EMAILS: ${ADMIN_EMAILS:-}
      UNDER_DEVELOPMENT: ${UNDER_DEVELOPMENT:-false}
      DATABASE_URL: postgres://${DB_USER:-<app>}:${DB_PASS:-localdbpass}@<app>-db:5432/${DB_NAME:-<app>}
      # DMS todo file lives on the host — bind-mount the directory (read/write).
      TODO_DATA_DIR: /app/todo-data
    volumes:
      # Host path → container: lets the container write the DMS todo file.
      - ${TODO_DATA_DIR:-/home/sam/src/<org>/<app>/data/todo}:/app/todo-data
    ports:
      - "${APP_PORT:-5173}:3000"
    depends_on:
      <app>-db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "node", "-e", "fetch('http://127.0.0.1:3000/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 15s
    networks: [<app>-net]
    restart: unless-stopped

  <app>-db:
    image: docker.io/nfrastack/postgres:18
    container_name: <app>-db
    environment:
      - TIMEZONE=${TIMEZONE:-America/Toronto}
      - SUPERUSER_PASS=${DB_ROOT_PASS:-localrootpass}
      - DB_NAME=${DB_NAME:-<app>}
      - DB_USER=${DB_USER:-<app>}
      - DB_PASS=${DB_PASS:-localdbpass}
    volumes:
      - <app>-pg-data:/data
    ports:
      - "${DB_PORT:-5432}:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \"$$DB_USER\" -d \"$$DB_NAME\" || exit 1"]
      interval: 5s
      timeout: 5s
      retries: 10
      start_period: 10s
    networks: [<app>-net]
    restart: unless-stopped

volumes:
  <app>-pg-data:
networks:
  <app>-net:
    driver: bridge
```

**DMS todo file note:** `TODO_DATA_DIR` is a new env the app reads; the bind mount
`${TODO_DATA_DIR}:/app/todo-data` is what lets the container write it. Change the
env name to whatever your app uses (`DATA_DIR`, `TODOS_PATH`, etc.) and the host
path to wherever you want the file persisted. Make the host dir exist and be
writable, e.g. `mkdir -p /home/sam/src/<org>/<app>/data/todo`.

Usage:
```sh
docker compose up -d --build     # build + start
docker compose down -v           # stop + wipe DB volume
```
Stop the vite dev server on :5173 first, or set `APP_PORT`.

---

## 3. Dockerfile

Copy `/home/sam/src/lumae/solutions/Dockerfile` (identical shape for any SvelteKit
adapter-node app):

```dockerfile
FROM node:22-slim AS build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --no-audit --no-fund
COPY . .
RUN npm run build

FROM node:22-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json* ./
RUN npm install --omit=dev --no-audit --no-fund
COPY --from=build /app/build ./build
COPY --from=build /app/drizzle ./drizzle      # migrations ship with the image
ENV PORT=3000
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:3000/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node", "build"]
```

---

## 4. Komodo stack — `komodo/<app>.yaml`

Copy `/home/sam/src/lumae/solutions/komodo/solutions-lumae-net.yaml`. The reverse
proxy is **Traefik** (per-`Host(...)` labels) with **Herald** service discovery
(`nfrastack.herald.enable=true`); OIDC is **LemonLDAP::NG** at `auth.lauzon.xyz`
(solutions uses `auth.lumae.net`). External networks `proxy` + `proxy-internal`
already exist (declared `external: true`).

```yaml
# <App> — Komodo stack
services:
  <app>:
    image: git.lauzon.xyz/sam/container-<app>:latest   # push first
    container_name: <app>
    labels:
      - nfrastack.herald.enable=true
      - traefik.enable=true
      - traefik.http.routers.<app>.rule=Host(`<app>.lauzon.xyz`)
      - traefik.http.routers.<app>.service=<app>
      - traefik.http.services.<app>.loadbalancer.server.port=3000
      - traefik.proxy.visibility=internal            # solutions; modpacks uses `any`
      - nfrastack.dns.enable=true
    volumes:
      - ${DATADIR}/data:/app/todo-data                # bind-mount todo file (host path)
    environment:
      - PUBLIC_URL=https://<app>.lauzon.xyz
      - OIDC_ISSUER=https://auth.lauzon.xyz/
      - OIDC_CLIENT_ID=${OIDC_CLIENT_ID}
      - OIDC_CLIENT_SECRET=${OIDC_CLIENT_SECRET}
      - OIDC_REDIRECT_URI=https://<app>.lauzon.xyz/api/auth/callback
      - SESSION_SECRET=${SESSION_SECRET}
      - ADMIN_GROUPS=${ADMIN_GROUPS}
      - ALLOWED_GROUPS=${ALLOWED_GROUPS}
      - DATABASE_URL=postgres://<app>:${DB_PASS}@<app>-db:5432/<app>
      - TODO_DATA_DIR=/app/todo-data
    networks: [proxy, proxy-internal]
    restart: unless-stopped

  <app>-db:
    container_name: <app>-db
    image: docker.io/nfrastack/postgres:18
    volumes:
      - ${DBDIR}/postgres:/data
      - ${DATADIR}/logs:/logs
    environment:
      - TIMEZONE=America/Toronto
      - CONTAINER_NAME=<app>-db-backup
      - CONTAINER_ENABLE_MONITORING=FALSE
      - CONTAINER_ENABLE_LOGSHIPPING=FALSE
      - SUPERUSER_PASS=${DB_ROOT_PASS}
      - DB_NAME=<app>
      - DB_USER=<app>
      - DB_PASS=${DB_PASS}
    networks: [services]
    restart: unless-stopped

networks:
  services:
    external: false
  proxy-internal:
    external: true
  proxy:
    external: true
```

**Push the image first** (see the comments at the bottom of
`/home/sam/src/modpack-hub/komodo/modpacks-lauzon-xyz.yaml` lines 52-55):
```sh
docker build -t git.lauzon.xyz/sam/container-<app>:latest .
docker push git.lauzon.xyz/sam/container-<app>:latest
```
Komodo variables to set for the stack: `SESSION_SECRET`, `OIDC_CLIENT_ID`,
`OIDC_CLIENT_SECRET`, `ADMIN_GROUPS`, `ALLOWED_GROUPS`, plus `DATADIR`/`DBDIR`
(shared across stacks). Register the same LDAP **redirect URI** in LemonLDAP
(`https://<app>.lauzon.xyz/api/auth/callback`) as the solutions README notes.

---

## 5. OIDC / auth wiring (reuse verbatim)

Copy these files from solutions, changing only the cookie name / defaults:

- **`src/lib/server/config.ts`** — minimal `.env` loader, `PUBLIC_URL`,
  `OIDC_ISSUER` (trailing-slash-normalised), `OIDC_CLIENT_ID/SECRET`,
  `SESSION_SECRET`, `ADMIN_GROUPS`/`ADMIN_EMAILS`, `DATABASE_URL`, `devMode`.
  **Fail-closed guard** (lines ~66-72): refuses to start in devMode behind a public
  `https://` URL. **`SESSION_SECRET` required once `OIDC_CLIENT_ID` is set.**
- **`src/lib/server/oidc.ts`** — discovery cache (15 min), PKCE auth-code flow,
  `exchangeCode` (jose `jwtVerify` id_token against the IdP JWKS), `parseGroups`
  (LemonLDAP returns group as string-or-array), `decideAccess` (admin-only policy),
  `endSessionUrl`.
- **`src/lib/server/session-cookie.ts`** — HMAC-SHA256-signed httpOnly cookie
  `<payload>.<mac>`, 12h TTL, `secure` only in production.
- **Routes** (`src/routes/api/auth/{login,callback,logout,me}/+server.ts`).
  Register the same redirect URI in the IdP.

The OIDC flow and env-variable contract are fully documented in the solutions
`config.ts`/`oidc.ts` comments and `.env` — reuse them unchanged.

---

## 6. Data layer (drizzle + postgres)

Copy `/home/sam/src/lumae/solutions/src/lib/server/db/` and `drizzle.config.ts`.
- `schema.ts` — `pgTable` definitions, `$inferSelect`/`$inferInsert` types.
- `drizzle.config.ts` — `dialect: 'postgresql'`, schema + out `./drizzle`,
  `url: process.env.DATABASE_URL ?? ''`.
- `db/index.ts` — `Pool` + `drizzle(node-postgres)`, `migrate(..., {migrationsFolder:'drizzle'})`
  on boot, then `seedIfEmpty`; **fallback mode** if no `DATABASE_URL` (never throws).
- `scripts/seed.ts` — standalone seed runner.
- Migrations: `npm run db:generate` (drizzle-kit) → commit the `.sql` under `drizzle/`
  → they're copied into the image and auto-applied on boot. No `db:push` in prod;
  migrations are the source of truth.

`package.json` scripts to mirror:
```json
"db:generate": "drizzle-kit generate",
"db:push": "drizzle-kit push",
"db:seed": "node --experimental-strip-types scripts/seed.ts"
```
Deps: `drizzle-orm@^0.45.3`, `pg@^8.16.0`, `jose@^6.2.12` (+ `@sveltejs/adapter-node`).

---

## 7. Register a NEW stdio MCP server for Hermes

Hermes discovers MCP servers from the **`mcp_servers`** section of its config.yaml
(confirmed in the live config at `/home/sam/.hermes/config.yaml`, which is a
symlink into the nix store). Each entry is a **stdio** server declared with
`command:` + optional `env:`/`args:`. There is no separate "mcp" section for Hermes —
it's `mcp_servers` (unlike opencode's `programs.mcp`).

### Where to edit — the Nix source that generates config.yaml

The `config.yaml` symlink `~/.hermes/config.yaml → /nix/store/.../.hermes/config.yaml`
is generated by **`/home/sam/src/home-manager/home/xl/hostname/blackhawk/sam.nix`**.
`mcp_servers` is declared at **lines 81-90** inside the
`home.file."~/.hermes/config.yaml"` block (lines 57-91).

Current content (lines 81-90):
```nix
mcp_servers:
  # Shared knowledge-graph memory (same JSONL file as OpenCode, git-versioned).
  memory:
    command: "${pkgs.mcp-server-memory}/bin/mcp-server-memory"
    env:
      MEMORY_FILE_PATH: "${config.home.homeDirectory}/src/kb/memory.jsonl"
  # Real NixOS / Home Manager / nix docs lookup.
  nixos:
    command: "${pkgs.mcp-nixos}/bin/mcp-nixos"
```

### Exact change

Add an entry to `mcp_servers` in `sam.nix` (after line 90). The runtime uses
**Python mcp (FastMCP)** — `mcp.server.MCPServer` is aliased to `FastMCP` by the
sitecustomize shim in `/home/sam/src/home-manager/modules/applications/cli/hermes-agent.nix`
**lines 61-84**. So the natural fit is a **Python FastMCP server** over stdio
(not the TypeScript mcp-komodo pattern). Two steps:

**(a) Package the server** in the home-manager pkgs dir
(`/home/sam/src/home-manager/pkgs/<todo-mcp>/default.nix`), registering it in
`/home/sam/src/home-manager/pkgs/default.nix` (which currently lists `firecrawl-mcp`
and `komodo-mcp-server` at lines 3-4). Mirror the **local-path source** pattern of
`/home/sam/src/home-manager/pkgs/komodo-mcp-server/default.nix` (lines 6-20): a
`buildNpmPackage`/`buildPythonApplication` (use `buildPythonApplication` + a
`pyproject.toml`/uv for a Python FastMCP server) with
`src = lib.cleanSourceWith { src = /home/sam/src/misc/mcp/<todo-mcp>; filter = ...; }`.

The Hermes MCP entrypoint runs `hermes mcp serve` via the `hermes-mcp` wrapper
(`hermes-agent.nix` lines 13-16), which sets `PYTHONPATH` for the shim — so a Python
FastMCP server run over stdio is the correct transport.

**(b) Register it** in `sam.nix`'s `mcp_servers`:
```nix
# To-do / calendar API.
todo:
  command: "${pkgs.<todo-mcp>}/bin/<todo-mcp>"
  env:
    TODO_API_URL: "https://<app>.lauzon.xyz"
    TODO_API_TOKEN: "${...}"   # or read from a sops-encrypted env file
```
Pass the API token via a **sops** secret (never inline the plaintext). The
secret-declaration pattern is in
`/home/sam/src/home-manager/home/common/user/sam/secrets/komodo/default.nix`
(`mcpEnv` → `~/.config/komodo/mcp.env`, lines 34-42) and
`/home/sam/src/home-manager/home/common/user/sam/secrets/hermes/default.nix`
(`~/.hermes/.env`). Add an equivalent sops secret and have the wrapper source it
(see the `komodoMcpWrapper` shell wrapper at `sam.nix` lines 8-15 which sources
`~/.config/komodo/mcp.env` before exec).

### Rebuild + switch
```sh
alejandra .
nix flake check .#homeConfigurations.blackhawk.sam.config   # validate, never switch unchecked
home-manager build --flake .#blackhawk.sam
home-manager switch --flake .#blackhawk.sam                 # only after build passes
```
After switch, `~/.hermes/config.yaml` regenerates with the new `todo` server and
Hermes picks it up on its next MCP startup (restart the `hermes-gateway` systemd
user service if needed).

---

## 8. Reverse proxy / domain conventions (summary)

- **Reverse proxy:** Traefik, configured per-service via `traefik.http.routers.<r>.rule=Host(...)`
  labels on the Komodo stack; services attach to the external `proxy`/`proxy-internal`
  networks. **Herald** (`nfrastack.herald.enable=true`) handles discovery/DNS.
- **OIDC:** LemonLDAP::NG. `https://auth.lauzon.xyz/` (xl org) or `https://auth.lumae.net/`
  (solutions). Redirect URI must be registered in the IdP for the client.
- **Domains seen in use:** `*.lauzon.xyz` — `git.lauzon.xyz` (forgejo), `auth.lauzon.xyz`
  (OIDC), `komodo.lauzon.xyz`/`k.lauzon.xyz` (Komodo), `ai.lauzon.xyz` (OpenAI-compat
  gateway), `crawl.lauzon.xyz` (firecrawl), `modpacks.lauzon.xyz` (modpack-hub).
  `*.lumae.net` — `auth.lumae.net`, `solutions.lumae.net`, `git.lumae.net`
  (`git.lumae.net/samuelpizette/solutions-lumae-net`).
- **Local dev:** SvelteKit dev server / compose mirror published to `http://localhost:5173`.
- **Image registry:** `git.lumae.net/samuelpizette/<image>` or
  `git.lauzon.xyz/sam/container-<name>`; push before the Komodo stack deploy.
- **Komodo Core:** `https://komodo.lauzon.xyz` (from `komodo.cli.toml.example`).

---

## 9. Checklist

- [ ] New repo under `/home/sam/src/<org>/<app>/` mirroring solutions layout
- [ ] `compose.yaml` with app + postgres sibling, healthchecks, `depends_on: healthy`
- [ ] Bind-mount for the DMS todo file (`${TODO_DATA_DIR}:/app/todo-data`), host dir created & writable
- [ ] Multi-stage `Dockerfile`; drizzle migrations copied in and auto-applied on boot
- [ ] `komodo/<app>.yaml` with Traefik + Herald labels, OIDC env, proxy networks
- [ ] Image pushed to the registry; Komodo variables + LDAP redirect registered
- [ ] OIDC files copied from solutions (config/oidc/session-cookie/auth routes)
- [ ] Python FastMCP server at `/home/sam/src/misc/mcp/<todo-mcp>`, packaged under `pkgs/`
- [ ] New `todo` entry in `mcp_servers` in `home/xl/hostname/blackhawk/sam.nix` (after line 90)
- [ ] API token via a sops secret, never inline
- [ ] `alejandra .`, `nix flake check`, `build`, then `switch`

## Files to edit (exact paths)

| Purpose | Path |
|---|---|
| Hermes MCP registration | `/home/sam/src/home-manager/home/xl/hostname/blackhawk/sam.nix` (mcp_servers, lines 81-90) |
| Hermes MCP shim (why Python/FastMCP) | `/home/sam/src/home-manager/modules/applications/cli/hermes-agent.nix` (lines 61-84) |
| Package the server | `/home/sam/src/home-manager/pkgs/<todo-mcp>/default.nix` + register in `pkgs/default.nix` |
| Secret (API token) | `/home/sam/src/home-manager/home/common/user/sam/secrets/<todo>/default.nix` |
| Komodo stack | `/home/sam/src/<org>/<app>/komodo/<app>.yaml` |
| Local compose mirror | `/home/sam/src/<org>/<app>/compose.yaml` |
