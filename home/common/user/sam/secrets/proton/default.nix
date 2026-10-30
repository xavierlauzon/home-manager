{
  config,
  lib,
  ...
}: let
  cfg = config.host.home.user.sam.secrets.proton;
in
  with lib; {
    options = {
      host.home.user.sam.secrets.proton = {
        enable = mkOption {
          default = false;
          type = types.bool;
          description = "Deploy Proton Mail Bridge MCP credentials (username + Bridge password)";
        };
      };
    };

    config = mkIf cfg.enable {
      # The Bridge password is generated per-install by Proton Bridge at login;
      # it is NOT the Proton account password. The MCP server reads these via
      # PROTONMAIL_USERNAME_FILE / PROTONMAIL_PASSWORD_FILE so the values never
      # land in the nix store or the Hermes config.yaml.
      sops.secrets = {
        "proton/username" = {
          format = "binary";
          sopsFile = ../../../../../xl/user/sam/secrets/proton/username.enc;
          path = config.home.homeDirectory + "/.config/proton/username";
          mode = "600";
        };
        "proton/password" = {
          format = "binary";
          sopsFile = ../../../../../xl/user/sam/secrets/proton/password.enc;
          path = config.home.homeDirectory + "/.config/proton/password";
          mode = "600";
        };
      };
    };
  }
