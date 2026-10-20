---
name: hm-rebuild
description: Build/switch the home-manager nix config; see gotchas.
---

# Home-manager rebuild (~/src/home-manager)

The user's home-manager config is a nix flake at `~/src/home-manager`. Follow this
workflow to make a config change and apply it.

## Prereqs

- Repo: `~/src/home-manager` (git). Entry `flake.nix`; `homeConfigurations.<hostname>.<user>`.
- Formatter: `alejandra` (in PATH). Build/switch may need `--impure` (see gotchas).

## Workflow

1. Read the repo `AGENTS.md` (documents repo model, hosts, secrets).
2. Make the smallest scoped change; thread new facts through `extraSpecialArgs`, not globals.
3. Format ONLY the file(s) you touched. **Do not run `alejandra .` on the whole repo** —
   existing files are not alejandra-formatted; a full reformat makes a huge noisy diff that
   violates the smallest-change rule. Run `alejandra <file>` on your edit only, or skip if it
   would reformat the whole file.
4. Validate (dry-run, does NOT activate):
   ```sh
   cd ~/src/home-manager
   nix flake check            # may fail on the absolute-path gotcha; see below
   home-manager build --flake .#blackhawk.sam --impure
   ```
5. Verify the generated config, e.g. for opencode:
   ```sh
   python3 -c "import json; print(json.load(open('result/home-files/.config/opencode/opencode.json')))"
   ```
6. Deploy (activate): `home-manager switch --flake .#blackhawk.sam --impure`.
7. If the change is opencode config, restart the service: `opencode2 service restart`.
8. Commit the source change (config is git-versioned).

## Gotchas

- **`--impure` is required.** `home/xl/hostname/blackhawk/sam.nix` references an absolute path
  `/home/sam/src/misc/mcp/mcp-komodo` in `programs.mcp.servers.komodo.command`, which pure eval
  forbids. Always pass `--impure`.
- **Never edit the generated store files** (e.g. `~/.config/opencode/opencode.json` is a symlink
  into the store). Edit the source `.nix` and rebuild.
- **Secrets**: sops-nix + age; never read/decrypt/commit (see `secret-handling` skill).
- **Eval-then-deploy, never deploy-first.** Build/check before switch.
- **Two nixpkgs channels** (stable 26.05 / unstable) per host; don't mix inside one config.
- opencode CLI is installed as `opencode2` (not `opencode`).

## Verify

`home-manager build` exits 0 and the generated config reflects the change; `switch` exits 0.
