{config, lib, ...}:

let
  cfg = config.host.home.user.sam.secrets.hermes;
in
with lib;
{
  options = {
    host.home.user.sam.secrets.hermes = {
      env = {
        enable = mkOption {
          default = false;
          type = types.bool;
          description = "Deploy Hermes Agent credentials env file (~/.hermes/.env)";
        };
      };
    };
  };

  config = mkIf cfg.env.enable {
    sops.secrets = {
      "hermes/env" = {
        format = "dotenv";
        sopsFile = ../../../../../xl/user/sam/secrets/hermes/env.enc;
        path = config.home.homeDirectory + "/.hermes/.env";
        mode = "600";
      };
    };
  };
}
