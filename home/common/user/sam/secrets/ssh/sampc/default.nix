{config, lib, pkgs, specialArgs, ...}:

let
  cfg = config.host.home.user.sam.secrets.ssh.sampc;
  passwordPath = config.sops.secrets."ssh/sampc-password".path;
in
  with lib;
{
  options = {
    host.home.user.sam.secrets.ssh.sampc = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Always authenticate to sampc.lauzon.xyz (user samsh) with the sops-protected password";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sshpass
    ];

    sops.secrets = {
      "ssh/sampc-password" = {
        format = "binary";
        sopsFile = ../../../../../../xl/user/sam/secrets/ssh/sampc-password.enc;
        path = config.home.homeDirectory + "/.ssh/keys/sampc-password";
        mode = "600";
      };
    };

    # Must come before the *.lauzon.xyz wildcard block (first obtained value wins in ssh_config).
    programs.ssh.settings."sampc sampc.lauzon.xyz" = lib.hm.dag.entryBefore [ "*.lauzon.xyz" ] {
      User = "samsh";
      PubkeyAuthentication = "no";
      PreferredAuthentications = "password,keyboard-interactive";
      NumberOfPasswordPrompts = "1";
    };

    programs.bash.bashrcExtra = ''
      # Always use the sops-protected password for sampc.lauzon.xyz
      ssh() {
        local target="''${1:-}"
        if [[ "$target" == "sampc" || "$target" == "sampc.lauzon.xyz" || "$target" == "samsh@sampc" || "$target" == "samsh@sampc.lauzon.xyz" ]]; then
          ${pkgs.sshpass}/bin/sshpass -f ${passwordPath} "$(type -P ssh)" "$@"
        else
          command ssh "$@"
        fi
      }
    '';
  };
}
