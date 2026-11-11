{
  config,
  lib,
  ...
}: let
  cfg = config.host.home.user.sam.secrets.github;
in
  with lib; {
    options = {
      host.home.user.sam.secrets.github = {
        token = {
          enable = mkOption {
            default = false;
            type = types.bool;
            description = "Deploy the GitHub PAT (sops) so gh CLI is signed in and github.com git push works.";
          };
        };
      };
    };

    config = mkIf cfg.token.enable {
      sops.secrets = {
        # gh CLI auth file. gh's own credential helper (`gh auth git-credential`,
        # wired by the gh module) reads this, so `gh auth status` is signed in
        # and github.com pushes work headless (cron) with no prompt.
        "github/hosts" = {
          format = "binary";
          sopsFile = ../../../../../xl/user/sam/secrets/github/hosts.yml.enc;
          path = config.home.homeDirectory + "/.config/gh/hosts.yml";
          mode = "600";
        };
      };
    };
  }
