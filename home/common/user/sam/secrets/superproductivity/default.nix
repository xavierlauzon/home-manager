{config, lib, ...}:

let
  cfg = config.host.home.user.sam.secrets.superproductivity;
in
with lib;
{
  options = {
    host.home.user.sam.secrets.superproductivity = {
      captureToken = {
        enable = mkOption {
          default = false;
          type = types.bool;
          description = "Deploy the SuperSync MCP capture token file (~/.config/superproductivity/capture-token).";
        };
      };
    };
  };

  config = mkIf cfg.captureToken.enable {
    sops.secrets = {
      "superproductivity/capture-token" = {
        format = "binary";
        sopsFile = ../../../../../xl/user/sam/secrets/superproductivity/capture-token.enc;
        path = config.home.homeDirectory + "/.config/superproductivity/capture-token";
        mode = "600";
      };
    };
  };
}
