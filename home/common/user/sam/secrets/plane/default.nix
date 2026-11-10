{config, lib, pkgs, specialArgs, ...}:

let
  cfg = config.host.home.user.sam.secrets.plane;
in
  with lib;
{
  options = {
    host.home.user.sam.secrets.plane = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Deploy encrypted Plane config";
      };
      mcpEnv = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Deploy encrypted Plane MCP credentials env file";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      # "plane/config.toml" = {
      #   format = "binary";
      #   sopsFile = ../../../../../xl/user/sam/secrets/plane/config.toml.enc;
      #   path = config.home.homeDirectory+"/.config/plane/config.toml";
      #   mode = "600";
      # };
    };
  } // (mkIf cfg.mcpEnv.enable {
    sops.secrets = {
      "plane/mcp.env" = {
        format = "dotenv";
        sopsFile = ../../../../../xl/user/sam/secrets/plane/mcp.env.enc;
        path = config.home.homeDirectory+"/.config/plane/mcp.env";
        mode = "600";
      };
    };
  });
}
