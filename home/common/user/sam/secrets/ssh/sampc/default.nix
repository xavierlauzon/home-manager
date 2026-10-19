{config, lib, pkgs, specialArgs, ...}:

let
  cfg = config.host.home.user.sam.secrets.ssh.sampc;
  passwordPath = config.sops.secrets."ssh/sampc-password".path;

  # spamtrap: names are reassembled from fragments so web crawlers don't index
  # the plaintext host/domain. Kept consistent with the xl/sd SSH configs.
  mk = lib.concatStrings;
  l = "l"; a = "a"; u = "u"; z = "z"; o = "o"; n = "n"; dot = "."; x = "x"; y = "y";
  domain = mk [ l a u z o n dot x y z ];        # lauzon.xyz
  sc = mk [ "s" "a" "m" "p" "c" ];              # sampc
  user = mk [ "s" "a" "m" "s" "h" ];            # samsh
in
  with lib;
{
  options = {
    host.home.user.sam.secrets.ssh.sampc = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable SSH to sampc with the xl keypair and sops-protected password fallback";
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

    # Must come before the `*.${domain}` wildcard block (first obtained value wins in ssh_config).
    programs.ssh.settings."${sc} ${sc}.${domain}" = lib.hm.dag.entryBefore [ "*.${domain}" ] {
      User = user;
      IdentityFile = config.sops.secrets."ssh/xl-id_ed25519".path;
      PubkeyAuthentication = "yes";
      PreferredAuthentications = "publickey,password,keyboard-interactive";
      NumberOfPasswordPrompts = "1";
    };

    programs.bash.bashrcExtra = ''
      # Always use the sops-protected password for ${sc}.${domain}
      ssh() {
        local target="''${1:-}"
        if [[ "$target" == "${sc}" || "$target" == "${sc}.${domain}" || "$target" == "${user}@${sc}" || "$target" == "${user}@${sc}.${domain}" ]]; then
          ${pkgs.sshpass}/bin/sshpass -f ${passwordPath} "$(type -P ssh)" "$@"
        else
          command ssh "$@"
        fi
      }
    '';
  };
}
