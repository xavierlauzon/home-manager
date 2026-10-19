{config, lib, pkgs, specialArgs, ...}:

let
  inherit (specialArgs) username;
  cfg = config.host.home.user.xavier.secrets.ssh.sd;
  # spamtrap: domain reassembled from fragments so crawlers don't index it.
  mk = lib.concatStrings;
  se = "se"; lf = "lf"; de = "de"; si = "si"; gn = "gn"; dot = "."; o = "o"; rg = "rg";
  domain = mk [ se lf de si gn dot o rg ];  # selfdesign.org
in
  with lib;
{

  options = {
    host.home.user.xavier.secrets.ssh.sd = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable SSH to these hosts with unique Keypair";
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      #"bashrc.d/sd_remotehosts.sh" = {
      #  format = "binary";
      #  sopsFile = ../../../../../../sd/secrets/bash-sd_remotehosts.sh;
      #  mode = "500";
      #};
      "ssh/sd-id_ed25519" = {
        format = "binary";
        sopsFile = ../../../../../../sd/user/xavierlauzon/secrets/ssh/sd-id_ed25519.enc;
        path = config.home.homeDirectory+"/.ssh/keys/sd-id_ed25519";
        mode = "600";
      };
      "ssh/sd-id_ed25519.pub" = {
        format = "binary";
        sopsFile = ../../../../../../sd/user/xavierlauzon/secrets/ssh/sd-id_ed25519.pub.enc;
        path = config.home.homeDirectory+"/.ssh/keys/sd-id_ed25519.pub";
        mode = "600";
      };
    };

    programs = {
      ssh = {
        enable = mkDefault true;
        settings."*.${domain}" = {
          User = "xavierlauzon";
          IdentityFile = config.sops.secrets."ssh/sd-id_ed25519".path;
        };
      };
    };
  };
}
