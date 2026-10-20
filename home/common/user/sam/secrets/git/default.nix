{config, lib, ...}:

let
  cfg = config.host.home.user.sam.secrets.git;
in
with lib;
{
  options = {
    host.home.user.sam.secrets.git = {
      token = {
        enable = mkOption {
          default = false;
          type = types.bool;
          description = "Deploy the git.lauzon.xyz PAT (sops) for headless git push auth (cron).";
        };
      };
    };
  };

  config = mkIf cfg.token.enable {
    sops.secrets = {
      "git/env" = {
        format = "dotenv";
        sopsFile = ../../../../../xl/user/sam/secrets/git/env.enc;
        path = config.home.homeDirectory + "/.config/git/lauzon.env";
        mode = "600";
      };
    };
  };
}
