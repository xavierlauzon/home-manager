---
name: secret-handling
description: Use sops-nix/age secrets safely; never read or commit them.
---

# sops-nix / age secrets

The user's machine secrets are managed with **sops-nix + age**, rooted in `~/src/home-manager`.

## Rules

- **Never read, decrypt, or commit the encrypted files.** `decrypted/` is gitignored; sops-nix
  generates it on activation.
- **Never print a secret** (password, API key, token, credential) into a command, file, or chat.
- Secrets live under `home/*/secrets/**`; `.sops.yaml` maps `path_regex: home/*/secrets/.*` to the
  age keys.
- To add/change a secret, edit it with `sops` (which decrypts/encrypts in place), not a plaintext
  editor:
  ```sh
  sops home/xl/user/sam/secrets/<name>/default.nix
  ```
- Reference secrets in config via `config.sops.secrets.<name>` / `sopsFile` — never inline the
  plaintext.
- Add the new key/recipient to `.sops.yaml` `creation_rules` before encrypting for a new target.

## Verify

`sops` opens the file for editing; the committed file is encrypted; `decrypted/` is not in git.
