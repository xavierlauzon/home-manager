{config, lib, pkgs, specialArgs, ...}:

let
  inherit (specialArgs) username;
  cfg = config.host.home.user.sam.secrets.ssh.xl;
  # spamtrap: domain reassembled from fragments so crawlers don't index it.
  mk = lib.concatStrings;
  l = "l"; a = "a"; u = "u"; z = "z"; o = "o"; n = "n"; dot = "."; x = "x"; y = "y";
  domain = mk [ l a u z o n dot x y z ];  # lauzon.xyz
in
  with lib;
{

  options = {
    host.home.user.sam.secrets.ssh.xl = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable SSH to these hosts with unique Keypair";
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      #"bashrc.d/xl_remotehosts.sh" = {
      #  format = "binary";
      #  sopsFile = ../../../../../../xl/secrets/bash-xl_remotehosts.sh;
      #  mode = "500";
      #};
      "ssh/xl-id_ed25519" = {
        format = "binary";
        sopsFile = ../../../../../../xl/user/sam/secrets/ssh/xl-id_ed25519.enc;
        path = config.home.homeDirectory+"/.ssh/keys/xl-id_ed25519";
        mode = "600";
      };
      "ssh/xl-id_ed25519.pub" = {
        format = "binary";
        sopsFile = ../../../../../../xl/user/sam/secrets/ssh/xl-id_ed25519.pub.enc;
        path = config.home.homeDirectory+"/.ssh/keys/xl-id_ed25519.pub";
        mode = "600";
      };
    };

    programs = {
      ssh = {
        enable = mkDefault true;
        settings."*.${domain}" = {
          User = "sam";
          IdentityFile = config.sops.secrets."ssh/xl-id_ed25519".path;
        };
      };
    };
  };
}
