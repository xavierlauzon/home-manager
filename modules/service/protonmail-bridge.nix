{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.home.service.protonmail-bridge;
in
  with lib; {
    options = {
      host.home.service.protonmail-bridge = {
        enable = mkOption {
          default = false;
          type = types.bool;
          description = "Run Proton Mail Bridge headless (IMAP/SMTP loopback for Proton Mail)";
        };
        logLevel = mkOption {
          default = "info";
          type = types.str;
          description = "Bridge log level (panic|fatal|error|warn|info|debug)";
        };
      };
    };

    # One-time setup (not scriptable - needs the account password + 2FA):
    #   1. ~/.local/bin/proton-bridge-init   (creates passphrase-free GPG key + pass vault)
    #   2. systemctl --user stop protonmail-bridge   (the service holds the lock)
    #   3. protonmail-bridge --cli
    #        -> login   (Proton address, account password, 2FA, mailbox password)
    #        -> info    (IMAP/SMTP username + generated Bridge password)
    #        -> exit
    #   4. Put the username + the `info` Bridge password into the sops secrets
    #      (home/xl/user/sam/secrets/proton/{username,password}.enc) via `sops`.
    #   5. home-manager switch --flake .#blackhawk.sam --impure
    #   6. systemctl --user start protonmail-bridge
    # Note: the `info` password is the Bridge's mail-client password, NOT the
    # Proton account password. They differ on purpose; the MCP server must use
    # the mail-client one. The account persists in the Bridge's own vault
    # (~/.config/protonmail/bridge-v3), so it survives restarts.
    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        protonmail-bridge
        pass
        gnupg
        # Small terminal client for the MCP server / manual mail ops.
        proton-mail-bridge-client
      ];

      # Proton Bridge stores its account credentials in a local vault via the
      # `pass` keychain helper. Initialise the vault once (see
      # proton-bridge-init below), then sign in: `protonmail-bridge --cli`.
      systemd.user.services.protonmail-bridge = {
        Unit = {
          Description = "Proton Mail Bridge (IMAP 127.0.0.1:1143 / SMTP 127.0.0.1:1025)";
          After = ["network.target" "default.target"];
        };
        Service = {
          ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive --log-level ${cfg.logLevel}";
          Restart = "on-failure";
          RestartSec = 10;
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };

      # One-time, idempotent helper: creates a passphrase-free GPG key and the
      # pass store that Proton Bridge uses as its credential vault. Run once,
      # then `protonmail-bridge --cli` -> login.
      home.file.".local/bin/proton-bridge-init" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail

          GPG_ID="ProtonMail Bridge"

          if ! gpg --list-secret-keys "$GPG_ID" >/dev/null 2>&1; then
            echo "Creating passphrase-free GPG key '$GPG_ID'..."
            EMPTY=""
            gpg --batch --pinentry-mode loopback --passphrase "$EMPTY" --quick-gen-key "$GPG_ID" default default never
          fi

          KEY_FPR=$(gpg --list-secret-keys --with-colons "$GPG_ID" 2>/dev/null | awk -F: '$1=="fpr"{print $10; exit}')

          if [ ! -d "$HOME/.password-store" ]; then
            echo "Initialising pass store..."
            pass init "$KEY_FPR"
          fi

          echo "Pass vault ready. Next, sign in once:"
          echo "  protonmail-bridge --cli"
          echo "    -> login   (Proton address, account password, 2FA, mailbox password)"
          echo "    -> info    (note the generated Bridge password - NOT your Proton password)"
          echo "    -> exit"
        '';
      };
    };
  }
