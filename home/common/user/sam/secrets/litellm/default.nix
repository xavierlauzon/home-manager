{config, lib, pkgs, specialArgs, ...}:

let
  cfg = config.host.home.user.sam.secrets.litellm;
in
  with lib;
{
  options = {
    host.home.user.sam.secrets.litellm = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Deploy encrypted LiteLLM admin config";
      };
      mcpEnv = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Deploy encrypted LiteLLM Admin MCP credentials env file (LITELLM_API_KEY = personal proxy_admin key)";
        };
      };
    };
  };

  config = mkIf cfg.mcpEnv.enable {
    sops.secrets = {
      "litellm/mcp.env" = {
        format = "dotenv";
        sopsFile = ../../../../../xl/user/sam/secrets/litellm/mcp.env.enc;
        path = config.home.homeDirectory+"/.config/litellm/mcp.env";
        mode = "600";
      };
    };
  };
}
