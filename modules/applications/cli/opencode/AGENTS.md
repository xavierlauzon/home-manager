# AGENTS.md — Global rules for this machine (Xavier's workstation)

System-wide instructions for every agent session. Project-specific rules live
in each repo's own `AGENTS.md`; this file only holds cross-project rules.

## 1. Environment (NixOS)

- This is a **NixOS / home-manager** machine. `nix` flakes and `nix-command`
  are enabled.
- **`node`, `npm`, `bun` are NOT on PATH globally.** For any node tooling run:
  `nix shell nixpkgs#nodejs_22 --command <cmd> ...`
- `opencode` CLI is installed as **`opencode2`** (v2.1.0), not `opencode`.
- `alejandra` is the nix formatter. Use it before committing nix files.

## 2. Agents & providers

- Default provider: **Lauzon AI** (`ai-lauzon-xyz`), default model
  `deepseek-v4-flash`. Config is nix-managed under `~/.config/opencode/`
  (`opencode.json`, `oh-my-opencode-slim.json` are symlinks into the store).
- MCP servers available: `firecrawl`, `hermes` (`hermes-mcp`), `komodo`,
  `playwright`, `memory`, `nixos`. See `~/.config/opencode/opencode.json`.

## 3. Secrets

- Machine secrets are **sops-nix + age**, under `~/src/home-manager/home/*/secrets/**`.
- **Never read, decrypt, or commit secret files.** Never type a password, API
  key, token, or credential into a command or a file. If a task needs a secret,
  use the sops-managed reference (e.g. `config.sops.secrets.*`), not a plaintext
  value you found in the tree.

## 4. Persistent memory (opencode-codex-memory)

- OpenCode has **persistent cross-session memory** via the `opencode-codex-memory`
  plugin (markdown + SQLite under `~/.local/share/opencode/`). It is **global
  across projects** — general preferences follow you into any repo, while
  project-specific facts carry their repo context.
- The agent should treat the injected `[MEMORY]`/memory context as ground truth
  for past decisions and conventions, and can use the memory tools to recall,
  save, or inspect what it knows.
- To save a durable fact mid-session, state it explicitly (e.g. "remember that
  I deploy this project with X"); explicit requests save immediately.
- **Never store secrets in memory.** If a fact would reveal a key/token/credential,
  omit it (or mark it private) instead of recording it.
- Learning runs in the background on idle sessions; an empty memory right after
  install is normal. Check with "check my memory status" or the `/memory-inspect`
  panel.

## 5. Convention

- Prefer the **smallest change** that does the job; don't refactor unrelated
  code.
- For anything that runs somewhere (deploys, switches, releases):
  **eval/build first, verify the diff, then apply** — never deploy-first.
- Repos the user works in are under `~/src/` (e.g. `home-manager`, `modpack-hub`,
  `laark/panel.laark.ca`, `desktop-theme-panel`). Read that repo's `AGENTS.md`
  first.

## 6. Review checklist (cross-project)

- [ ] Change scoped, no unrelated edits
- [ ] Formatter run (alejandra for nix; prettier/eslint for the repo's stack)
- [ ] Build/tests pass for the affected project
- [ ] No secrets or local-only config (`.env`, PATs) committed
- [ ] Summary of what changed and why, given to the user

## 7. Deep-dive references

These load on demand; keep this file short.

- `~/src/home-manager/AGENTS.md` — nix repo model, hosts, sops workflow.
- `~/src/modpack-hub/AGENTS.md` — SvelteKit/Drizzle project rules.
- `~/src/laark/panel.laark.ca/AGENTS.md` — Express/React panel + n8n pipeline rules.
- `~/.config/opencode/` — opencode provider/MCP config.
