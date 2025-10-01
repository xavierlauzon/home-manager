{config, lib, pkgs, specialArgs, ...}:

let
  inherit (specialArgs) username;
  cfg = config.host.home.user.xavier.secrets.ssh.xl;
  s = "l";
  _p = "a";
  _a = "u";
  m = "z";
  t = "o";
  r = "n";
  a_ = ".";
  p_ = "xyz";
in
  with lib;
{

  options = {
    host.home.user.xavier.secrets.ssh.xl = {
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
        sopsFile = ../../../../../../xl/user/xavier/secrets/ssh/xl-id_ed25519.enc;
        path = config.home.homeDirectory+"/.ssh/keys/xl-id_ed25519";
        mode = "600";
      };
      "ssh/xl-id_ed25519.pub" = {
        format = "binary";
        sopsFile = ../../../../../../xl/user/xavier/secrets/ssh/xl-id_ed25519.pub.enc;
        path = config.home.homeDirectory+"/.ssh/keys/xl-id_ed25519.pub";
        mode = "600";
      };
    };

    programs = {
      ssh = {
        enable = mkDefault true;
        matchBlocks = {
          "*.${s}${_p}${_a}${m}${t}${r}${a_}${p_}" = {
            user = "xavier";
            identityFile = config.sops.secrets."ssh/xl-id_ed25519".path;
          };
        };
      };
    };
  };
}
