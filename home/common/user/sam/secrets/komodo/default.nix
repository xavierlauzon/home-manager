{config, lib, pkgs, specialArgs, ...}:

let
  cfg = config.host.home.user.sam.secrets.komodo;
in
  with lib;
{
  options = {
    host.home.user.sam.secrets.komodo = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Deploy encrypted Komodo CLI (km) config";
      };
      mcpEnv = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Deploy encrypted Komodo MCP credentials env file";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "komodo/komodo.cli.toml" = {
        format = "binary";
        sopsFile = ../../../../../xl/user/sam/secrets/komodo/komodo.cli.toml.enc;
        path = config.home.homeDirectory+"/.config/komodo/komodo.cli.toml";
        mode = "600";
      };
    };
  } // (mkIf cfg.mcpEnv.enable {
    sops.secrets = {
      "komodo/mcp.env" = {
        format = "dotenv";
        sopsFile = ../../../../../xl/user/sam/secrets/komodo/mcp.env.enc;
        path = config.home.homeDirectory+"/.config/komodo/mcp.env";
        mode = "600";
      };
    };
  });
}
